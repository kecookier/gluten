#!/bin/bash

cd /opt/meituan/spark-3.0-vec/jars/
rm gluten-package*SNAPSHOT.jar
cp /opt/meituan/gluten-1.1.0/gluten-package*SNAPSHOT.jar /opt/meituan/spark-3.0-vec/jars/
ls -l |grep gluten-package*
