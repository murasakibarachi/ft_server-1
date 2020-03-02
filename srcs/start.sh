#!/bin/bash

service mysql start
#sed -i -r 's/index index.html index.htm index.nginx-debian.html/index index.html index.htm index.nginx-debian.html index.php/g' /etc/nginx/sites-enabled/default
#sed -i 's/\t#location ~ \\.php\$ {/\tlocation ~ \\.php$ {/g' /etc/nginx/sites-enabled/default
#sed -i 's|#\tfastcgi_pass unix:/run/php/php7.3-fpm.sock;|\tfastcgi_pass unix:/run/php/php7.3-fpm.sock;\n}|g' /etc/nginx/sites-enabled/default
nginx -t
service nginx restart

service php-mysql start
service php7.3-fpm start
mysql -u root < ./app/data.sql
ln -s /etc/nginx/sites-available/nathandemo /etc/nginx/sites-enabled/nathandemo
nginx -t
service nginx restart
#telecharger wordpress
wget https://wordpress.org/latest.tar.gz -P /tmp
tar xzf /tmp/latest.tar.gz --strip-components=1 -C /var/www/html/
cp /var/www/html/wp-config{-sample,}.php
#generer une cle de secu
curl -s https://api.wordpress.org/secret-key/1.1/salt/ > key.txt
#remplacer les cles de secu dans le fichier
sed -i -e "/^define( 'AUTH_KEY',         'put your unique phrase here' );/r key.txt" -e "/^define( 'AUTH_KEY',         'put your unique phrase here' );/,/^define( 'NONCE_SALT',       'put your unique phrase here' );/d" /var/www/html/wp-config.php
#definir les parametre de config wordpress
sed -i "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', 'nathandemo' );/g" /var/www/html/wp-config.php
sed -i "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', 'nathanuser' );/g" /var/www/html/wp-config.php
sed -i "s/define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', 'Str0nGPassword' );/g" /var/www/html/wp-config.php
sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', 'localhost' );/g" /var/www/html/wp-config.php
sed -i "s/define( 'DB_CHARSET', 'utf8' );/define( 'DB_CHARSET', 'utf8' );/g" /var/www/html/wp-config.php
chown -R www-data:www-data /var/www/html/
#telecharge PhpMyAdmin
wget https://files.phpmyadmin.net/phpMyAdmin/4.8.4/phpMyAdmin-4.8.4-all-languages.tar.gz -P /tmp
tar -xvf  /tmp/phpMyAdmin-4.8.4-all-languages.tar.gz -C /tmp
mv /tmp/phpMyAdmin-4.8.4-all-languages /usr/share/phpmyadmin
#configure phpMyadmin
mkdir -p /var/lib/phpmyadmin/tmp
chown -R www-data:www-data /var/lib/phpmyadmin
cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php
sed -i "s~\$cfg\['blowfish_secret'\] = '';~\$cfg\['blowfish_secret'\] = 'STRINGOFTHIRTYTWORANDOMCHARACTERS';~g" /usr/share/phpmyadmin/config.inc.php
echo "\$cfg['TempDir'] = '/var/lib/phpmyadmin/tmp';" >> /usr/share/phpmyadmin/config.inc.php
#cree les tables sql necessaires a PMA
mysql -u root < /usr/share/phpmyadmin/sql/create_tables.sql
mysql -u root < /app/conf_php.sql
ln -s /usr/share/phpmyadmin /var/www/html
while true; do sleep 1000; done
