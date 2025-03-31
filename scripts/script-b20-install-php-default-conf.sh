#!/bin/bash

###############################################################################################
#####                          Install php, configure php, nginx                          #####
###############################################################################################


if [ -z "${MAUTIC_COUNT}" ]; then

  show_info ${ICON_INFO} 'Install MidnightCommander - orthodox File Explorer...'
  DEBIAN_FRONTEND=noninteractive apt-get -yq install mc >/dev/null

  show_info ${ICON_INFO} 'Install php...'
  DEBIAN_FRONTEND=noninteractive apt-get -yq install php${PHP_VERSION} php${PHP_VERSION}-{fpm,mysql,cli,common,opcache,readline,mbstring,xml,gd,curl,imagick,imap,zip,bz2,intl,gmp,bcmath} >/dev/null

  #Enable autostart of php on every reboot
  systemctl start php${PHP_VERSION}-fpm >/dev/null
  #Start php now
  systemctl enable php${PHP_VERSION}-fpm >/dev/null


  #Ideally the sessions folder should allow web server to create and modify session files.
  #Prevend such Mautic errors:
  #[2024-03-17 20:32:35] mautic.NOTICE: PHP Notice - SessionHandler::gc(): ps_files_cleanup_dir: opendir(/var/lib/php/sessions) failed: Permission denied (13) - in file /var/www/mautic/vendor/symfony/http-foundation/Session/Storage/Handler/StrictSessionHandler.php - at line 106 {"maxlifetime":14400} {"hostname":"m","pid":2243362}
  sudo chown www-data:www-data /var/lib/php/sessions
  sudo chmod 700 /var/lib/php/sessions
  show_info ${ICON_OK} "php${PHP_VERSION} is installed."


  show_info ${ICON_INFO} 'Adjust configuration of web server Nginx...'
  rm /etc/nginx/sites-enabled/default

file_content="$(cat << EOF
server {
  listen 80;
  listen [::]:80;
  server_name _;
  root /usr/share/nginx/html/;
  index index.php index.html index.htm index.nginx-debian.html;

  location / {
    try_files \$uri \$uri/ /index.php;
  }

  location ~ \.php$ {
    fastcgi_pass unix:/run/php/php${PHP_VERSION}-fpm.sock;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    include fastcgi_params;
    include snippets/fastcgi-php.conf;
  }

 # A long browser cache lifetime can speed up repeat visits to your page
  location ~* \.(jpg|jpeg|gif|png|webp|svg|woff|woff2|ttf|css|js|ico|xml)$ {
       access_log        off;
       log_not_found     off;
       expires           360d;
  }

  # disable access to hidden files
  location ~ /\.ht {
      access_log off;
      log_not_found off;
      deny all;
  }
}
EOF
)"
  echo "${file_content}" > /etc/nginx/conf.d/default.conf
  systemctl reload nginx

  mkdir -p /etc/systemd/system/nginx.service.d/
file_content="$(cat << EOF
[Service]
Restart=always
RestartSec=5s
EOF
)"
  echo "${file_content}" > /etc/systemd/system/nginx.service.d/restart.conf
  systemctl daemon-reload

  php_ini_file="/etc/php/${PHP_VERSION}/fpm/php.ini"
  sed -i 's/memory_limit = 128M/memory_limit = 2048M/' "${php_ini_file}"
  sed -i 's/post_max_size = 8M/post_max_size = 512M/' "${php_ini_file}"
  sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 512M/' "${php_ini_file}"
  sed -i 's/max_execution_time = 30/max_execution_time = 360/' "${php_ini_file}"
  sed -i 's/;date.timezone =/date.timezone = UTC/' "${php_ini_file}"
  #PHP will not try to correct the path to script filex
  sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' "${php_ini_file}"
  #Increase the lifetime of the unused php sessions
  #1440 = 24 minutes , 14400 = 4 hours
  sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 14400/' "${php_ini_file}"

  systemctl restart php${PHP_VERSION}-fpm.service

  show_info ${ICON_OK} 'Configuration of web server Nginx and php finished.'

else
  show_info ${ICON_INFO} 'No install or configuration of php or configuration of Nginx'
fi
