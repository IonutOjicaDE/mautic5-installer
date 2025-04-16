#!/bin/bash

###############################################################################################
#####                                    Configure Cronjobs                               #####
###############################################################################################


show_info ${ICON_INFO} 'Installing cron scripts for web user...'

mkdir -p "${CRON_FOLDER}"
mkdir -p "${BACKUP_FILES_FOLDER}"

mv "${INSTALL_FOLDER}crons/"* "${CRON_FOLDER}"
mv "${TEMP_FOLDER}"* "${CRON_FOLDER}"
rm -d "${TEMP_FOLDER}"

chown -R www-data:www-data "${CRON_FOLDER}"
chown -R www-data:www-data "${BACKUP_FILES_FOLDER}"
chmod -R 755 "${CRON_FOLDER}"
chmod -R 755 "${BACKUP_FILES_FOLDER}"
show_info ${ICON_OK} 'installed and permissions set.' 0


show_info ${ICON_OK} 'Scheduling crons for web user...'
if [ -z "${MAUTIC_COUNT}" ]; then
  echo "" > crontab_temp
  cron_execution_hour="1"
else
  crontab -u www-data -l > crontab_temp
  cron_execution_hour="${MAUTIC_COUNT}"
fi
file_content="$(cat << EOF
1 ${cron_execution_hour} * * * bash ${CRON_FOLDER}w-cron-iplookup-download.sh >> ${CRON_FOLDER}w-cron.log 2>&1
10 ${cron_execution_hour} * * * bash ${CRON_FOLDER}w-cron-backup.sh >> ${CRON_FOLDER}w-cron.log 2>&1
20 ${cron_execution_hour} * * * bash ${CRON_FOLDER}w-cron-duplicate.sh >> ${CRON_FOLDER}w-cron.log 2>&1
25 ${cron_execution_hour} * * * bash ${CRON_FOLDER}w-cron-database-optimization.sh >> ${CRON_FOLDER}w-cron.log 2>&1
30 ${cron_execution_hour} ${cron_execution_hour} * * bash ${CRON_FOLDER}w-cron-maintenance-cleanup.sh >> ${CRON_FOLDER}w-cron.log 2>&1
* * * * * bash ${CRON_FOLDER}w-cron-all.sh >> ${CRON_FOLDER}w-cron.log 2>&1
2${cron_execution_hour} * * * * bash ${CRON_FOLDER}send-email.sh >> ${CRON_FOLDER}w-cron.log 2>&1
EOF
)"
echo "${file_content}" >> crontab_temp
crontab -u www-data crontab_temp
rm crontab_temp
show_info ${ICON_OK} 'scheduled.' 0


show_info ${ICON_INFO} 'Installing cron script for root user...'
sed -i "s|###CRON_FOLDER###|${CRON_FOLDER}|g" "${INSTALL_FOLDER}other/reset-mautic-permissions.sh"
mv "${INSTALL_FOLDER}other/reset-mautic-permissions.sh" "${ROOT_FILES_FOLDER}reset-mautic${MAUTIC_COUNT}-permissions.sh"
chmod a+x "${ROOT_FILES_FOLDER}reset-mautic${MAUTIC_COUNT}-permissions.sh"
show_info ${ICON_OK} 'installed and permissions set.' 0


show_info ${ICON_OK} 'Scheduling cron for root user...'
if [ -z "${MAUTIC_COUNT}" ]; then
  echo "" > crontab_temp
else
  crontab -l > crontab_temp
fi
file_content="$(cat << EOF
4${cron_execution_hour} 0 * * * bash ${ROOT_FILES_FOLDER}reset-mautic${MAUTIC_COUNT}-permissions.sh >> ${CRON_FOLDER}r-cron.log 2>&1
EOF
)"
echo "${file_content}" >> crontab_temp
crontab crontab_temp
rm crontab_temp
show_info ${ICON_OK} 'scheduled.' 0


show_info ${ICON_INFO} 'Installing messenger:consume workers...'

for SERVICE in email failed hit; do
  sed -i "s|###MAUTIC_FOLDER###|${MAUTIC_FOLDER}|g" "${INSTALL_FOLDER}other/mautic-consume-${SERVICE}@.service"

  if [ -z "${MAUTIC_COUNT}" ]; then
    SERVICE_FILENAME="mautic-consume-${SERVICE}@.service"
  else
    SERVICE_FILENAME="mautic${MAUTIC_COUNT}-consume-${SERVICE}@.service"
  fi

  mv "${INSTALL_FOLDER}other/mautic-consume-${SERVICE}@.service" "/etc/systemd/system/${SERVICE_FILENAME}"
done

systemctl daemon-reload

for SERVICE in email failed hit; do
  if [ -z "${MAUTIC_COUNT}" ]; then
    SERVICE_NAME="mautic-consume-${SERVICE}@1"
  else
    SERVICE_NAME="mautic${MAUTIC_COUNT}-consume-${SERVICE}@1"
  fi

  systemctl enable ${SERVICE_NAME}
  systemctl start ${SERVICE_NAME}

  if systemctl is-active --quiet ${SERVICE_NAME}; then
    show_info ${ICON_OK} "${SERVICE_NAME} is installed and activ."
  else
    show_info ${ICON_ERR} "${SERVICE_NAME} is installed but did not start."
  fi
done


show_info ${ICON_INFO} 'Installing sending email rate limiter...'
mv "${INSTALL_FOLDER}other/rate_limiter.yaml" "${MAUTIC_FOLDER}config/packages/rate_limiter.yaml"
mv "${INSTALL_FOLDER}other/messenger.yaml" "${MAUTIC_FOLDER}config/packages/messenger.yaml"
show_info ${ICON_OK} 'installed.' 0


show_info ${ICON_INFO} 'Clearing cache...'

chown -R www-data:www-data "${MAUTIC_FOLDER}"
chmod -R 755 "${MAUTIC_FOLDER}"

runuser -u www-data -- php "${CRON_FOLDER}cron-clear-cache.php"

show_info ${ICON_OK} 'Crons are installed.'
