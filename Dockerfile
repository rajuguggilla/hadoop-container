FROM centos:7
MAINTAINER raju <guggillaraju@gmail.com>

USER root

## install java and other dependencies
RUN yum -y update && yum clean all 
RUN yum -y install epel-release && yum clean all
RUN yum -y install wget vim && yum clean all
RUN yum -y install java-1.7.0-openjdk java-1.7.0-openjdk-devel && yum clean all
RUN yum -y install openssh-server openssh-clients && yum clean all

RUN yum update -y libselinux

# passwordless ssh
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN echo -e  'y\n'|ssh-keygen -q -t rsa -N "" -f ~/.ssh/id_rsa
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
 
ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

ADD hadoop-2.7.4 /opt/hadoop-2.7.4/

## ENV 
ENV JAVA_HOME /usr/lib/jvm/java-1.7.0-openjdk
ENV HADOOP_HOME /opt/hadoop-2.7.4 
ENV PATH $PATH:$HADOOP_HOME/bin
ENV PATH $PATH:$HADOOP_HOME/sbin

###
RUN echo "  " >> /root/.bashrc
RUN echo "##### JAVA ENV Variable #####" >> /root/.bashrc
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk" >> /root/.bashrc
RUN echo "  " >> /root/.bashrc
RUN echo "##### HADOOP ENV Variable #####" >> /root/.bashrc
RUN echo "export HADOOP_HOME=/opt/hadoop-2.7.4" >> /root/.bashrc
RUN echo "export PATH=$PATH:$HADOOP_HOME/bin" >> /root/.bashrc
RUN echo "export PATH=$PATH:$HADOOP_HOME/sbin" >> /root/.bashrc
RUN exec bash
RUN source ~/.bashrc

#######
RUN sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config
RUN echo "UsePAM no" >> /etc/ssh/sshd_config
RUN echo "Port 2122" >> /etc/ssh/sshd_config

RUN /etc/init.d/sshd start

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 10020 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#ssh port
EXPOSE 2122
