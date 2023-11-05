FROM mysql:latest

# configure mysql environment.
ENV MYSQL_ROOT_PASSWORD=passwd
ENV MYSQL_DATABASE=mydb
ENV MYSQL_USER=user
ENV MYSQL_PASSWORD=passwd
ADD mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

# prepare for installations.
RUN mkdir -p /usr/var/http/myhttp
COPY node-latest-linux.tar.gz /usr/var/http/myhttp
COPY make-latest-linux.tar.gz /usr/var/http/myhttp

# git and make are vital utilities for installing any other linux packages.
# since we do not have a package manager, we need to install them manually.
# we run into a problem when building them from source inside the container,
# git needs make to install and make needs git to isntall.
# we face a chicken and egg problem.
COPY ./make-install-dir/* /usr/local/
COPY ./git-install-dir/* /usr/local/

# install nodejs.
RUN cd /usr/var/http/myhttp && tar -xzvf node-latest-linux.tar.gz
RUN cd /usr/var/http/myhttp && mv node-v* node-latest-linux
RUN cd /usr/var/http/myhttp && cd node-latest-linux && cp -R * /usr/local/
RUN cd /usr/var/http/myhttp && rm -rf node*

# install make.
RUN cd /usr/var/http/myhttp && tar -xzvf make-latest-linux.tar.gz
RUN cd /usr/var/http/myhttp && rm make-latest-linux.tar.gz
RUN cd /usr/var/http/myhttp && mv make-* make-latest-linux
RUN cd /usr/var/http/myhttp/make-latest-linux && ./configure
RUN cd /usr/var/http/myhttp/make-latest-linux && make
RUN cd /usr/var/http/myhttp/make-latest-linux && make install
RUN cd /usr/var/http/myhttp && rm -rf make*

# copy project files.
COPY ./http /usr/var/http/myhttp
RUN chmod +x /usr/var/http/myhttp/.container_initializer.sh
COPY ./http/node_modules /usr/var/http/myhttp/node_modules

# expose ports.
EXPOSE 3306
EXPOSE 3000

# run initializer.
CMD ["/usr/var/http/myhttp/.container_initializer.sh"]

