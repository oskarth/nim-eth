import eth/rlp, nimcrypto/hash

# XXX: Errors when running standalone
#import whisper_protocol as whisper
#
# > nim c eth/p2p/rlpx_protocols/whisper_protocol.nim
# /home/oskarth/.nimble/pkgs/eth-1.0.0/eth/p2p.nim(145, 17) Warning: random is deprecated [Deprecated]
# ../ecies.nim(1, 2) Error: module names need to be unique per Nimble package; module clashes with /home/oskarth/.nimble/pkgs/eth-1.0.0/eth/p2p/ecies.nim


# https://github.com/ethersphere/swarm/tree/master/pss

echo "hello pss"

#cool

# Core concepts
# 1. Encryption key - type?
# 2. Topic - type?
# 3. Message payload

type
  Hash* = MDigest[256]
  SymKey* = array[256 div 8, byte] ## AES256 key, 8 bits
  Topic* = array[4, byte]

  Envelope* = object
   
  PssMsg* = object
    dst*: array[4, byte] # Size?
    control*: array[4, byte] # What is this? Also size
    expire*: uint32
    payload*: Envelope # whisper.Envelope / Bytes