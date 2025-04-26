#!/bin/bash
VERSION="0.0.4"
show_info ${ICON_INFO} "Start executing ${install_script_file} V${VERSION}" 1

###############################################################################################
#####                                   Display summary                                   #####
###############################################################################################

echo
echo "Mautic installation is finished!"
if [ "${SSL_CERTIFICATE,,}" == "test" ]; then
  echo 'SSL certificate was installed only for test!'
  echo
elif [ "${SSL_CERTIFICATE,,}" == "yes" ]; then
  echo 'A production ready SSL certificate was installed.'
  echo
else
  echo 'No SSL certificate was installed.'
  echo
fi
echo
echo -e "You can login to Mautic here: ${UBlu}https://${MAUTIC_SUBDOMAIN}${RCol}"
echo -e "use username: ${BBlu}${MAUTIC_USERNAME}${RCol}"
echo -e "and password: ${BBlu}${MAUTIC_ADMIN_PASSWORD}${RCol}"
echo
if [ "$EMAIL_SENT" = false ]; then
  echo -e "${BRed}ERROR: The email with the passwords was not sent!${RCol}"
  echo "Please manually copy the passwords *NOW* from the file: ${CRON_FOLDER}mautic.txt !"
  echo "The content is displayed also below:"
  cat "${CRON_FOLDER}mautic.txt"
else
  echo -e "Passwords created during installations were sent to $(check_positive "${SEND_PASS_TO_SENDER_EMAIL}" && echo "${UBlu}${SENDER_EMAIL}${RCol} and to ")${UBlu}${ADMIN_EMAIL}${RCol}"
fi
echo
echo -e "Root password to login trough ssh: ${BBlu}${ROOT_USER_PASSWORD}${RCol}"
echo
echo '===================================================================================================='
echo 'Updated for Mautic 5 and 6 by Ionuţ Ojică - contact@ionutojica.ro'
echo
echo 'Source created by Matthias Reich - Info@Online-Business-Duplicator.de ( https://online-business-duplicator.de/mautic ).'
echo
echo '===================================================================================================='
