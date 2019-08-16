import
  eth/p2p, chronos, chronicles, eth/rlp, chronos/timer

const
  bzzVersion = 42

p2pProtocol Bzz(version = bzzVersion):

  proc hellooo(peer: Peer,
    foo: string) =
     echo foo
    
  onPeerConnected do (peer: Peer):
    warn "conn"
    if peer.supports(Bzz):
      warn "bzz"
      waitFor peer.hellooo("bar")
      waitFor sleepAsync(1000)
