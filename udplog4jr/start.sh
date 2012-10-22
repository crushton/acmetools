#!/bin/sh

unset GEM_PATH
unset GEM_HOME

java -Xms64m -Xmx256m -jar "./jruby-custom-1.7.0.jar" udplog4jr.rb $*
