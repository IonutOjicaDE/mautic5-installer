#!/bin/bash

###############################################################################################
#####                        Creating passwords and saving the files                      #####
###############################################################################################

if [ -z "${MYSQL_ROOT_PASSWORD}" ]; then
      MYSQL_ROOT_PASSWORD=$(tr -dc 'A-Za-z0-9_#=+*;:,.-' < /dev/urandom | head -c40)
fi
if [ -z "${ROOT_USER_PASSWORD}" ]; then
       ROOT_USER_PASSWORD=$(tr -dc 'A-Za-z0-9_#=+*;:,.-' < /dev/urandom | head -c40)
fi
MYSQL_MAUTICUSER_PASSWORD=$(tr -dc 'A-Za-z0-9_#=+*;:,.-' < /dev/urandom | head -c40)
        MAUTIC_SECRET_KEY=$(tr -dc 'a-f0-9' < /dev/urandom | head -c64)
    MAUTIC_REMEMBERME_KEY=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c40)
    MAUTIC_ADMIN_PASSWORD=$(tr -dc 'A-Za-z0-9_#=+*;:,.-' < /dev/urandom | head -c40)

 MAUTIC_COMMANDS_PASSWORD=$(tr -dc 'A-Za-z0-9_#=+*;:,.-' < /dev/urandom | head -c40)
              MAIN_DOMAIN=$(echo "$MAUTIC_SUBDOMAIN" | cut -d'.' -f2-)
          MAUTIC_USERNAME=$(echo "$MAUTIC_SUBDOMAIN" | sed 's/\.//g')

            MAUTIC_FOLDER="/var/www/mautic${MAUTIC_COUNT}/"
           DOCROOT_FOLDER="${MAUTIC_FOLDER}docroot/"
              CRON_FOLDER="${MAUTIC_FOLDER}crons/"
      BACKUP_FILES_FOLDER="${MAUTIC_FOLDER}backups/"
        ROOT_FILES_FOLDER="/usr/local/bin/"

show_info ${ICON_OK} 'Passwords created. Saving the passwords in .sh, .php, .txt files...'

content_file_sh="
MAIN_DOMAIN='${MAIN_DOMAIN}'
MAUTIC_SUBDOMAIN='${MAUTIC_SUBDOMAIN}'
SENDER_EMAIL='${SENDER_EMAIL}'
SENDER_FIRSTNAME='${SENDER_FIRSTNAME}'
SENDER_LASTNAME='${SENDER_LASTNAME}'

MAUTIC_FOLDER='${MAUTIC_FOLDER}'
DOCROOT_FOLDER='${DOCROOT_FOLDER}'
CRON_FOLDER='${CRON_FOLDER}'
BACKUP_FILES_FOLDER='${BACKUP_FILES_FOLDER}'
ROOT_FILES_FOLDER='${ROOT_FILES_FOLDER}'

MAUTIC_COUNT='${MAUTIC_COUNT}'
MYSQL_ROOT_PASSWORD='${MYSQL_ROOT_PASSWORD}'
MYSQL_MAUTICUSER_PASSWORD='${MYSQL_MAUTICUSER_PASSWORD}'

MAUTIC_SECRET_KEY='${MAUTIC_SECRET_KEY}'
MAUTIC_REMEMBERME_KEY='${MAUTIC_REMEMBERME_KEY}'

MAUTIC_USERNAME='${MAUTIC_USERNAME}'
MAUTIC_ADMIN_PASSWORD='${MAUTIC_ADMIN_PASSWORD}'

ROOT_USER_PASSWORD='${ROOT_USER_PASSWORD}'

MAUTIC_COMMANDS_PASSWORD='${MAUTIC_COMMANDS_PASSWORD}'

ADMIN_EMAIL='${ADMIN_EMAIL}'

FROM_EMAIL='${FROM_EMAIL}'
FROM_SERVER_PORT='${FROM_SERVER_PORT}'
FROM_USER='${FROM_USER}'
FROM_PASS='${FROM_PASS}'
"
printf "#!/bin/bash\n%s\n" "${content_file_sh}" > "${TEMP_FOLDER}mautic.sh"

show_info ${ICON_OK} 'Passwords saved in .sh file.'


content_file_php=""
content_file_txt=""
while IFS= read -r current_line; do
  if [[ "${current_line}" == *=* ]]; then
    key="${current_line%%=*}"
    value="${!key}"
    content_file_php+="\$${key}='${value}';"$'\n'
    content_file_txt+="${key} = ${value}"$'\n'
  else
    content_file_php+="${current_line}"$'\n'
    content_file_txt+="${current_line}"$'\n'
  fi
done <<< "${content_file_sh}"

printf "<?php\n%s\n?>" "${content_file_php}" > "${TEMP_FOLDER}mautic.php"
printf "${content_file_txt}" > "${TEMP_FOLDER}mautic.txt"

show_info ${ICON_OK} 'Passwords saved in .php and .txt files.'
