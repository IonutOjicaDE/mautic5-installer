#!/bin/bash

###############################################################################################
#####                                 Install Adminer                                     #####
###############################################################################################

show_info ${ICON_INFO} 'Download Adminer...'

#wget "${URL_TO_FILES}bazadate.zip"
#unzip -q bazadate.zip -d "${MAUTIC_FOLDER}"
#rm bazadate.zip

mkdir -p "${MAUTIC_FOLDER}database/plugins"

wget -q "${ADMINER_DOWNLOAD_URL}" -O "${MAUTIC_FOLDER}database/adminer.php"
mv "${INSTALL_FOLDER}other/database.php" "${MAUTIC_FOLDER}database/"

ADMINER_PLUGIN_FOLDER="${MAUTIC_FOLDER}database/plugins/"
wget -q https://raw.githubusercontent.com/adminerevo/adminerevo/master/plugins/plugin.php -P "${ADMINER_PLUGIN_FOLDER}"
wget -q https://raw.githubusercontent.com/adminerevo/adminerevo/master/plugins/edit-textarea.php -P "${ADMINER_PLUGIN_FOLDER}"
wget -q https://raw.githubusercontent.com/adminerevo/adminerevo/master/plugins/file-upload.php -P "${ADMINER_PLUGIN_FOLDER}"
wget -q https://raw.githubusercontent.com/adminerevo/adminerevo/master/plugins/foreign-system.php -P "${ADMINER_PLUGIN_FOLDER}"
wget -q https://raw.githubusercontent.com/adminerevo/adminerevo/master/plugins/tables-filter.php -P "${ADMINER_PLUGIN_FOLDER}"
wget -q https://raw.githubusercontent.com/adminerevo/adminerevo/master/plugins/tinymce.php -P "${ADMINER_PLUGIN_FOLDER}"

chown -R www-data:www-data "${MAUTIC_FOLDER}"
chmod -R 755 "${MAUTIC_FOLDER}"


show_info ${ICON_OK} 'Adminer is installed.'
