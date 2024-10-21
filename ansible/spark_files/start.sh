
rm -rf /tmp/hadoop*
ssh slave rm -rf /tmp/hadoop*

hdfs namenode -format

start-dfs.sh

start-master.sh
start-slaves.sh
hdfs dfsadmin -safemode leave
