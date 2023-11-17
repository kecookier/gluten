#!/bin/bash

if [ -d /opt/meituan/spark-3.0-vec/jars/ ]; then
    cd /opt/meituan/spark-3.0-vec/jars/
    rm gluten-package*SNAPSHOT.jar
    cp /opt/meituan/gluten/target/gluten-package*SNAPSHOT.jar /opt/meituan/spark-3.0-vec/jars/
    ls -l |grep gluten-package*
else
    echo "Dir /opt/meituan/spark-3.0-vec/jars/ is not exist, just continue"
fi
