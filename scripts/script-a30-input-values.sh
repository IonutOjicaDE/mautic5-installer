#!/bin/bash

###############################################################################
#                                                                             #
# Input values                                                                #
#                                                                             #
###############################################################################

#clear
# https://patorjk.com/software/taag/#p=display&f=Colossal&t=ionutojica.ro
echo -e "${Cya}"
echo 'd8b                            888             d8b d8b                                       '
echo 'Y8P                            888             Y8P Y8P                                       '
echo '                               888                                                           '
echo '888  .d88b.  88888b.  888  888 888888 .d88b.  8888 888  .d8888b  8888b.      888d888 .d88b.  '
echo '888 d88""88b 888 "88b 888  888 888   d88""88b "888 888 d88P"        "88b     888P"  d88""88b '
echo '888 888  888 888  888 888  888 888   888  888  888 888 888      .d888888     888    888  888 '
echo '888 Y88..88P 888  888 Y88b 888 Y88b. Y88..88P  888 888 Y88b.    888  888 d8b 888    Y88..88P '
echo '888  "Y88P"  888  888  "Y88888  "Y888 "Y88P"   888 888  "Y8888P "Y888888 Y8P 888     "Y88P"  '
echo '                                               888                                           '
echo '                                              d88P                                           '
echo '                                            888P"                                            '
echo -e "${RCol}"
echo 'GREAT that you install Mautic using this script!'
echo
echo 'Updated for Mautic V5 on Debian V12 by Ionuţ Ojică - https://ionutojica.ro/home/contact/'
echo
echo 'Source created by Matthias Reich - Info@Online-Business-Duplicator.de ( https://online-business-duplicator.de/mautic ).'
echo
echo "==========================================================================================================================="
echo
echo "The subdomain where Mautic will be accessible: ${MAUTIC_SUBDOMAIN}"
echo
echo "The email address from which Mautic will send emails: ${SENDER_EMAIL}"
echo
echo "First and last name of the sender: ${SENDER_FIRSTNAME} ${SENDER_LASTNAME}"
echo
echo "Used time zone: ${SENDER_TIMEZONE}"
echo
if [ ! -z "${MAUTIC_COUNT}" ]; then
  echo "Mautic installation count on this server: ${MAUTIC_COUNT}"
  echo
fi
echo "Administration emails will be sent from: ${FROM_EMAIL} (to $(check_positive "${SEND_PASS_TO_SENDER_EMAIL}" && echo "${SENDER_EMAIL} and to ")${ADMIN_EMAIL})"
echo
if [ "${SSL_CERTIFICATE,,}" == "test" ]; then
  echo 'Debug mode enabled: we will use the option --test-cert to obtain a SSL certificate.'
  echo
elif [ "${SSL_CERTIFICATE,,}" == "yes" ]; then
  echo 'We will try to obtain a SSL certificate.'
  echo
else
  echo 'No SSL certificate will be pulled.'
  echo
fi
echo "==========================================================================================================================="
echo
echo -e "${BRed}I am ready to begin installation. Press ENTER to continue or Ctrl + C to cancel installation..."
echo -e "${RCol}"
read
