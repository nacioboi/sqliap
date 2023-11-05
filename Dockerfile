FROM mysql:latest

ENV MYSQL_ROOT_PASSWORD=passwd
ENV MYSQL_DATABASE=mydb
ENV MYSQL_USER=user
ENV MYSQL_PASSWORD=passwd

ADD mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

RUN mkdir -p /usr/var/http/myhttp
COPY node-latest-linux.tar.gz /usr/var/http/myhttp

RUN cd /usr/var/http/myhttp && tar -xzvf node-latest-linux.tar.gz
# the extracted folder has the version number in its name
RUN cd /usr/var/http/myhttp && mv node-v* node-latest-linux
RUN cd /usr/var/http/myhttp && cd node-latest-linux && cp -R * /usr/local/
RUN cd /usr/var/http/myhttp && rm -rf node*

COPY ./http /usr/var/http/myhttp
RUN chmod +x /usr/var/http/myhttp/.container_initializer.sh

COPY ./http/node_modules /usr/var/http/myhttp/node_modules

EXPOSE 3306
EXPOSE 3000

CMD ["/usr/var/http/myhttp/.container_initializer.sh"]

