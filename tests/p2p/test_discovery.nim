#
#                 Ethereum P2P
#              (c) Copyright 2018
#       Status Research & Development GmbH
#
#    See the file "LICENSE", included in this
#    distribution, for details about the copyright.
#

import
  sequtils, unittest, chronos, stew/byteutils,
  eth/[keys, rlp], eth/p2p/[discovery, kademlia, enode],
  ./p2p_test_helper

proc nodeIdInNodes(id: NodeId, nodes: openarray[Node]): bool =
  for n in nodes:
    if id == n.id: return true

proc test() {.async.} =
  suite "Discovery Tests":
    let
      bootNodeKey = initPrivateKey("a2b50376a79b1a8c8a3296485572bdfbf54708bb46d3c25d73d2723aaaf6a617")
      bootNodeAddr = localAddress(20301)
      bootENode = initENode(bootNodeKey.getPublicKey, bootNodeAddr)
      bootNode = await startDiscoveryNode(bootNodeKey, bootNodeAddr, @[])

    test "Discover nodes":
      let nodeKeys = [
        initPrivateKey("a2b50376a79b1a8c8a3296485572bdfbf54708bb46d3c25d73d2723aaaf6a618"),
        initPrivateKey("a2b50376a79b1a8c8a3296485572bdfbf54708bb46d3c25d73d2723aaaf6a619"),
        initPrivateKey("a2b50376a79b1a8c8a3296485572bdfbf54708bb46d3c25d73d2723aaaf6a620")
      ]
      var nodeAddrs = newSeqOfCap[Address](nodeKeys.len)
      for i in 0 ..< nodeKeys.len: nodeAddrs.add(localAddress(20302 + i))

      var nodes = await all(zip(nodeKeys, nodeAddrs).mapIt(
        startDiscoveryNode(it.a, it.b, @[bootENode]))
      )
      nodes.add(bootNode)

      for i in nodes:
        for j in nodes:
          if j != i:
            check(nodeIdInNodes(i.thisNode.id, j.randomNodes(nodes.len - 1)))

    test "Test Vectors":
      # These are the test vectors from EIP-8:
      # https://github.com/ethereum/EIPs/blob/master/EIPS/eip-8.md#rlpx-discovery-protocol
      # However they are unpacked and the expiration is changed from 0x43b9a355
      # to 0x6fd3aed7 so that they remain valid for a while
      let validProtocolData = [
        # ping packet with version 4, additional list elements
        "01ec04cb847f000001820cfa8215a8d790000000000000000000000000000000018208ae820d05846fd3aed70102",
        # ping packet with version 555, additional list elements and additional random data
        "01f83e82022bd79020010db83c4d001500000000abcdef12820cfa8215a8d79020010db885a308d313198a2e037073488208ae82823a846fd3aed7c5010203040531b9019afde696e582a78fa8d95ea13ce3297d4afb8ba6433e4154caa5ac6431af1b80ba76023fa4090c408f6b4bc3701562c031041d4702971d102c9ab7fa5eed4cd6bab8f7af956f7d565ee1917084a95398b6a21eac920fe3dd1345ec0a7ef39367ee69ddf092cbfe5b93e5e568ebc491983c09c76d922dc3",
        # pong packet with additional list elements and additional random data
        "02f846d79020010db885a308d313198a2e037073488208ae82823aa0fbc914b16819237dcd8801d7e53f69e9719adecb3cc0e790c57e91ca4461c954846fd3aed7c6010203c2040506a0c969a58f6f9095004c0177a6b47f451530cab38966a25cca5cb58f055542124e",
        # findnode packet with additional list elements and additional random data
        "03f84eb840ca634cae0d49acb401d8a4c6b6fe8c55b70d115bf400769cc1400f3258cd31387574077f301b421bc84df7266c44e9e6d569fc56be00812904767bf5ccd1fc7f846fd3aed782999983999999280dc62cc8255c73471e0a61da0c89acdc0e035e260add7fc0c04ad9ebf3919644c91cb247affc82b69bd2ca235c71eab8e49737c937a2c396",
        # neighbours packet with additional list elements and additional random data
        "04f9015bf90150f84d846321163782115c82115db8403155e1427f85f10a5c9a7755877748041af1bcd8d474ec065eb33df57a97babf54bfd2103575fa829115d224c523596b401065a97f74010610fce76382c0bf32f84984010203040101b840312c55512422cf9b8a4097e9a6ad79402e87a15ae909a4bfefa22398f03d20951933beea1e4dfa6f968212385e829f04c2d314fc2d4e255e0d3bc08792b069dbf8599020010db83c4d001500000000abcdef12820d05820d05b84038643200b172dcfef857492156971f0e6aa2c538d8b74010f8e140811d53b98c765dd2d96126051913f44582e8c199ad7c6d6819e9a56483f637feaac9448aacf8599020010db885a308d313198a2e037073488203e78203e8b8408dcab8618c3253b558d459da53bd8fa68935a719aff8b811197101a4b2b47dd2d47295286fc00cc081bb542d760717d1bdd6bec2c37cd72eca367d6dd3b9df73846fd3aed7010203b525a138aa34383fec3d2719a0",
      ]
      let
        address = localAddress(20302)
        nodeKey = initPrivateKey("b71c71a67e1177ad4e901695e1b4b9ee17ae16c6668d313eac2f96dbcda3f291")

      for data in validProtocolData:
        # none of these may raise
        bootNode.receive(address, packData(hexToSeqByte(data), nodeKey))

    test "Invalid protocol data":
      let invalidProtocolData = [
        "0x00",   # invalid msg id
        "0x01",   # empty payload
        "0x03b8", # no list but string
        "0x01C0", # empty list
        # FindNode target that is 1 byte too long
        # We currently do not raise on this, so can't really test it
        # "0x03f847b841AA0000000000000000000000000000000000000000000000000000000000000000a99a96bd988e1839272f93257bd9dfb2e558390e1f9bff28cdc8f04c9b5d06b1846fd3aed7",
      ]
      let
        address = localAddress(20302)
        nodeKey = initPrivateKey("a2b50376a79b1a8c8a3296485572bdfbf54708bb46d3c25d73d2723aaaf6a618")

      for data in invalidProtocolData:
        expect DiscProtocolError:
          bootNode.receive(address, packData(hexToSeqByte(data), nodeKey))

      # empty msg id and payload, doesn't raise, just fails abd prints wrong
      # msg mac
      bootNode.receive(address, packData(@[], nodeKey))

waitFor test()
