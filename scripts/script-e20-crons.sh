#!/bin/bash

###############################################################################################
#####                                    Configure Cronjobs                               #####
###############################################################################################


show_info ${ICON_INFO} 'Installing cron scripts for web user...'

mv "${INSTALL_FOLDER}crons/"* "${CRON_FOLDER}"

chown -R www-data:www-data "${CRON_FOLDER}"
chown -R www-data:www-data "${BACKUP_FILES_FOLDER}"
chmod -R 755 "${CRON_FOLDER}"
chmod -R 755 "${BACKUP_FILES_FOLDER}"
show_info ${ICON_OK} 'Cron scripts for web user installed and permissions set.'


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
show_info ${ICON_OK} 'Crons for web user scheduled.'


sed -i "s|###CRON_FOLDER###|${CRON_FOLDER}|g" "${INSTALL_FOLDER}other/reset-mautic-permissions.sh"
mv "${INSTALL_FOLDER}other/reset-mautic-permissions.sh" "${ROOT_FILES_FOLDER}reset-mautic${MAUTIC_COUNT}-permissions.sh"
chmod a+x "${ROOT_FILES_FOLDER}reset-mautic${MAUTIC_COUNT}-permissions.sh"
show_info ${ICON_OK} 'Cron script for root user installed.'


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
show_info ${ICON_OK} 'Cron for root user scheduled.'


show_info ${ICON_INFO} 'Clearing cache...'
runuser -u www-data -- php "${CRON_FOLDER}cron-clear-cache.php"

chown -R www-data:www-data "${MAUTIC_FOLDER}"
chmod -R 755 "${MAUTIC_FOLDER}"

show_info ${ICON_OK} 'Crons are installed.'
