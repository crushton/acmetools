#!/bin/sh

. setEnv.sh

SCRIPT="ruby/udplog4jr.rb"

${JRUBY} ${SCRIPT} $*
