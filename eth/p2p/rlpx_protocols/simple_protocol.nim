import
  eth/p2p, chronos, chronicles, eth/rlp, chronos/timer

const
  simpleVersion = 1

p2pProtocol Bzz(version = simpleVersion,
                rlpxName = "smp"):
 
  onPeerConnected do (peer: Peer):
    warn "conn"
        
    waitFor peer.simpleMsg(42)
    waitFor sleepAsync(1000)

  proc simpleMsg(peer: Peer,
    version: uint)
