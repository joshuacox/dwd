FROM wordpress

#RUN apt-get update
#RUN apt-get install -y wget mysql-client
#RUN rm -rf /var/lib/apt/lists/*
RUN cd /tmp;curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN cd /tmp ; php wp-cli.phar --allow-root --info; ls -lh /tmp; chmod +x /tmp/wp-cli.phar; 
RUN cp /tmp/wp-cli.phar /usr/local/bin/wp
RUN wp --allow-root --info

#RUN chsh -s /bin/bash www-data
