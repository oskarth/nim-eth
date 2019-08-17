package main

import (
	"fmt"
	"os"
	"os/signal"
	"strconv"

	"github.com/ethereum/go-ethereum/log"
	"github.com/ethereum/go-ethereum/node"
	"github.com/ethereum/go-ethereum/p2p"
	"github.com/ethereum/go-ethereum/rlp"
	"github.com/ethereum/go-ethereum/rpc"
)

type SimpleMessage struct {
	Version uint
}

func (s SimpleMessage) String() string {
	return fmt.Sprintf("Version: %d", s.Version)
}

var (
	SimpleProtocol = p2p.Protocol{
		Name:    "smp",
		Version: 1,
		Length:  1,
		Run: func(p *p2p.Peer, rw p2p.MsgReadWriter) error {
			for {
				msg, err := rw.ReadMsg()
				if err != nil {
					return err
				}
				var simpleMsg SimpleMessage
				log.Debug("raw msg received", "obj", msg, "payload", msg.Payload)
				err = msg.Decode(&simpleMsg)
				if err != nil {
					return err
				}
				log.Debug("msg cast", "content", msg)
			}
			return nil
		},
	}
)

type Simple struct {
}

func (s *Simple) Start(srv *p2p.Server) error {
	log.Info("Starting Simple service")
	return nil
}

func (s *Simple) Stop() error {
	log.Info("Stopping Simple service")
	return nil
}

func (s *Simple) Protocols() []p2p.Protocol {
	return []p2p.Protocol{SimpleProtocol}
}

func (s *Simple) APIs() []rpc.API {
	return []rpc.API{}
}

func init() {
	hs := log.StreamHandler(os.Stderr, log.TerminalFormat(true))
	hf := log.LvlFilterHandler(log.Lvl(5), hs)
	h := log.CallerFileHandler(hf)
	log.Root().SetHandler(h)
}

func main() {

	var expectId uint
	if len(os.Args) > 1 {
		n, err := strconv.ParseInt(os.Args[1], 10, 64)
		if err != nil {
			panic(err)
		}
		expectId = uint(n)
	} else {
		expectId = 42
	}
	cfg := &node.DefaultConfig
	cfg.P2P.NoDiscovery = true
	stack, err := node.New(cfg)
	if err != nil {
		panic(err)
	}
	err = stack.Register(func(_ *node.ServiceContext) (node.Service, error) {
		return &Simple{}, nil
	})
	if err != nil {
		panic(err)
	}
	var refMessage = SimpleMessage{
		Version: expectId,
	}
	rlpMsg, err := rlp.EncodeToBytes(refMessage)
	if err != nil {
		panic(err)
	}
	log.Debug("reference serialization", "msg", rlpMsg)
	ch := make(chan os.Signal)
	signal.Notify(ch, os.Interrupt)
	stack.Start()
	<-ch
	stack.Stop()
}
