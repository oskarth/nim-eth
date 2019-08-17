import
  eth/p2p, chronos, chronicles, eth/rlp, chronos/timer

const
  bzzVersion = 12
  hiveVersion = 10
  networkId = 4

type 
  Capabilities = object
    Caps: seq[Capability]
  Capability = object
    ID: uint
    Cap: seq[bool]
  Handshake = object
    version: uint
    networkid: uint
    ad: seq[seq[byte]]
    capabilities: Capabilities

p2pProtocol Hive(version = hiveVersion,
  rlpxName = "hive"):

  proc peersMsg(peer: Peer)
  proc subPeersMsg(peer:Peer)

  onPeerConnected do (peer: Peer):
    warn "conn hive"
    waitFor sleepAsync(60000)

p2pProtocol Bzz(version = 12, #bzzVersion,
  rlpxName = "bzz"):
 
  proc hs(peer: Peer,
    Payload: Handshake) =
      echo "foo"
      echo Payload.version 
      echo Payload.ad

  onPeerConnected do (peer: Peer):
    warn "conn"
    var
      oad = newSeq[byte](32)
      en: string = "enode://0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef@127.0.0.1:30399" #newSeq[byte](32) 
      uad = newSeq[byte](len(en))
      ad = newSeq[seq[byte]](2)
      cps: Capabilities
      cp: Capability

    # surely a nicer way to do this exists
    cp.ID = 0
    cp.Cap = newSeq[bool](16)
    cp.Cap[0] = true
    cp.Cap[1] = true
    cp.Cap[4] = true
    cp.Cap[5] = true
    cp.Cap[15] = true
    cps.Caps = newSeq[Capability](1)
    cps.Caps[0] = cp
    for i in byte(0)..byte(31):
      oad[i] = i
    var i: int = 0
    for e in en:
      uad[i] = byte(ord(e))
      i.inc()
    ad[0] = oad 
    ad[1] = uad 
   
    var hsp: Handshake
    hsp.version = bzzVersion
    hsp.networkid = networkId
    hsp.ad = ad 
    hsp.capabilities = cps
    waitFor sleepAsync(1000)
    #discard await peer.nextMsg(Bzz.hs)
    waitFor peer.hs(hsp)
    waitFor sleepAsync(60000)

