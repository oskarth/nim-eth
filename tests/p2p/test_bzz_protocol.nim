import
  sequtils, options, unittest, tables, chronos, eth/[keys, p2p],
  eth/p2p/rlpx_protocols/whisper_protocol, eth/p2p/peer_pool, eth/p2p/rlpx_protocols/bzz_protocol, ./p2p_test_helper

suite "Whisper connections":
  var node1 = setupTestNode(Bzz)
  var node2 = setupTestNode(Bzz)
  node2.startListening()
  waitFor node1.peerPool.connectToNode(newNode(initENode(node2.keys.pubKey,
                                                         node2.address)))
  asyncTest "Two peers connected":
    check:
      node1.peerPool.connectedNodes.len() == 1


