import
    sequtils, options, unittest, times, tables,
    nimcrypto/hash,
    eth/[keys, rlp],
    eth/p2p/rlpx_protocols/pss_protocol as pss

suite "PSS payload":
  test "should roundtrip without keys":
    # Piggyback on Whisper's payload for now

    let payload = Payload(payload: @[byte 0, 1, 2])
    let encoded = encode(payload)

    let decoded = pss.decode(encoded.get())
    check:
      1 == 1
      decoded.isSome()
      payload.payload == decoded.get().payload
      decoded.get().src.isNone()
      decoded.get().padding.get().len == 251 # 256 -1 -1 -3
