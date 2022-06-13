FROM centos:7

RUN yum update -y
RUN yum install -y \
    gcc \
    openssl-devel \
    bzip2-devel \
    libffi-devel \
    epel-release \
    python3-pip \
    wget \
    make \
    java-1.8.0-openjdk-devel.x86_64

ENV SPARK_VERSION=3.2.1
ENV HADOOP_VERSION=3.2
ENV PYTHON_VERSION=3.8.2
ENV SPARK_URL=https://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz 
ENV PYTHON_URL=https://python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz

# install python 3.8
RUN wget "$PYTHON_URL" -O /tmp/python.tgz \
    && tar xzf  /tmp/python.tgz  -C /usr/local \
    && rm /tmp/python.tgz

# /bin/python을 python2 -> python3.8로 심볼릭 링크 변경
RUN rm -f /bin/python \
    && ln -s /usr/local/bin/python3.8 /bin/python

RUN /usr/local/Python-$PYTHON_VERSION/configure --enable-optimizations
RUN make altinstall

RUN wget "$SPARK_URL" -O /tmp/spark.tgz  \
    && tar -xf /tmp/spark.tgz -C /opt/ \
    && rm /tmp/spark.tgz

# 환경변수 설정
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk
ENV PATH $JAVA_HOME/bin/:$PATH
# ENV HADOOP_HOME /opt/hadoop
# ENV HADOOP_CONFIG_DIR /etc/hadoop
# ENV YARN_CONFIG_DIR /etc/hadoop
# ENV MAPRED_HOME /etc/hadoop
# ENV PATH $HADOOP_HOME/bin/:$PATH
# ENV PATH $HADOOP_HOME/sbin/:$PATH

ENV MAVEN_OPTS "-Xmx2g -XX:ReservedCodeCacheSize=512m"
ENV SPARK_HOME /opt/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION
ENV PYSPARK_PYTHON /usr/local/bin/python3.8
ENV PATH $SPARK_HOME/bin/:$PATH
ENV PATH $SPARK_HOME/sbin/:$PATH

# ENV JAVA_HOME `echo $JAVA_HOME`
# RUN $SPARK_HOME/build/mvn -DskipTests clean package
ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

VOLUME $SPARK_HOME/logs

ENTRYPOINT ["/entrypoint.sh"]