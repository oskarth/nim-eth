import
  sequtils, options, unittest, tables, chronos, eth/[keys, p2p], 
  eth/p2p/rlpx_protocols/whisper_protocol, eth/p2p/[enode, peer_pool], eth/p2p/rlpx_protocols/bzz_protocol, ./p2p_test_helper

var nextPort = 30303

proc setupBzzTestNode*(capabilities: varargs[ProtocolInfo, `protocolInfo`],
  networkId: uint): EthereumNode =
  let keys1 = newKeyPair()
  result = newEthereumNode(keys1, localAddress(nextPort), networkId, nil, "bzz-nim/0.0.2",
                           addAllCapabilities = false)
  nextPort.inc
  for capability in capabilities:
    result.addCapability capability

suite "Bzz connections":
  var node1 = setupBzzTestNode(Bzz, 4)
  var node2Pub = keys.initPublicKey("0x818d337ee5a93dc699850463f6cc73c52d0d2d7cd3b1d58949760dba801e873ae9c57611d32dcf2f82cc14fc4619ea1124e4d59641f8e47d40ab2115f6893b06")
  var node2Port = Port(30399)
  var node2Addr = Address(udpPort: node2Port, tcpPort: node2Port, ip: parseIpAddress("127.0.0.1"))

  waitFor node1.peerPool.connectToNode(newNode(initENode(node2Pub,
    node2Addr)))
  asyncTest "Two peers connected":
    waitFor sleepAsync(2000)
    check:
      node1.peerPool.connectedNodes.len() == 1
