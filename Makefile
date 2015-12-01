.PHONY: all help build run builddocker rundocker kill rm-image rm clean enter logs ps prod temp ddd

user = $(shell whoami)
ifeq ($(user),root)
$(error  "do not run as root! run 'gpasswd -a USER docker' on the user of your choice")
endif

all: help

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make run       - build and run docker container
	@echo ""   2. make build     - build docker container
	@echo ""   3. make clean     - kill and remove docker container
	@echo ""   4. make enter     - execute an interactive bash in docker container
	@echo ""   3. make logs      - follow the logs of docker container

build: NAME TAG builddocker

# run a  container that requires mysql temporarily
temp: MYSQL_PASS build mysqltemp runmysqltemp ddd ps

# run a  container that requires mysql in production with persistent data
# HINT: use the grabmysqldatadir recipe to grab the data directory automatically from the above runmysqltemp
prod: APACHE_DATADIR MYSQL_DATADIR MYSQL_PASS mysqlcid runprod ddd ps

ddd:
	@cat ddd.txt

ps:
	@docker ps

runmysqltemp:
	$(eval TMP := $(shell mktemp -d --suffix=DOCKERTMP))
	$(eval NAME := $(shell cat NAME))
	$(eval TAG := $(shell cat TAG))
	chmod 777 $(TMP)
	@docker run --name=$(NAME) \
	--cidfile="cid" \
	-v $(TMP):/tmp \
	-d \
	-p 80:80 \
	--link `cat NAME`-mysqltemp:mysql \
	-v /var/run/docker.sock:/run/docker.sock \
	-v $(shell which docker):/bin/docker \
	-t $(TAG)

runprod:
	$(eval APACHE_DATADIR := $(shell cat APACHE_DATADIR))
	$(eval TMP := $(shell mktemp -d --suffix=DOCKERTMP))
	$(eval NAME := $(shell cat NAME))
	$(eval TAG := $(shell cat TAG))
	chmod 777 $(TMP)
	@docker run --name=$(NAME) \
	--cidfile="cid" \
	-v $(TMP):/tmp \
	-d \
	-p 80:80 \
	--link `cat NAME`-mysql:mysql \
	-v /var/run/docker.sock:/run/docker.sock \
	-v $(APACHE_DATADIR):/var/www/html \
	-v $(shell which docker):/bin/docker \
	-t $(TAG)

builddocker:
	docker build -t `cat TAG` .

kill:
	-@docker kill `cat cid`

rm-image:
	-@docker rm `cat cid`
	-@rm cid

rm: kill rm-image

clean: rm

enter:
	docker exec -i -t `cat cid` /bin/bash

logs:
	docker logs -f `cat cid`

NAME:
	@while [ -z "$$NAME" ]; do \
		read -r -p "Enter the name you wish to associate with this container [NAME]: " NAME; echo "$$NAME">>NAME; cat NAME; \
	done ;

TAG:
	@while [ -z "$$TAG" ]; do \
		read -r -p "Enter the tag you wish to associate with this container [TAG]: " TAG; echo "$$TAG">>TAG; cat TAG; \
	done ;

# MYSQL additions
# use these to generate a mysql container that may or may not be persistent

mysqlcid:
	$(eval MYSQL_DATADIR := $(shell cat MYSQL_DATADIR))
	docker run \
	--cidfile="mysqlcid" \
	--name `cat NAME`-mysql \
	-e MYSQL_ROOT_PASSWORD=`cat MYSQL_PASS` \
	-d \
	-v $(MYSQL_DATADIR):/var/lib/mysql \
	mysql:5.5

rmmysql: mysqlcid-rmkill

mysqlcid-rmkill:
	-@docker kill `cat mysqlcid`
	-@docker rm `cat mysqlcid`
	-@rm mysqlcid

# This one is ephemeral and will not persist data
mysqltemp:
	docker run \
	--cidfile="mysqltemp" \
	--name `cat NAME`-mysqltemp \
	-e MYSQL_ROOT_PASSWORD=`cat MYSQL_PASS` \
	-e MYSQL_PASSWORD=`cat MYSQL_PASS` \
	-e MYSQL_USER=drupal \
	-e MYSQL_DATABASE=drupal \
	-d \
	mysql:5.5

rmmysqltemp: mysqltemp-rmkill

mysqltemp-rmkill:
	-@docker kill `cat mysqltemp`
	-@docker rm `cat mysqltemp`
	-@rm mysqltemp

rmall: rm rmmysqltemp rmmysql

grab: grabapachedir grabmysqldatadir

# sudo on the cp as I am getting errors on btrfs storage driven docker systems

grabmysqldatadir:
	-mkdir -p datadir
	sudo docker cp `cat mysqltemp`:/var/lib/mysql datadir/
	sudo chown -R $(user). datadir/mysql
	echo `pwd`/datadir/mysql > MYSQL_DATADIR

grabapachedir:
	-mkdir -p datadir
	sudo docker cp `cat cid`:/var/www/html datadir/
	echo `pwd`/datadir/html > APACHE_DATADIR

#	sudo chown -R $(user). datadir/html

APACHE_DATADIR:
	@while [ -z "$$APACHE_DATADIR" ]; do \
		read -r -p "Enter the destination of the Apache data directory you wish to associate with this container [APACHE_DATADIR]: " APACHE_DATADIR; echo "$$APACHE_DATADIR">>APACHE_DATADIR; cat APACHE_DATADIR; \
	done ;

MYSQL_DATADIR:
	@while [ -z "$$MYSQL_DATADIR" ]; do \
		read -r -p "Enter the destination of the MySQL data directory you wish to associate with this container [MYSQL_DATADIR]: " MYSQL_DATADIR; echo "$$MYSQL_DATADIR">>MYSQL_DATADIR; cat MYSQL_DATADIR; \
	done ;

MYSQL_PASS:
	@while [ -z "$$MYSQL_PASS" ]; do \
		read -r -p "Enter the MySQL password you wish to associate with this container [MYSQL_PASS]: " MYSQL_PASS; echo "$$MYSQL_PASS">>MYSQL_PASS; cat MYSQL_PASS; \
	done ;

