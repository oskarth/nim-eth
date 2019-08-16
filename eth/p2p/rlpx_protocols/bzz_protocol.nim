import
  eth/p2p, chronos, chronicles

const
  bzzVersion = 42

type
   BzzPeer = ref object
     initialized: bool
   
   BzzNetwork = ref object
     foo: string 

p2pProtocol Bzz(version = bzzVersion,
  rlpxName = "bzz",
  peerState = BzzPeer,
  networkState = BzzNetwork):
  onPeerConnected do (peer: Peer):
    trace "onPeerConnected Whisper"
