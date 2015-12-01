ddd
===

Docker Drupal Development

Build a container from scratch, this will prompt you for a few details like a Mysql password (which will be stored locally):

```
make temp
```

and you should be able to install a drupal site using the password you just gave,
```
mysqlhost=mysql   # this is because of the docker linking magic
mysqluser=drupal
database=drupal
db_password=dbpass # The One You Supplied Earlier
```

to grab the data directories from apache and mysql do:
```
make grab
```
this will grab the /var/www/html from the drupal container and /var/lib/mysql from the mysql container and put them in datadir

then you should be able to:
```
make prod
```

and run a persistent local drupal 8 install, if you want to try drupal 7 change out the 8 for a 7 in the FROM line of the Dockerfile
