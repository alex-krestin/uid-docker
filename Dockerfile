FROM java:8-jdk

MAINTAINER Krestin Oleksandr <alex.krestin@gmail.com>

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre
ENV HBASE_VERSION 1.1.0.1

RUN wget --quiet -O - http://archive.apache.org/dist/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz | tar --directory /usr/local -xzf -
RUN ln -s /usr/local/hbase-$HBASE_VERSION /usr/local/hbase

ENV PATH $PATH:/usr/local/hbase/bin

## create the data folder
RUN mkdir /hbase-data

ADD start.sh /usr/local/hbase/start-tail.sh
RUN ["chmod", "+x", "/usr/local/hbase/start-tail.sh"]
ADD ./hbase-site.xml /usr/local/hbase/conf/

RUN sed -i.bak -r 's/=(INFO|DEBUG)/=WARN/' /usr/local/hbase/conf/log4j.properties

# Zookeeper
EXPOSE 2181
# HBase Master API port
EXPOSE 60000
# HBase Master Web UI
EXPOSE 60010
# Regionserver API port
EXPOSE 60020
# HBase Regionserver web UI
EXPOSE 60030
# Spring-Boot
EXPOSE 8080

#USER root

RUN echo 'update and install maven'
RUN apt-get update && apt-get --no-install-recommends install maven -y 
RUN git clone https://github.com/alex-krestin/url.id.git; 
RUN cd url.id/dist/; mvn package
RUN cd url.id/dist/target; mkdir uid; cp uid-1.0.jar uid/; cd ../; cp -avr public/ target/uid/; cp GeoLite2-Country.mmdb target/uid/;
RUN cp -avr url.id/dist/target/uid /; cd ../../; rm -rf url.id

CMD /usr/local/hbase/start-tail.sh