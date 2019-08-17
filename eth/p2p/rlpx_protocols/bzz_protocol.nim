import
  eth/p2p, chronos, chronicles, eth/rlp, chronos/timer

const
  bzzVersion = 11

p2pProtocol Bzz(version = bzzVersion,
                rlpxName = "bzz"):
 
  onPeerConnected do (peer: Peer):
    warn "conn"
    var
      oad = newSeq[byte](32)
      en: string = "enode://040123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef@127.0.0.1:30399" #newSeq[byte](32) 
      uad = newSeq[byte](len(en))
      ad = newSeq[seq[byte]](2)
      #cps = newSeq[seq[byte]](1) #array[0..0, array[0..1, byte]]
      #cp = newSeq[byte](2)
      # cp: array[0..1, byte] # light node legacy preset capability 
    #cp[0] = byte(0) # zeroed by default?
    #cp[1] = byte(3)
    #cps[0] = cp
    for i in byte(0)..byte(31):
      oad[i] = i
    var i: int = 0
    for e in en:
      uad[i] = byte(ord(e))
      i.inc()
    ad[0] = oad 
    ad[1] = uad 
    
    #waitFor peer.hs(12, 4, rlp.encode(ad), rlp.encode(cps))
    waitFor peer.hs(12, 4, ad)
    waitFor sleepAsync(1000)

  proc hs(peer: Peer,
    version: uint,
    networkid: uint,
    ad: seq[seq[byte]])
    #cp: seq[seq[byte]])
      # hmmm
#      var o = newSeq[seq[byte]](4)
#      o[0] = rlp.encode(version)
#      o[1] = rlp.encode(networkid)
#      o[2] = rlp.encode(ad)
#      o[3] = rlp.encode(cp)
#      echo rlp.encode(o)
