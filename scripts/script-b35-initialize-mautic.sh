#!/bin/bash

###############################################################################################
#####                                 Initialize Mautic                                   #####
###############################################################################################


show_info ${ICON_INFO} 'Initialize Mautic...'

runuser -u www-data -- bash -c "cd '${MAUTIC_FOLDER}' && php bin/console mautic:install \
--db_driver=pdo_mysql \
--db_host=localhost \
--db_port=3306 \
--db_name=mautic${MAUTIC_COUNT} \
--db_user=mautic${MAUTIC_COUNT} \
--db_password='${MYSQL_MAUTICUSER_PASSWORD}' \
--admin_username=${MAUTIC_USERNAME} \
--admin_password='${MAUTIC_ADMIN_PASSWORD}' \
--admin_email=${SENDER_EMAIL} \
--admin_firstname=${SENDER_FIRSTNAME} \
--admin_lastname=${SENDER_LASTNAME} \
https://${MAUTIC_SUBDOMAIN}"

show_info ${ICON_OK} 'Mautic initialized.'

chown -R www-data:www-data "${MAUTIC_FOLDER}"
chmod -R 755 "${MAUTIC_FOLDER}"

show_info ${ICON_OK} 'Cache is cleared.'

