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



# #cool

# # Core concepts
# # 1. Encryption key - type?
# # 2. Topic - type?
# # 3. Message payload

# type
#   Hash* = MDigest[256]
#   SymKey* = array[256 div 8, byte] ## AES256 key, 8 bits
#   Topic* = array[4, byte]

#   Payload* = object
#     ## XXX: Taken from Whisper, how is this different for PSS?
#     ## Payload is what goes in the data field of the Envelope

#     src*: Option[PrivateKey] ## Optional key used for signing message
#     dst*: Option[PublicKey] ## Optional key used for asymmetric encryption
#     symKey*: Option[SymKey] ## Optional key used for symmetric encryption
#     payload*: Bytes ## Application data / message contents
#     padding*: Option[Bytes] ## Padding - if unset, will automatically pad up to
#                             ## nearest maxPadLen-byte boundary

#   DecodedPayload* = object
#     src*: Option[PublicKey] ## If the message was signed, this is the public key
#                             ## of the source
#     payload*: Bytes ## Application data / message contents
#     padding*: Option[Bytes] ## Message padding

#   Envelope* = object
#     ## Taken from whisper_protocol.nim, in types.go these are the same
#     ## What is on the wire
#     ## XXX: Do we actually want all these fields?
#     expiry*: uint32 ## Unix timestamp when message expires
#     ttl*: uint32 ## Time-to-live, seconds - message was created at (expiry - ttl)
#     topic*: Topic
#     data*: Bytes ## Payload, as given by user
#     nonce*: uint64 ## Nonce used for proof-of-work calculation

#   # Corresponds to types.go PssMsg
#   PssMsg* = object
#     dst*: array[4, byte] # Size?
#     control*: array[4, byte] # What is this? Also size
#     expire*: uint32
#     payload*: Envelope # whisper.Envelope (?) / Bytes

# proc encode*(self: Payload): Option[Bytes] =
#   ## XXX: Mocking encode method
#   ## Encode a payload according so as to make it suitable to put in an Envelope
#   echo "encode payload len ", self.payload.len

#   # assume base64

#   # Base64, just for testing
#   let naiveEncode = self.payload.encode()

#   #  totalLen = dataLen + padLen
#   let totalLen = len(naiveEncode)
#   var plain = newSeqOfCap[byte](totalLen)
#   plain.add(naiveEncode)

#   return some(plain)

# proc decode*(data: openarray[byte]): Option[DecodedPayload] =
#   ## Decode data into payload, potentially decrypting
#   ## Should assume malformated data
#   var res: DecodedPayload
#   var plain: Bytes

#   echo " decode 1"
#   # Wtf
# #  echo "  decoded", data.decode()

#   echo " decode 2"
#   plain = @data
#   echo " decode 3"

#   return some(res)



# # Look into connectivity later
