#!/usr/bin/env bash
set -euo pipefail

cp /tmp/mapred-site.xml /data/hadoop/etc/hadoop/mapred-site.xml

for host in bigdata2 bigdata3; do
  su -s /bin/bash -c "scp -o StrictHostKeyChecking=no /tmp/mapred-site.xml ${host}:/tmp/mapred-site.xml" hadoop
  su -s /bin/bash -c "ssh -o StrictHostKeyChecking=no ${host} 'cp /tmp/mapred-site.xml /data/hadoop/etc/hadoop/mapred-site.xml'" hadoop
done

echo "mapred-site.xml distributed to bigdata1/2/3"
