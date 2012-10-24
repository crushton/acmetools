@echo off

set GEM_PATH="gems"
set GEM_HOME="gems"
set JRUBY_COMPLETE="jar/jruby-complete-1.7.0.jar"
set JRUBY="java -Xmx500m -Xss1024k -jar %JRUBY_COMPLETE%"

set SCRIPT="ruby/9200collect4jr.rb"

%JRUBY% %SCRIPT% $1 $2 $3 $4 $5 $6 $7 $8 $9
