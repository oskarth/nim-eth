import
  eth/p2p, chronos, chronicles, eth/rlp, chronos/timer

const
  simpleVersion = 1

type
  SimpleContent = object
    Version: uint

p2pProtocol Bzz(version = simpleVersion,
                rlpxName = "smp"):
 
  onPeerConnected do (peer: Peer):
    warn "conn"
    
    var content: SimpleContent 
    content.Version = 42
    waitFor peer.SimpleMessage(content)
    waitFor sleepAsync(1000)
  proc SimpleMessage(peer: Peer,
    payload: SimpleContent)
