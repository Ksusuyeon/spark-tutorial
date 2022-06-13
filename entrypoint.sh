#!/bin/bash
sleep 1

# 스파크 마스터 실행
if [ ${SPARK_MODE} == "master" ]; then
    # bash $SPARK_HOME/sbin/start-master.sh
    $SPARK_HOME/bin/spark-class org.apache.spark.deploy.master.Master >> logs/spark-master.out
fi

sleep 1
# 스파크 슬레이브 실행
if [ ${SPARK_MODE} == "worker" ]; then
    # bash $SPARK_HOME/sbin/start-worker.sh spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT} 
    $SPARK_HOME/bin/spark-class org.apache.spark.deploy.worker.Worker spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT} >> logs/spark-worker.out
fi

sleep 1

# 제플린 실행
if [ ${SPARK_MODE} == "zeppelin" ]; then
    bash /home/zeppelin/bin/zeppelin-daemon.sh start
fi

sleep 1

bash