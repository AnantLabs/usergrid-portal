# use same ubuntu version as java container
FROM usergrid-java

RUN \
  apt-get update && \
  \
  echo "+++ install nginx" && \
  apt-get install -y nginx && \
  chown -R www-data:www-data /var/lib/nginx && \
  rm -rf /var/www/html/* && \
  \
  echo "++ build usergrid portal" && \
  apt-get install -y npm git-core nodejs-legacy phantomjs && \
  npm install -g n && \
  n stable && \
  git clone https://github.com/apache/usergrid.git /root/usergrid 

#RUN \
#  cd /root/usergrid && \
#  git checkout tags/portal-2.0.16 
 
RUN  cd /root/usergrid/portal && \
  npm install -g grunt-cli && \
  ./build.sh && \
  mv /root/usergrid/portal/dist/usergrid-portal/* /var/www/html && \
  chown -R www-data:www-data /var/www/html && \
  \
  echo "+++ cleanup" && \
  rm -rf /root/usergrid && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get purge -y npm git-core nodejs-legacy phantomjs &&\
  apt-get autoremove -y && \
  apt-get clean -y

EXPOSE 80

VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/conf.d", "/var/log/nginx"]

COPY run.sh /root/run.sh
RUN chmod 777 /root/run.sh
RUN sed -i -e 's/\r$//' /root/run.sh
CMD /root/run.sh
