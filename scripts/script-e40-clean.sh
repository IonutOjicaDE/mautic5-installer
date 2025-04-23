#!/bin/bash
VERSION="0.0.2"
show_info ${ICON_INFO} "Start executing ${install_script_file} V${VERSION}." 1

###############################################################################################
#####                        Clear temporary and not needed files                         #####
###############################################################################################

COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_PROCESS_TIMEOUT=10000 composer --working-dir="${MAUTIC_FOLDER}" remove mautic/core-project-message --no-interaction > /dev/null 2>&1

if [[ $? -ne 0 ]]; then
  show_info ${ICON_ERR} "Error: Remove of mautic/core-project-message from Mautic${MAUTIC_COUNT} failed. We continue."
fi

show_info ${ICON_INFO} 'Autoremove of not needed packages...'
DEBIAN_FRONTEND=noninteractive apt-get -yq autoremove >/dev/null
show_info ${ICON_INFO} 'Clear cache of installed packages...'
DEBIAN_FRONTEND=noninteractive apt-get -yq clean >/dev/null
show_info ${ICON_OK} 'Autoremove and clean finished.'
