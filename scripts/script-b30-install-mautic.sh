#!/bin/bash

###############################################################################################
#####                                 Install Mautic                                      #####
###############################################################################################

show_info ${ICON_INFO} 'Download Mautic...'

mkdir -p "${MAUTIC_FOLDER}"

composer create-project mautic/recommended-project:"^${MAJOR_VERSION}" "$MAUTIC_FOLDER"

# DEBIAN_FRONTEND=noninteractive apt-get -yq install unzip zip >/dev/null
# wget -q "${MAUTIC_DOWNLOAD_URL}" -P "${INSTALL_FOLDER}"
#
# show_info ${ICON_INFO} 'Unzip Mautic...'
# unzip -q "${INSTALL_FOLDER}${MAUTIC_VERSION}.zip" -d "${MAUTIC_FOLDER}"

chown -R www-data:www-data "${MAUTIC_FOLDER}"
chmod -R 755 "${MAUTIC_FOLDER}"

show_info ${ICON_OK} 'Mautic is installed.'
