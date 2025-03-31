#!/bin/bash

###############################################################################################
#####                                   Install plugins                                   #####
###############################################################################################


show_info ${ICON_INFO} 'Installing commands.php...'
wget -q 'https://github.com/IonutOjicaDE/mautic-commands/archive/refs/heads/main.zip' -O "${INSTALL_FOLDER}commands.zip"
unzip -q "${INSTALL_FOLDER}commands.zip" -d "${INSTALL_FOLDER}"
mv "${INSTALL_FOLDER}mautic-commands-main" "${MAUTIC_FOLDER}commands"
sed -i "s|/var/mautic-crons/|${CRON_FOLDER}|g" "${MAUTIC_FOLDER}commands/commands.php"
show_info ${ICON_OK} 'commands.php is installed.'


if false; then # first do nothing

show_info ${ICON_INFO} 'Installing Plugin: MauticAdvancedTemplatesBundle...'
wget -q 'https://github.com/IonutOjicaDE/MauticAdvancedTemplatesBundle/archive/refs/heads/master.zip' -O "${INSTALL_FOLDER}MauticAdvancedTemplatesBundle.zip"
unzip -q "${INSTALL_FOLDER}MauticAdvancedTemplatesBundle.zip" -d "${INSTALL_FOLDER}"
mv "${INSTALL_FOLDER}MauticAdvancedTemplatesBundle-master" "${MAUTIC_FOLDER}plugins/MauticAdvancedTemplatesBundle"
show_info ${ICON_OK} 'Plugin: MauticAdvancedTemplatesBundle is installed.'


show_info ${ICON_INFO} 'Installing Plugin: MauticPostalServerBundle...'
wget -q 'https://github.com/IonutOjicaDE/MauticPostalServerBundle/archive/refs/heads/master.zip' -O "${INSTALL_FOLDER}MauticPostalServerBundle.zip"
unzip -q "${INSTALL_FOLDER}MauticPostalServerBundle.zip" -d "${INSTALL_FOLDER}"
mv "${INSTALL_FOLDER}MauticPostalServerBundle-master" "${MAUTIC_FOLDER}plugins/MauticPostalServerBundle"

show_info ${ICON_OK} 'Plugin: MauticPostalServerBundle is installed.'


show_info ${ICON_INFO} 'Installing Plugin: JotaworksDoiBundle...'
wget -q 'https://github.com/IonutOjicaDE/mautic-doi-plugin/archive/refs/heads/main.zip' -O "${INSTALL_FOLDER}JotaworksDoiBundle.zip"
unzip -q "${INSTALL_FOLDER}JotaworksDoiBundle.zip" -d "${INSTALL_FOLDER}"
mv "${INSTALL_FOLDER}mautic-doi-plugin-main/src/JotaworksDoiBundle" "${MAUTIC_FOLDER}plugins/"
show_info ${ICON_OK} 'Plugin: JotaworksDoiBundle is installed.'

show_info ${ICON_INFO} 'Reset permissions...'
chown -R www-data:www-data "${MAUTIC_FOLDER}plugins/"
chmod -R 755 "${MAUTIC_FOLDER}plugins/"

show_info ${ICON_INFO} 'Clearing cache...'
php "${MAUTIC_FOLDER}bin/console" cache:clear --no-interaction --no-warmup

chown -R www-data:www-data "${MAUTIC_FOLDER}"
chmod -R 755 "${MAUTIC_FOLDER}"

show_info ${ICON_INFO} 'Reload plugins in Mautic...'
php "${MAUTIC_FOLDER}bin/console" mautic:plugins:reload
show_info ${ICON_OK} 'Plugins reloaded in Mautic.'

fi
