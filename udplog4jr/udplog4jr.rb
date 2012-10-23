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
  opts.on_tail( '-h', '--help', 'Show this message' ) do
    puts optparse
    exit
  end
  $sipmsg = false
  opts.on( '-s', '--sipmsg', 'Filter sipmsg.log only' ) do
    $sipmsg = true
  end
  $disable_options = false
  opts.on( '-o', '--disable-options', 'Remove OPTIONS from being displayed' ) do
    $disable_options = true
  end
end
optparse.parse(ARGV)

if ( ($disable_options == true) and ($sipmsg == false) )
  puts "ERROR: -o can only be used with -s"
  exit
end

if $sipmsg == true
  puts "Filtering sipmsg.log files only..."
end
if $disable_options == true 
  puts "Filtering out all SIP OPTIONS methods..."
end

class PacketHandler < EM::Connection

  def receive_data(data)
    if $sipmsg
       if /sipmsg/.match(data)
         if ( $disable_options && /CSeq:.*OPTIONS/i.match(data) )
           return
         end
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
