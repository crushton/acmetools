#!/bin/sh

. setEnv.sh

SCRIPT="ruby/9200collect4jr.rb"

${JRUBY} ${SCRIPT} $*
