package main

import (
    "os"
    "net"
    "fmt"
    "flag"
    "strings"
)

var buf [4096]byte

var address = flag.String("a", "", "Set the listen ip address")
var port = flag.String("p", "2500", "Set the listen port (default 2500)")
var siplogonly = flag.Bool("siplog", false, "If true will filter sipmsg.log messages only")
var local = ""
var searchfor = ""

var Usage = func() {
    fmt.Fprintf(os.Stderr, "Usage of %s:\n", os.Args[0])
    flag.PrintDefaults()
    fmt.Printf("hi")
    os.Exit(1)
}

func parseMessage(data string, addr net.Addr) {
    // splits the log message
    //   d[0] = logname@cpu/core
    //   d[1] = the log message
    var d = strings.Split(data, ":", 2)

    // splits the logname and cpu/core
    //  f[0] = logfile name
    //  f[1] = the cpu/core
    var f = strings.Split(d[0], "@", 2)

    // handles siplog flag
    if *siplogonly {
      if strings.Contains(d[0], "sipmsg.log") {
        if len(searchfor) > 0 {
          if strings.Contains(data, searchfor) {
            fmt.Printf("From: %v, Log: %v, Cpu/Core: %v\n", addr, f[0], f[1])
            fmt.Printf("%v\n", strings.TrimSpace(d[1]))
          }
        } else {
          fmt.Printf("From: %v, Log: %v, Cpu/Core: %v\n", addr, f[0], f[1])
          fmt.Printf("%v\n", strings.TrimSpace(d[1]))
        }
      }
    } else {
      if len(searchfor) > 0 {
        if strings.Contains(data, searchfor) {
          fmt.Printf("%v: %v\n", addr, string(data))
        }
      } else {
        fmt.Printf("%v: %v\n", addr, string(data))
      }
    }
}

func main() {
  flag.Parse()
  if flag.NArg() == 1 {
    searchfor = flag.Arg(0)
  }

  if flag.NArg() > 1 {
      fmt.Printf("Too many arguments, only 1 search arg is supported at this time.\n")
      os.Exit(1)
  }

  if len(*address) > 0 {
    l := net.ParseIP(*address).To4()
    if l == nil {
      fmt.Printf("Invalid IPv4 Address: %v\n", *address)
      os.Exit(1)
    }
    local = l.String()
  }

  laddr := local + ":" + *port
  c, err := net.ListenPacket("udp", laddr )
  if err != nil {
    fmt.Printf("Cannot bind...%v\nError: %s\n", laddr, err)
    os.Exit(1)
  }
  fmt.Printf("Listening on: %v\n", c.LocalAddr())

  for {
    nr, addr, err := c.ReadFrom(buf[0:])
    if err != nil {
      panic(err.String())
    }
    data := buf[0:nr]
    parseMessage(string(data), addr)
  }

}
