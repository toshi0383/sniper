#!/bin/bash
command="./bin/sniper"

function test() {
    com="$1"
    expected=$2
    echo "Testing \`$com\`"
    $com
    if [ $? -ne ${expected} ];then
        echo $3
        echo "command: $com"
        exit 1
    fi
    echo
}
test "$command target" 0 "target should success"
test "$command shoot" 1 "shoot should fail"
test "$command shoot helloworld" 1 "shoot should fail"
test "$command shoot -b helloworld" 1 "shoot should fail"
test "$command shoot -p helloworld" 1 "shoot should fail"

# FIXME: shell process is not mac app process, so it doesn't show up as NSRunningApplication
#
#sleep 100 &
#pid=`ps | grep sleep\ 100 | grep -v grep | awk '{print $1}'`
#$command shoot -p $pid
#test 0 "shoot should success"
#
#$command shoot -b $bundleID
#test 0 "shoot should success"

