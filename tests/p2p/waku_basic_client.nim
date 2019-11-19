#
#                 Ethereum P2P
#              (c) Copyright 2018
#       Status Research & Development GmbH
#
#            Licensed under either of
#  Apache License, version 2.0, (LICENSE-APACHEv2)
#            MIT license (LICENSE-MIT)

import
  sequtils, options, strutils, parseopt, chronos,
  eth/[keys, rlp, p2p],
  eth/p2p/[discovery, enode, peer_pool, bootnodes, whispernodes]

import eth/p2p/rlpx_protocols/waku_protocol as waku
import eth/p2p/rlpx_protocols/whisper_protocol as whisper

# TODO: To start with, listen to all whisper nodes
# `nim c -o:waku_client tests/p2p/waku_basic_client.nim` and
# `./waku_client --mainnet` should show Whisper peers too

# TODO: Then, redirect traffic

const
  DefaultListeningPort = 30303
  Usage = """Usage:
  tssh_client [options]
Options:
  -p --port                 Listening port
  --post                    Post messages
  --watch                   Install filters
  --mainnet                 Connect to main network (default local private)
  --local                   Only local loopback
  --help                    Display this help and exit"""

  DockerBootnode = "enode://f41f87f084ed7df4a9fd0833e395f49c89764462d3c4bc16d061a3ae5e3e34b79eb47d61c2f62db95ff32ae8e20965e25a3c9d9b8dbccaa8e8d77ac6fc8efc06@172.17.0.2:30301"

type
  WakuConfig* = object
    listeningPort*: int
    post*: bool
    watch*: bool
    main*: bool
    local*: bool

proc processArguments*(): WakuConfig =
  var opt = initOptParser()
  var length = 0
  for kind, key, value in opt.getopt():
    case kind
    of cmdArgument:
      echo key
    of cmdLongOption, cmdShortOption:
      inc(length)
      case key.toLowerAscii()
        of "help", "h": quit(Usage, QuitSuccess)
        of "port", "p":
          result.listeningPort = value.parseInt
        of "post":
          result.post = true
        of "watch":
          result.watch = true
        of "mainnet":
          result.main = true
        of "local":
          result.local = true
        else: quit(Usage)
    of cmdEnd:
      quit(Usage)

let config = processArguments()

var port: Port
var address: Address
var netId: uint

# config
if config.listeningPort != 0:
  port = Port(config.listeningPort)
else:
  port = Port(DefaultListeningPort)
if config.local:
  address = Address(udpPort: port, tcpPort: port, ip: parseIpAddress("127.0.0.1"))
else:
  address = Address(udpPort: port, tcpPort: port, ip: parseIpAddress("0.0.0.0"))
if config.main:
  netId = 1
else:
  netId = 15

let keypair = newKeyPair()
var node = newEthereumNode(keypair, address, netId, nil, addAllCapabilities = false)

node.addCapability Waku
node.addCapability Whisper

# lets prepare some prearranged keypairs
let encPrivateKey = initPrivateKey("5dc5381cae54ba3174dc0d46040fe11614d0cc94d41185922585198b4fcef9d3")
let encPublicKey = encPrivateKey.getPublicKey()
let signPrivateKey = initPrivateKey("365bda0757d22212b04fada4b9222f8c3da59b49398fa04cf612481cd893b0a3")
let signPublicKey = signPrivateKey.getPublicKey()
var symKey: waku.SymKey
# To test with geth: all 0's key is invalid in geth console
symKey[31] = 1
let topic = [byte 0x12, 0, 0, 0]

if config.main:
  var bootnodes: seq[ENode] = @[]
  for nodeId in MainnetBootnodes:
    var bootnode: ENode
    discard initENode(nodeId, bootnode)
    bootnodes.add(bootnode)

  asyncCheck node.connectToNetwork(bootnodes, true, true)
  # main network has mostly non WAKU nodes, so we connect directly to WAKU nodes
  # XXX: To start with, listen to Whisper nodes
  for nodeId in WhisperNodes:
    var wakuENode: ENode
    discard initENode(nodeId, wakuENode)
    var wakuNode = newNode(wakuENode)
    asyncCheck node.peerPool.connectToNode(wakuNode)
else:
  var bootENode: ENode
  discard initENode(DockerBootNode, bootENode)
  waitFor node.connectToNetwork(@[bootENode], true, true)

# XXX: using Whisper for now

if config.watch:
  # XXX: Is this only called for Whisper envelopes?
  proc handler(msg: whisper.ReceivedMessage) =
    echo msg.decoded.payload.repr

  # filter encrypted asym
  discard node.subscribeFilter(whisper.newFilter(privateKey = some(encPrivateKey),
                                         topics = @[topic]),
                               handler)
  # filter encrypted asym + signed
  discard node.subscribeFilter(whisper.newFilter(some(signPublicKey),
                                         privateKey = some(encPrivateKey),
                                         topics = @[topic]),
                               handler)
  # filter encrypted sym
  discard node.subscribeFilter(whisper.newFilter(symKey = some(symKey),
                                         topics = @[topic]),
                               handler)
  # filter encrypted sym + signed
  discard node.subscribeFilter(whisper.newFilter(some(signPublicKey),
                                         symKey = some(symKey),
                                         topics = @[topic]),
                               handler)

# XXX: Using whisper for now

if config.post:
  # encrypted asym

  # XXX: is node.postMessage(...) definitely same as postMessage(node, ...)?
  discard whisper.postMessage(node, some(encPublicKey), ttl = 5, topic = topic,
                           payload = repeat(byte 65, 10))
  poll()
#   # # encrypted asym + signed
  discard whisper.postMessage(node, some(encPublicKey), src = some(signPrivateKey),
                           ttl = 5, topic = topic, payload = repeat(byte 66, 10))
  poll()
  # # encrypted sym
  discard whisper.postMessage(node, symKey = some(symKey), ttl = 5, topic = topic,
                           payload = repeat(byte 67, 10))
  poll()
  # # encrypted sym + signed
  discard whisper.postMessage(node, symKey = some(symKey), src = some(signPrivateKey),
                           ttl = 5, topic = topic, payload = repeat(byte 68, 10))

while true:
  poll()
