FROM mysql:latest

# configure mysql environment.
ENV MYSQL_ROOT_PASSWORD=passwd
ENV MYSQL_DATABASE=mydb
ENV MYSQL_USER=user
ENV MYSQL_PASSWORD=passwd
COPY mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

# prepare for installations.
RUN mkdir -p /usr/var/http/myhttp
COPY /junk/node-latest-linux.tar.gz /usr/var/http/myhttp

# git and make are vital utilities for installing any other linux packages.
# since we do not have a package manager, we need to install them manually.
# we run into a problem when building them from source inside the container,
# git needs make to install and make needs git to isntall.
# we face a chicken and egg problem.
COPY ./junk/make-install-dir/bin/* /usr/local/bin/
COPY ./junk/make-install-dir/include/* /usr/local/include/
COPY ./junk/make-install-dir/share/info/* /usr/local/share/info/
COPY ./junk/make-install-dir/share/man/man1/* /usr/local/share/man/man1/
# now for git...
COPY ./junk/git-install-dir/bin/* /usr/local/bin
RUN mkdir -p /usr/local/libexec/git-core/mergetools
COPY ./junk/git-install-dir/libexec/git-core/** /usr/local/libexec/git-core/
RUN mkdir -p /usr/local/share/{git-core,git-gui,gitk,gitweb,perl5}
COPY ./junk/git-install-dir/share/git-core/** /usr/local/share/git-core/

# install nodejs.
RUN cd /usr/var/http/myhttp && tar -xzvf node-latest-linux.tar.gz
RUN cd /usr/var/http/myhttp && mv node-v* node-latest-linux
RUN cd /usr/var/http/myhttp && cd node-latest-linux && cp -R * /usr/local/
RUN cd /usr/var/http/myhttp && rm -rf node*

# copy project files.
COPY ./http /usr/var/http/myhttp
RUN chmod +x /usr/var/http/myhttp/.container_initializer.sh
COPY ./http/node_modules /usr/var/http/myhttp/node_modules

# expose ports.
EXPOSE 3306
EXPOSE 3000

# run initializer.
CMD ["/usr/var/http/myhttp/.container_initializer.sh"]

