          # Java
          export JAVA_HOME=/home/ubuntu/install/jdk1.8.0_202
          export PATH=$JAVA_HOME/bin:$PATH

          # Hadoop
          export HADOOP_HOME=/home/ubuntu/install/hadoop-2.7.1
          export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

          # Spark
          export SPARK_HOME=/home/ubuntu/install/spark-2.4.3-bin-hadoop2.7
          export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
          #echo "BRUHHH MOMENTO"
          export TEST="IT WORKS"