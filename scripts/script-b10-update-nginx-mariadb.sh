#!/bin/bash
VERSION="0.0.6"
show_info ${ICON_INFO} "Start executing ${install_script_file} V${VERSION}." 1

###############################################################################################
#####                               Install nginx, MariaDb                                #####
###############################################################################################


if [ -z "${MAUTIC_COUNT}" ]; then

  show_info ${ICON_INFO} 'Enable autentification using password for root user...'
  echo "root:${ROOT_USER_PASSWORD}" | chpasswd
  sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
  sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
  systemctl restart sshd
  show_info ${ICON_OK} 'done.' 0


  show_info ${ICON_INFO} 'Time zone of the operating system must remain Etc/UTC...'
  timedatectl set-timezone "Etc/UTC"
  show_info ${ICON_OK} 'done.' 0


  show_info ${ICON_INFO} 'Installing nginx...'
  errors=()
  DEBIAN_FRONTEND=noninteractive apt-get -yq install nginx htop >/dev/null 2>&1 || errors+=("Installing nginx.")
  systemctl enable nginx >/dev/null 2>&1 || errors+=("Enable autostart of nginx on every reboot (systemctl enable nginx).")
  systemctl start nginx >/dev/null 2>&1 || errors+=("Starting nginx now (systemctl start nginx).")
  chown www-data:www-data /usr/share/nginx/html -R >/dev/null 2>&1 || errors+=("Setting permissions.")

  if [[ ${#errors[@]} -gt 0 ]]; then
    show_info ${ICON_ERR} "ERROR:"
    for err in "${errors[@]}"; do
      show_info ${ICON_NOGO} "$err"
    done

    show_info ${ICON_QUE} "Should we continue installation?"
    answer_yes_else_stop
  else
    show_info ${ICON_OK} 'done.' 0
  fi


  show_info ${ICON_INFO} 'Installing MariaDB...'
  errors=()
  DEBIAN_FRONTEND=noninteractive apt-get -yq install mariadb-server mariadb-client >/dev/null 2>&1 || errors+=("Installing MariaDB.")
  systemctl enable mariadb >/dev/null 2>&1 || errors+=("Enable autostart of MariaDB on every reboot (systemctl enable mariadb).")

mysql -u root <<EOF
-- Delete anonymous users
DELETE FROM mysql.user WHERE User='';

-- Disable remote login for root
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Delete database "test"
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

FLUSH PRIVILEGES;
EOF
  if [[ $? -ne 0 ]]; then
    errors+=("Optimizing MariaDB.")
  fi

  echo "ALTER USER 'root'@'localhost' IDENTIFIED VIA 'mysql_native_password';ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';FLUSH PRIVILEGES;" | mysql -u root
  if [[ $? -ne 0 ]]; then
    errors+=("Change password of root for MariaDB.")
  fi

  if [[ ${#errors[@]} -gt 0 ]]; then
    show_info ${ICON_ERR} "ERROR:"
    for err in "${errors[@]}"; do
      show_info ${ICON_NOGO} "$err"
    done

    show_info ${ICON_QUE} "Should we continue installation?"
    answer_yes_else_stop
  else
    show_info ${ICON_OK} 'done.' 0
  fi


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
