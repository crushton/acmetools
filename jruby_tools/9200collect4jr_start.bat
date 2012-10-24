@echo off

set GEM_PATH=gems
set GEM_HOME=gems

java -Xmx500m -Xss1024k -jar "jar\jruby-complete-1.7.0.jar" "ruby\9200collect4jr.rb" %1 %2 %3 %4 %5 %6 %7 %8 %9
