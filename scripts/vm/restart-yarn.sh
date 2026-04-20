#!/usr/bin/env bash
set -e

export HADOOP_HOME=/data/hadoop
export HADOOP_PREFIX=/data/hadoop
export JAVA_HOME=/opt/jdk1.8
export PATH="${JAVA_HOME}/bin:${HADOOP_HOME}/sbin:${HADOOP_HOME}/bin:${PATH}"

/data/hadoop/sbin/stop-yarn.sh || true
sleep 4
/data/hadoop/sbin/start-yarn.sh

echo "YARN restarted."
