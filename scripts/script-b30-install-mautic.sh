#!/bin/bash

###############################################################################################
#####                                 Install Mautic                                      #####
###############################################################################################

show_info ${ICON_INFO} 'Download and install Mautic - this will take time...'

COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_PROCESS_TIMEOUT=10000 composer create-project mautic/recommended-project:"${MAUTIC_VERSION}" "${MAUTIC_FOLDER}" --no-interaction

chown -R www-data:www-data "${MAUTIC_FOLDER}"
chmod -R 755 "${MAUTIC_FOLDER}"

show_info ${ICON_INFO} 'Download and install symfony/amazon-mailer...'

COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_PROCESS_TIMEOUT=10000 composer --working-dir="${MAUTIC_FOLDER}" require symfony/amazon-mailer --no-interaction

chown -R www-data:www-data "${MAUTIC_FOLDER}"
chmod -R 755 "${MAUTIC_FOLDER}"

show_info ${ICON_OK} 'Mautic is installed.'
