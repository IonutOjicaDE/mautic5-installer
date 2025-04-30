#!/bin/bash
VERSION="0.0.9"
show_info ${ICON_INFO} "Start executing ${install_script_file} V${VERSION}" 1

###############################################################################################
#####                               Install nginx, MySQL                                #####
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


  show_info ${ICON_OK} 'Installing MySQL:'

show_info ${ICON_INFO} 'Download and add the GPG key for the official MySQL repository...'
output=$(wget -O mysql-apt-config.deb https://dev.mysql.com/get/mysql-apt-config_0.8.29-1_all.deb 2>&1)
if [[ $? -ne 0 ]]; then
  show_info ${ICON_ERR} 'ERROR downloading mysql-apt-config:' 0
  echo "$output"
  show_info ${ICON_QUE} "Do you want to continue?"
  answer_yes_else_stop && continue
fi
show_info ${ICON_OK} 'done.' 0

show_info ${ICON_INFO} 'Preconfiguring mysql-apt-config to use MySQL 8.0...'
echo "mysql-apt-config mysql-apt-config/select-server select mysql-8.0" | debconf-set-selections

output=$(DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config.deb 2>&1)
if [[ $? -ne 0 ]]; then
  show_info ${ICON_ERR} 'ERROR installing mysql-apt-config:' 0
  echo "$output"
  show_info ${ICON_QUE} "Do you want to continue?"
  answer_yes_else_stop && continue
fi
show_info ${ICON_OK} 'done.' 0

show_info ${ICON_INFO} 'Updating package list after adding MySQL repository...'
output=$(DEBIAN_FRONTEND=noninteractive apt-get -yq update 2>&1)
if [[ $? -ne 0 ]]; then
  show_info ${ICON_ERR} 'ERROR updating apt package list:' 0
  echo "$output"
  show_info ${ICON_QUE} "Do you want to continue?"
  answer_yes_else_stop && continue
fi
show_info ${ICON_OK} 'done.' 0

show_info ${ICON_INFO} 'Installing MySQL 8.0 server and client...'
output=$(DEBIAN_FRONTEND=noninteractive apt-get install -yq mysql-server mysql-client 2>&1)
if [[ $? -ne 0 ]]; then
  show_info ${ICON_ERR} 'ERROR installing MySQL:' 0
  echo "$output"
  show_info ${ICON_QUE} "Do you want to continue?"
  answer_yes_else_stop && continue
fi
show_info ${ICON_OK} 'done.' 0

rm -f mysql-apt-config.deb

  errors=()
  systemctl enable mysql >/dev/null 2>&1 || errors+=("Enable autostart of MySQL on every reboot (systemctl enable mysql).")

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
    errors+=("Optimizing MySQL.")
  fi

  echo "ALTER USER 'root'@'localhost' IDENTIFIED VIA 'mysql_native_password';ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';FLUSH PRIVILEGES;" | mysql -u root
  if [[ $? -ne 0 ]]; then
    errors+=("Change password of root for MySQL.")
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

  if dpkg -s nginx >/dev/null 2>&1; then
    show_info ${ICON_OK} 'Nginx is already installed.'
  else
    show_info ${ICON_NOGO} "Error: Nginx should already be installed, when installing ${MAUTIC_COUNT} instance of Mautic !"
    exit 1
  fi
  if dpkg -s mysql-server >/dev/null 2>&1; then
    show_info ${ICON_OK} 'MySQL is already installed.'
  else
    show_info ${ICON_NOGO} "Error: MySQL should already be installed, when installing ${MAUTIC_COUNT} instance of Mautic !"
    exit 1
  fi

fi
