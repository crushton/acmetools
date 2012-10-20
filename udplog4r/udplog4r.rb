#!/usr/bin/env ruby
###
## Copyright (c) 2012, Chris Rushton
##
## Permission to use, copy, modify, and distribute this software for any
## purpose with or without fee is hereby granted, provided that the above
## copyright notice and this permission notice appear in all copies.
##
## THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
## WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
## MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
## ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
## WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
## ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
## OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
###

require 'eventmachine'
require 'optparse'
require 'pp'

addr = '0.0.0.0'
port = 2600


optparse = OptionParser.new do|opts|
  opts.banner = "Usage: udplog4r.rb [options]"
  $sipmsg = false
  opts.on( '-s', '--sipmsg', 'Filter sipmsg.log only' ) do
    puts "Enabling sipmsg.log only..."
    $sipmsg = true
  end
  $disable_options = false
  opts.on( '-o', '--disable-options', 'Remove OPTIONS from being displayed' ) do
    puts "Enabling filtering of OPTIONS messages..."
    $disable_options = true
  end
end
optparse.parse(ARGV)

class PacketHandler < EM::Connection

  def receive_data(data)
    if /CSeq:.*OPTIONS/i.match(data)
      return
    end
    if $sipmsg
       if /sipmsg/.match(data)
         puts data
       end
    else
      puts data
    end
  end

end

EM.run {
    EM.open_datagram_socket addr, port, PacketHandler
    printf "Running on %s:%s...\n", addr, port
    #EM.add_periodic_timer(1) { puts }
}
