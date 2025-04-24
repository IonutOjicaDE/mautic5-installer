#!/bin/bash
VERSION="0.0.3"
show_info ${ICON_INFO} "Start executing ${install_script_file} V${VERSION}." 1

###############################################################################################
#####                               Install nginx, MariaDb                                #####
###############################################################################################


if [ -z "${MAUTIC_COUNT}" ]; then

  show_info ${ICON_INFO} 'Enable autentification using password for root user'
  echo "root:${ROOT_USER_PASSWORD}" | chpasswd
  sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
  sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
  systemctl restart sshd


  show_info ${ICON_INFO} 'Time zone of the operating system must remain Etc/UTC'
  timedatectl set-timezone "Etc/UTC"

  show_info ${ICON_INFO} 'Installing nginx...'
  DEBIAN_FRONTEND=noninteractive apt-get -yq install nginx htop >/dev/null
  # Enable autostart of nginx on every reboot
  systemctl enable nginx >/dev/null
  # Start nginx now
  systemctl start nginx >/dev/null
  # Assure the correct permissions
  chown www-data:www-data /usr/share/nginx/html -R
  show_info ${ICON_OK} 'Nginx is installed.'


  show_info ${ICON_INFO} 'Installing MariaDB...'
  DEBIAN_FRONTEND=noninteractive apt-get -yq install mariadb-server mariadb-client >/dev/null
  # Enable autostart of MariaDB on every reboot
  systemctl enable mariadb >/dev/null

mysql -u root <<EOF
-- Setează parola root (doar dacă e instalare proaspătă)
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

-- Șterge utilizatorii anonimi
DELETE FROM mysql.user WHERE User='';

-- Dezactivează loginul remote pentru root
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Șterge baza de date "test"
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Reîncarcă privilegii
FLUSH PRIVILEGES;
EOF

#mysql_secure_installation <<EOF
#y
#${MYSQL_ROOT_PASSWORD}
#${MYSQL_ROOT_PASSWORD}
#y
#y
#y
#y
#y
#EOF

  show_info ${ICON_OK} 'MariaDB is installed.'

else

  if dpkg -l | grep -qw nginx; then
    show_info ${ICON_OK} 'Nginx is already installed.'
  else
    show_info ${ICON_NOGO} "Error: Nginx should already be installed, when installing ${MAUTIC_COUNT} instance of Mautic !"
    exit 1
  fi
  if dpkg -l | grep -qw mariadb; then
    show_info ${ICON_OK} 'MariaDB is already installed.'
  else
    show_info ${ICON_NOGO} "Error: MariaDB should already be installed, when installing ${MAUTIC_COUNT} instance of Mautic !"
    exit 1
  fi

fi
