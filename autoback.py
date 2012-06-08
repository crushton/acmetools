#!/usr/bin/env python
###
# Copyright (c) 2012, Chris Rushton
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
##
import pexpect
import os
import sys
import subprocess
from re import search
from datetime import datetime

## Enable or disable for production or lab only [0,1]
labonly = 0

## Sets the time for log files and output
t = datetime.now()
#logdate = datetime.now().strftime("%m%d%y%I%M%S")
filedate = t.strftime("%m%d%y%I%M")

backup_location = 'backups'
config_location = 'configs'
log_location = 'logs'

PROMPT = '[#>] '

def logtype(child):
    logtype = file
    if logtype == file:
      fout = open ("./" + log_location + "/expectout.log","a")
      child.logfile = fout
    else:
      child.logfile = sys.stdout
    return child

def logscreen(input):
    logdate = datetime.now().strftime("%m%d%y%I%M%S")
    print logdate + ": " + input

def create_dirs():
    dirs = [backup_location,config_location,log_location]
    for location in dirs:
        if not os.path.isdir('./' + location + '/'):
            os.mkdir( './' + location + '/')
            logscreen('WARNING: Directory does not exist, created "' + location + '"')

def login_telnet(hostname, password):
    child = pexpect.spawn('telnet %s'%(hostname))
    logtype(child)
    i = child.expect([pexpect.TIMEOUT, pexpect.EOF,'[Pp]assword:'])
    if i == 0: # Timeout
        logscreen('ERROR: TELNET is expecting password prompt, but did not receive it before timeout. Here is what TELNET said: ')
        print child.before, child.after
        return
    if i == 1: # EOF
        logscreen('ERROR')
        print child.before, child.after
        return
    child.sendline(password)
    i = child.expect (['Login failed', PROMPT])
    if i == 0:
        logscreen('ERROR: Permission denied incorrect username/password on host: ' + hostname)
        print child.before, child.after
        child.close(force=True)
        return
    logscreen('Telnet logged in successfully to ' + hostname)
    return child

def logout_telnet(child):
        child.sendline('exit')
        child.expect(PROMPT)
        child.sendline('exit')
        child.close(force=True)
        logscreen('Telnet logged out successfully')
        return

def become_root(child,root_password):
    child.sendline('en')
    i = child.expect([pexpect.TIMEOUT, pexpect.EOF,'[Pp]assword:'])
    child.sendline(root_password)
    child.expect(PROMPT)
    return child

def login_ftp(hostname,password):
    child = pexpect.spawn('ftp %s'%(hostname))
    logtype(child)
    i = child.expect([pexpect.TIMEOUT, 'Name'])
    if i == 0: # Timeout
        print 'ERROR!'
        print 'FTP is expecting username prompt, but did not receive it before timeout. Here is what FTP said:'
        print child.before, child.after
        sys.exit (1)
    child.sendline('user')
    i = child.expect([pexpect.TIMEOUT, '[Pp]assword:'])
    if i == 0: # Timeout
        print 'ERROR!'
        print 'FTP is expecting password prompt, but did not receive it before timeout. Here is what FTP said:'
        print child.before, child.after
        sys.exit (1)
    child.sendline(password)
    i = child.expect ([pexpect.TIMEOUT,'530 Login failed', PROMPT])
    if i == 0: # Timeout
        print 'ERROR!'
        print 'FTP is expecting prompt after successful username and password, but did not receive it before timeout. Here is what FTP said:'
        print child.before, child.after
        sys.exit (1)
    if i == 1: # Incorrect Username/Password Combo
        print 'ERROR!'
        print 'FTP is unable to login due to an incorrect username/password combo. Here is what FTP said:'
        print child.before, child.after
        sys.exit (1)
    logscreen('FTP logged in successfully to ' + hostname)
    return child

def logout_ftp(child):
    child.expect(PROMPT)
    child.sendline('bye')
    child.close(force=True)
    logscreen('FTP logged out successfully')
    return

def showconfig_tofile(child,config_name):
    child.sendline('show config to-file %s'%(config_name))
    logscreen('Config was successfully saved: ' + config_name)
    child.expect(PROMPT)
    return child

def savebackup(child,backup_name):
    child.sendline('backup-config %s'%(backup_name))
    logscreen('Config was successfully backed up: ' + backup_name + '.gz')
    child.expect(PROMPT)
    return child

def cleanbackup(child,backup_name):
    i = child.sendline('show backup-config')
    child.expect([pexpect.TIMEOUT, PROMPT])
    files = child.before.split('\n')
    for file in files:
        file = file.strip('\r')
        if (search('auto-?config',file) or search('auto-?backup',file)) and not search(filedate,file):
            child.sendline('delete-backup-config %s'%(file))
            i = child.expect ([pexpect.TIMEOUT, PROMPT])
            if i == 0: # Timeout
                print 'ERROR!'
                print 'FTP is trying to download config file but it is taking too long Here is what FTP said:'
                print child.before, child.after
                sys.exit (1)
            logscreen('Old config file successfully deleted: ' + file)
    return child

def show_health(child):
    child.sendline('show health')

def show_uptime(child):
    child.sendline('show uptime')

def ftp_list(child):
    child.sendline('ls')

def ftp_getconfig(child,config_name):
    child.sendline('cd /ramdrv/logs')
    i = child.expect ([pexpect.TIMEOUT, PROMPT])
    logscreen('FTP starting transfer of ' + config_name + '...')
    child.sendline('get %s ./%s/%s'%(config_name,config_location,config_name))
    i = child.expect ([pexpect.TIMEOUT, '226 Transfer complete'],timeout=120)
    if i == 0: # Timeout
        print 'ERROR!'
        print 'FTP is trying to download config file but it is taking too long Here is what FTP said:'
        print child.before, child.after
        sys.exit (1)
    logscreen('FTP successfully copied file ' + config_name)
    return child

def ftp_deleteoldconfigs(child,config_name):
    child.sendline('cd /ramdrv/logs')
    i = child.expect ([pexpect.TIMEOUT, PROMPT])
    child.sendline('ls')
    i = child.expect ([pexpect.TIMEOUT, '226 Transfer complete'])
    files = child.before.split('\n')
    for file in files:
        file = file.strip('\r')
        if search('autoconfig',file) and file != config_name:
            #print repr(file)
            child.sendline('del %s'%(file))
            i = child.expect ([pexpect.TIMEOUT, '250 DELE command successful'])
            if i == 0: # Timeout
                print 'ERROR!'
                print 'FTP is trying to download config file but it is taking too long Here is what FTP said:'
                print child.before, child.after
                sys.exit (1)
            logscreen('Old config was successfully deleted ' + file)
    return child

def ftp_getbackup(child,backup_name):
    backup_name = backup_name + '.gz'
    child.sendline('cd /code/bkups')
    i = child.expect ([pexpect.TIMEOUT, PROMPT])
    logscreen('FTP starting transfer of ' + backup_name + '...')
    child.sendline('get %s ./%s/%s'%(backup_name,backup_location,backup_name))
    i = child.expect ([pexpect.TIMEOUT, '226 Transfer complete'],timeout=120)
    if i == 0: # Timeout
        print 'ERROR!'
        print 'FTP is trying to download config file but it is taking too long Here is what FTP said:'
        print child.before, child.after
        sys.exit (1)
    logscreen('FTP successfully copied file ' + backup_name)
    return child

def main():

    create_dirs()

    for server in set_servers():
        name = server[0]
        hostname = server[1]
        hostname_backup = server[2]
        password = server[3]
        root_password = server[4]
        config_name = filedate + '-autoconfig-' + name + '.txt'
        backup_name = filedate + '-autoconfig-' + name
        logscreen('============== ' + name + ': ' + hostname + ' ==============')
        child = login_telnet(hostname, password)
        if child == None:
            logscreen('ERROR: Unable to login to first host, trying backup host!!!')
            logscreen('============== ' + name + ': ' + hostname_backup + ' ==============')
            child = login_telnet(hostname_backup, password)
            if child == None:
              logscreen('')
              continue
            hostname = hostname_backup
        #show_health(child)
        #show_uptime(child)
        become_root(child,root_password)
        showconfig_tofile(child,config_name)
        savebackup(child,backup_name)
        cleanbackup(child,backup_name + '.gz')
        logout_telnet(child)
        child = login_ftp(hostname,password)
        if child == None:
            logscreen('ERROR: Unable to login with ftp to host: ' + hostname)
            continue
        ftp_getconfig(child,config_name)
        ftp_getbackup(child,backup_name)
        ftp_deleteoldconfigs(child,config_name)
        logout_ftp(child)
        logscreen('')

def set_servers():
    if labonly :
        servers = [
            ## Lab Sbc's
            #('name','hostname_a','hostname_b','user_pass','enable_pass'),
            ]
    else:
        servers = [
            ## Production Sbc's
            #('name','hostname_a','hostname_b','user_pass','enable_pass'),
            ]
    return servers

if __name__ == '__main__':
    try:
        main()
    except pexpect.ExceptionPexpect, e:
        print str(e)
