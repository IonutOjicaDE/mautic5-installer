#!/bin/bash

###############################################################################################
#####                                    Create database                                  #####
###############################################################################################

if [ -z "$MAUTIC_COUNT" ]; then
  show_info ${ICON_INFO} 'Change authentification to MySQL of root user from localhost to mysql_native_password...'
  #Schimbă parola utilizatorului root
  echo "ALTER USER 'root'@'localhost' IDENTIFIED VIA 'mysql_native_password';ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';FLUSH PRIVILEGES;" | mysql -u root
else
  # Check current authentication method for root user
  auth_plugin=$(echo "SELECT plugin FROM mysql.user WHERE User = 'root' AND Host = 'localhost';" | mysql -u root -p${MYSQL_ROOT_PASSWORD} -N)
  if [ "$auth_plugin" == "mysql_native_password" ]; then
      show_info ${ICON_OK} 'Authentication method to MySQL of root user is mysql_native_password'
  else
      show_info ${ICON_ERR} "Error: Authentication should be mysql_native_password, is ${auth_plugin}."
      show_info ${ICON_ERR} "Should the installation continue?"
      answer_yes_else_stop
  fi
fi

show_info ${ICON_INFO} "Create database mautic${MAUTIC_COUNT} and user mauticuser${MAUTIC_COUNT}..."

#database named "mautic" will be created
#username "mauticuser" will be created
#with the password "MYSQL_MAUTICUSER_PASSWORD"
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
CREATE DATABASE mautic${MAUTIC_COUNT} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL ON mautic${MAUTIC_COUNT}.* TO 'mauticuser${MAUTIC_COUNT}'@'localhost' IDENTIFIED BY '${MYSQL_MAUTICUSER_PASSWORD}';
FLUSH PRIVILEGES;
EOF

DB_EXISTS=$(mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -sse "SHOW DATABASES LIKE 'mautic${MAUTIC_COUNT}';")
if [[ "$DB_EXISTS" != "mautic${MAUTIC_COUNT}" ]]; then
  show_info ${ICON_ERR} "Error: Database 'mautic${MAUTIC_COUNT}' does not exist."
  show_info ${ICON_ERR} "Should the installation continue?"
  answer_yes_else_stop
fi

USER_EXISTS=$(mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -sse "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = 'mauticuser${MAUTIC_COUNT}' AND host = 'localhost');")
if [[ "$USER_EXISTS" != 1 ]]; then
  show_info ${ICON_ERR} "Error: User 'mauticuser${MAUTIC_COUNT}' does not exist."
  show_info ${ICON_ERR} "Should the installation continue?"
  answer_yes_else_stop
fi

show_info ${ICON_OK} 'Mautic database and user created.'
