dwd
===

Docker WordPress Development

Build a container from scratch, this will prompt you for a few details like a Mysql password (which will be stored locally):

```
make temp
```

and you should be able to install a wp site using the password you just gave,
```
mysqlhost=mysql   # this is because of the docker linking magic
mysqluser=wpdbuser
database=wpdb
db_password=dbpass # The One You Supplied Earlier
```

to grab the data directories from apache and mysql do:
```
make grab
```
this will grab the /var/www/html from the wp container and /var/lib/mysql from the mysql container and put them in datadir

then you should be able to:
```
make prod
```

and run a persistent local WP install

[Please check out my blog for other associated miscellanea:](http://joshuacox.github.io/)
[joshuacox.github.io](http://joshuacox.github.io/)
