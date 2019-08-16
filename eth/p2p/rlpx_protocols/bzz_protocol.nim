import
  eth/p2p, chronos, chronicles, eth/rlp, chronos/timer

const
  bzzVersion = 12

p2pProtocol Bzz(version = bzzVersion,
                rlpxName = "bzz"):
 
  onPeerConnected do (peer: Peer):
    warn "conn"
    var
      oad = newSeq[byte](32)
      en: string = "enode://040123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef@127.0.0.1:30399" #newSeq[byte](32) 
      uad = newSeq[byte](len(en))
      cps: array[0..0, array[0..1, byte]]
      cp: array[0..1, byte] # light node legacy preset capability 
    cp[0] = byte(0) # zeroed by default?
    cp[1] = byte(3)
    cps[0] = cp
    for i in byte(0)..byte(31):
      oad[i] = i
    var i: int = 0
    for e in en:
      uad[i] = byte(ord(e))
      i.inc()
    waitFor peer.hs(12, 4, array([oad, uad]), cps)
    waitFor sleepAsync(1000)

  proc hs(peer: Peer,
    version: uint,
    networkid: uint,
    ad: array[0..1, seq[byte]],
    cp: array[0..0, array[0..1, byte]]) =
    echo rlp.encode(ad)
    
