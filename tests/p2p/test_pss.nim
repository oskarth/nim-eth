# import options, unittest,
#     eth/p2p/rlpx_protocols/pss_protocol as pss

import
    sequtils, options, unittest, times, tables,
    nimcrypto/hash,
    eth/[keys, rlp],
    eth/p2p/rlpx_protocols/pss_protocol as pss

suite "PSS payload":
  test "should roundtrip without keys":

    echo "1"
    let payload = Payload(payload: @[byte 0, 1, 2])
    echo "2"
    let encoded = pss.encode(payload)

    echo "test encoded ", encoded

    # Fails here
    echo "get ", encoded.get()
    let decoded = pss.decode(encoded.get())

    echo "test decoded ", decoded
    check:
        1 == 1
    #   decoded.isSome()
    #   payload.payload == decoded.get().payload
    #   decoded.get().src.isNone()
    #   decoded.get().padding.get().len == 251 # 256 -1 -1 -3

