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

require 'logger'
require 'net/ftp'
require 'optparse'
require 'pp'

log = Logger.new(STDOUT)
log.level = Logger::INFO

user = 'admin'
passwd = ''
host = ''
port = '41'
debug = false
passive = true

cards = ['0.0.0',
         '1.0.0',
         '2.0.0',
         '3.0.0',
         '4.0.0',
         '5.0.0',
         '6.0.0'
]

ftp = Net::FTP.new
if debug
  log.info("Enabling debug logging...")
  ftp.debug_mode=true
end
if passive
  log.info("Enabling passive mode...")
  ftp.passive=true
end
begin
  log.info("Connecting to host: #{host}:#{port}")
  ftp.connect host, port
rescue => err
  log.warn("#{err}")
  exit
else
  log.info("Connected...")
end
begin
  ftp.login user, passwd
rescue => err
  log.warn("#{err}")
  ftp.close
  log.info("Closed connection...")
  exit
else
  log.info("Login successful...")
end
log.info("Checking SPU type...")
begin
  ftp.chdir("0.4.0/logs")
rescue
  log.info("SPU Slot 0 is SPU2 type")
else
  log.info("SPU Slot 0 is SPU1 type")
end
begin
  ftp.chdir("1.4.0/logs")
rescue
  log.info("SPU Slot 1 is SPU2 type")
else
  log.info("SPU Slot 1 is SPU1 type")
end
log.info("Checking cards...")
cards.each do |card|
  begin
    ftp.chdir("/#{card}/logs")
  rescue
    log.info("Card: #{card}: not present!")
  else
    log.info("Card: #{card}: OK!")
  end
end
log.info("Closed connection...") if ftp.close
log.close
