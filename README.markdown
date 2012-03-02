# Acme Tools

My place to put scripts and things related to lazy administration of acme packet gear.
I started learning most of the languages here, so they may not be
pretty.

- **9200collect.pl**: collects log files from 9200, differentiates between
  SPU1/NPU1, and SPU2/NPU2
- **clean4k.pl**: cleans rotated log files out from C series
- **collect4k.pl**: collects logs files on C series to local directory
- **convert262.pl**: converts xml of a C series config < C620 to compatible
  C620+ format
- **monitor4250.sh**: simple snmp monitoring script for C series
- **monitor9200.sh**: simple snmp monitoring script for D series

- **udplog**: a udp logger on port 2600 for receiving and filtering udp
  transmitted logs from the sbc, you can put in a specific string to
  filter on and it will only display those lines. Written in Google Go

- **autoback.py**: auto backup script for c series, this was made to run as
  a cron every day and it will login, create a backup config, and save a
  copy of the show config to a file. It would then ftp those files to your
  local machine for keeping track of changes daily. This uses the python
  pexpect module.

License
-------

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
