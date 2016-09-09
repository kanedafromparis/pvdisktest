FROM centos:7
MAINTAINER "Charles Sabourdin" <kanedafromparis@gmail.com>
LABEL version="1.0"
ENV AUTHUSER toto@gmail.com
ENV AUTHPASS notinthebuildsilly
ENV DESTMAIL toto-again@gmail.com
ENV FILE_PATH /home/sysbench

RUN (rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
yum install mailx ssmtp contabs sysbench -y ); 

ADD ssmtp.conf /etc/ssmtp/ssmtp.conf
RUN chmod -R a+rwX /etc/ssmtp
ADD sysbench.sh /usr/local/bin/sysbench.sh

ADD crontask.sh /etc/cron.d/2sysbench
RUN chmod 0644 /etc/cron.d/2sysbench
RUN chmod a+x /usr/local/bin/sysbench.sh
RUN useradd -ms /bin/bash sysbench
USER sysbench
WORKDIR /home/sysbench
CMD ["/usr/local/bin/sysbench.sh"] 