#!/bin/bash

###############################################################################################
#####            Configure MySQL, local.php, copy commands.php, ro-translation            #####
###############################################################################################


if false; then # first do nothing

show_info ${ICON_INFO} 'Installing MySQL database template...'

LOCAL_SQL_FILE="${INSTALL_FOLDER}other/mautic-database-template-ro.sql"
if [[ ! -e "${LOCAL_SQL_FILE}" ]]; then
  show_info ${ICON_ERR} "MySQL database template does not exists and should be in the downloaded archive..."
  show_info ${ICON_ERR} "Missing MySQL database template: ${LOCAL_SQL_FILE} !"
  show_info ${ICON_NOGO} 'Terminating installation!'
  exit 1
fi

sed -i "s|###SENDER_EMAIL###|$SENDER_EMAIL|g" "${LOCAL_SQL_FILE}"
sed -i "s|###MAUTIC_USERNAME###|$MAUTIC_USERNAME|g" "${LOCAL_SQL_FILE}"
sed -i "s|###MAIN_DOMAIN###|$MAIN_DOMAIN|g" "${LOCAL_SQL_FILE}"
sed -i "s|###MAUTIC_SUBDOMAIN###|$MAUTIC_SUBDOMAIN|g" "${LOCAL_SQL_FILE}"
sed -i "s|###SENDER_FIRSTNAME###|$SENDER_FIRSTNAME|g" "${LOCAL_SQL_FILE}"
sed -i "s|###SENDER_LASTNAME###|$SENDER_LASTNAME|g" "${LOCAL_SQL_FILE}"

mysql -u root -p${MYSQL_ROOT_PASSWORD} mautic${MAUTIC_COUNT} < "${LOCAL_SQL_FILE}"

show_info ${ICON_OK} 'MySQL database installed.'


show_info ${ICON_INFO} 'Save encrypted password for mautic admin in the database...'

mautic_admin_password_md5=$(echo "$MAUTIC_ADMIN_PASSWORD" | openssl passwd -1 -stdin)
echo "use mautic${MAUTIC_COUNT}; UPDATE users SET password='${mautic_admin_password_md5}' WHERE username='${MAUTIC_USERNAME}';" | mysql -u root -p${MYSQL_ROOT_PASSWORD}

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
      answer_yes_else_stop && continue
  fi
fi


show_info ${ICON_INFO} 'Installing local.php...'

LOCAL_PHP_FILE="${INSTALL_FOLDER}other/local.ro.php"
if [[ ! -e "${LOCAL_PHP_FILE}" ]]; then
  show_info ${ICON_ERR} "local.php does not exists and should be in the downloaded archive..."
  show_info ${ICON_ERR} "Missing local.php: ${LOCAL_PHP_FILE} !"
  show_info ${ICON_NOGO} 'Terminating installation!'
  exit 1
fi

show_info ${ICON_INFO} 'Personalize local.php...'
sed -i "s|###SENDER_EMAIL###|$SENDER_EMAIL|g" "${LOCAL_PHP_FILE}"
sed -i "s|###MAIN_DOMAIN###|$MAIN_DOMAIN|g" "${LOCAL_PHP_FILE}"
sed -i "s|###MAUTIC_SUBDOMAIN###|$MAUTIC_SUBDOMAIN|g" "${LOCAL_PHP_FILE}"
sed -i "s|###SENDER_FIRSTNAME###|$SENDER_FIRSTNAME|g" "${LOCAL_PHP_FILE}"
sed -i "s|###SENDER_LASTNAME###|$SENDER_LASTNAME|g" "${LOCAL_PHP_FILE}"
sed -i "s|###MAUTIC_FOLDER###|$MAUTIC_FOLDER|g" "${LOCAL_PHP_FILE}"
sed -i "s|###MAUTIC_SECRET_KEY###|$MAUTIC_SECRET_KEY|g" "${LOCAL_PHP_FILE}"
sed -i "s|###MAUTIC_REMEMBERME_KEY###|$MAUTIC_REMEMBERME_KEY|g" "${LOCAL_PHP_FILE}"

sed -i "s|###mysql_mautic_database###|mautic${MAUTIC_COUNT}|g" "${LOCAL_PHP_FILE}"
sed -i "s|###mysql_mauticuser_name###|mauticuser${MAUTIC_COUNT}|g" "${LOCAL_PHP_FILE}"
sed -i "s|###MYSQL_MAUTICUSER_PASSWORD###|$MYSQL_MAUTICUSER_PASSWORD|g" "${LOCAL_PHP_FILE}"
sed -i "s|###SENDER_TIMEZONE###|$SENDER_TIMEZONE|g" "${LOCAL_PHP_FILE}"

mv "${LOCAL_PHP_FILE}" "${MAUTIC_FOLDER}app/config/local.php"
show_info ${ICON_OK} 'local.php installed.'


show_info ${ICON_INFO} 'Install romanian laguage package'
#wget 'https://updates.mautic.org/index.php?option=com_mauticdownload&task=downloadLanguagePackage&langCode=ro_RO' -O ro_RO.zip
wget -q 'https://github.com/IonutOjicaDE/mautic4-ro-translation/archive/refs/heads/main.zip' -O "${INSTALL_FOLDER}mautic4-ro-translation.zip"
unzip -q "${INSTALL_FOLDER}mautic4-ro-translation.zip" -d "${INSTALL_FOLDER}"
mv "${INSTALL_FOLDER}mautic4-ro-translation-main/ro_RO" "${MAUTIC_FOLDER}translations/"
show_info ${ICON_OK} 'Romanian laguage package installed.'


chown -R www-data:www-data "${MAUTIC_FOLDER}"
chmod -R 755 "${MAUTIC_FOLDER}"

fi
