#!/bin/bash

###############################################################################################
#####                                 Install Mautic                                      #####
###############################################################################################

show_info ${ICON_INFO} 'Download Mautic...'

mkdir -p "${MAUTIC_FOLDER}"

COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_PROCESS_TIMEOUT=10000 composer create-project mautic/recommended-project:"${MAUTIC_VERSION}" "$MAUTIC_FOLDER" --no-interaction

# DEBIAN_FRONTEND=noninteractive apt-get -yq install unzip zip >/dev/null
# wget -q "${MAUTIC_DOWNLOAD_URL}" -P "${INSTALL_FOLDER}"
#
# show_info ${ICON_INFO} 'Unzip Mautic...'
# unzip -q "${INSTALL_FOLDER}${MAUTIC_VERSION}.zip" -d "${MAUTIC_FOLDER}"

chown -R www-data:www-data "${MAUTIC_FOLDER}"
chmod -R 755 "${MAUTIC_FOLDER}"

show_info ${ICON_OK} 'Mautic is installed.'
