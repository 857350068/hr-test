#!/usr/bin/env bash
set -e

export HADOOP_HOME=/data/hadoop
export HADOOP_PREFIX=/data/hadoop
export HIVE_HOME=/opt/hive
export JAVA_HOME=/opt/jdk1.8
export PATH="${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${HIVE_HOME}/bin:${PATH}"

pkill -f "org.apache.hive.service.server.HiveServer2" >/dev/null 2>&1 || true
nohup /opt/hive/bin/hive --service hiveserver2 > /tmp/hiveserver2.log 2>&1 &
sleep 3
echo "HiveServer2 started by hadoop user."
