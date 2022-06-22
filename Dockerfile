FROM ubuntu:18.04

# apt 설치시 입력요청 무시
ENV DEBIAN_FRONTEND=noninteractive

# apt 미러서버 미국(default) -> 한국 변경
# RUN sed -i 's@archive.ubuntu.com@kr.archive.ubuntu.com@g' /etc/apt/sources.list

# 자주 사용하는 패키지 설치
RUN apt-get clean && \
    apt-get update && \
    apt-get install net-tools -y && \
    apt-get install vim -y && \
    apt-get install wget -y    

# version
ENV SPARK_VERSION 3.2.1
ENV HADOOP_VERSION 3.2
ENV PYTHON_VERSION 3.8
ENV ZEPPELIN_VERSION 0.10.1
# install java
RUN apt-get install openjdk-8-jdk -y

# install spark-3.2.1-bin-hadoop3.2
RUN wget https://dlcdn.apache.org/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz --no-check-certificate && \
    tar -xvf spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz && \
    mv spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION /home/spark && \
    rm -rf spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz

# python 3.8.0
RUN apt-get install python$PYTHON_VERSION -y && \
    apt-get install python3-pip -y && \
    rm -rf /usr/bin/python3 && \
    ln -s /usr/bin/python$PYTHON_VERSION /usr/bin/python3 && \
    ln -s /usr/bin/python$PYTHON_VERSION /usr/bin/python

# zeppelin-0.10.1
RUN wget https://dlcdn.apache.org/zeppelin/zeppelin-$ZEPPELIN_VERSION/zeppelin-$ZEPPELIN_VERSION-bin-all.tgz --no-check-certificate && \
    tar -zxf zeppelin-$ZEPPELIN_VERSION-bin-all.tgz && \
    mv zeppelin-$ZEPPELIN_VERSION-bin-all /home/zeppelin && \
    rm -rf zeppelin-$ZEPPELIN_VERSION-bin-all.tgz

# pip3 설정
RUN mkdir /root/.pip && \
    set -x \
    && { \
    echo '[global]'; \
    echo 'timeout = 60'; \
    echo '[freeze]'; \
    echo 'timeout = 10'; \
    echo '[list]'; \
    echo 'format = columns'; \
    } > /root/.pip/pip.conf && \
    pip3 install --upgrade pip

# 환경변수 설정
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV SPARK_HOME /home/spark
ENV ZEPPELIN_HOME /home/zeppelin
ENV PATH $PATH:$JAVA_HOME/bin:$SPARK_HOME/bin:$ZEPPELIN_HOME/bin

# spark 설정파일 수정
COPY ./log4j.properties /home/spark/conf/log4j.properties

RUN rm -rf /home/spark/conf/log4j.properties.template && \
    rm -rf /home/spark/bin/*.cmd

# zeppelin 설정파일 수정
RUN rm -rf /home/zeppelin/bin/*.cmd && \
    rm -rf /home/zeppelin/notebook && \
    mkdir /home/zeppelin/notebook

# pyspark 설치시 self signed certificate in certificate chain error 떄문에... 
RUN python -m pip install --upgrade pip --trusted-host pypi.python.org --trusted-host files.pythonhosted.org --trusted-host pypi.org
RUN pip3 install pyspark

# 컨테이너 실행시 spark 자동실행
COPY ./entrypoint.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]