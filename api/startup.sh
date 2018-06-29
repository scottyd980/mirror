#!/bin/sh

source /var/www/mirror/config/.env

/var/www/mirror/prod/rel/mirror/bin/mirror migrate
/var/www/mirror/prod/rel/mirror/bin/mirror start