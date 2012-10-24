#!/bin/sh

export GEM_PATH="gems"
export GEM_HOME="gems"
export JRUBY_COMPLETE="jar/jruby-complete-1.7.0.jar"
export JRUBY="java -Xmx500m -Xss1024k -jar ${JRUBY_COMPLETE}"
