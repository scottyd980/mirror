#!/bin/sh

mysql -u "root" -p"$MYSQL_PASS" -e "SHOW DATABASES"

/var/www/mirror/prod/rel/mirror/bin/mirror migrate
/var/www/mirror/prod/rel/mirror/bin/mirror start