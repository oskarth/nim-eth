# to be run with /tests/go/simplenode.go
import
  unittest, chronos, tables,
  eth/[keys, p2p], eth/p2p/[enode, peer_pool, discovery],
  eth/p2p/rlpx_protocols/simple_protocol

var nextPort = 30304

template asyncTest*(name, body: untyped) =
  test name:
    proc scenario {.async.} = body
    waitFor scenario()

proc localAddress*(port: int): Address =
  let port = Port(port)
  result = Address(udpPort: port, tcpPort: port, ip: parseIpAddress("127.0.0.1"))

proc setupSimpleTestNode*(capabilities: varargs[ProtocolInfo, `protocolInfo`],
  networkId: uint): EthereumNode =
  let keys1 = newKeyPair()
  result = newEthereumNode(keys1, localAddress(nextPort), networkId, nil, "simple-nim/0.0.1",
                           addAllCapabilities = false)
  nextPort.inc
  for capability in capabilities:
    result.addCapability capability

suite "Simple connection":
  var node1 = setupSimpleTestNode(Bzz, 1)
  var node2PubHex = "0x04501d11c89f8d2c0811a284f58541f2259be938276d490203000f9099e3f65f28fa5e0f90b3e7936338d121cf7115d6be9f89047f2141237594c2c71f3c1ce6"
  var node2Pub = keys.initPublicKey(node2PubHex)
  var node2Port = Port(30303)
  var node2Addr = Address(udpPort: node2Port, tcpPort: node2Port, ip: parseIpAddress("127.0.0.1"))

  waitFor node1.peerPool.connectToNode(newNode(initENode(node2Pub,
    node2Addr)))
  asyncTest "Two peers connected":
    waitFor sleepAsync(2000)
    check:
      node1.peerPool.connectedNodes.len() == 1
