import
  algorithm, bitops, endians, math, options, sequtils, strutils, tables, times,
  secp256k1, chronicles, chronos, eth/common/eth_types, eth/[keys, rlp, async_utils],
  hashes, byteutils, nimcrypto/[bcmode, hash, keccak, rijndael, sysrand],
  eth/p2p, whisper_protocol as whisper

# Piggybacking on Whisper payload for now
type Payload* = whisper.Payload
type DecodedPayload* = whisper.DecodedPayload

# Piggybacking on Whisper encode payload method for now
proc encode*(payload: Payload): Option[Bytes] =
  return whisper.encode(payload)

# Piggybacking on Whisper decode payload method for now
proc decode*(data: openarray[byte], dst = none[PrivateKey](),
             symKey = none[SymKey]()): Option[DecodedPayload] =
  return whisper.decode(data, dst, symKey)
