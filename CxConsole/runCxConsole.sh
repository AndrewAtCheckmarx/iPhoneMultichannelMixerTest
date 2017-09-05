#!/bin/bash
pushd  "`dirname \"$0\"`"
java -Xmx1024m -cp :./config/cx_console.properties -jar CxConsolePlugin-CLI-8.42.0-20170704-1528.jar "$@"
popd
