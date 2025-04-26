#!/bin/bash
VERSION="0.0.3"
show_info ${ICON_INFO} "Start executing ${install_script_file} V${VERSION}." 1

###############################################################################################
#####      Loop to edit and check the configuration file needed for the installation      #####
###############################################################################################

show_info ${ICON_INFO} 'Check if Apache2 is installed...'
if dpkg -l | grep -qw apache2; then
  show_info ${ICON_IMP} 'is installed. Uninstalling...' 0
  systemctl stop apache2
  DEBIAN_FRONTEND=noninteractive apt-get -yq purge apache2 apache2-utils apache2-bin apache2.2-common >/dev/null
  show_info ${ICON_OK} 'done.' 0
else
  show_info ${ICON_OK} 'is not installed.' 0
fi


show_info ${ICON_INFO} 'Installing netcat-openbsd (to check the authentification to the email server trough nc)...'
DEBIAN_FRONTEND=noninteractive apt-get -yq install netcat-openbsd >/dev/null
show_info ${ICON_OK} 'done.' 0

show_info ${ICON_INFO} 'Installing cron (needed for scheduled actions for Mautic / cronjobs)...'
DEBIAN_FRONTEND=noninteractive apt-get -yq install cron >/dev/null
show_info ${ICON_OK} 'done.' 0


show_info ${ICON_INFO} 'Installing the needed packages to add new sources of packages in APT...'
DEBIAN_FRONTEND=noninteractive apt-get -yq install apt-transport-https lsb-release ca-certificates >/dev/null
show_info ${ICON_OK} 'done.' 0

show_info ${ICON_INFO} 'Download and add the GPG key for the php repository from Sury...'
output=$(wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg 2>&1)
if [[ $? -ne 0 ]]; then
  show_info ${ICON_ERR} 'ERROR:' 0
  echo "$output"
  show_info ${ICON_ERR} "Do you want to continue?"
  answer_yes_else_stop && continue
fi
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
show_info ${ICON_OK} 'done.' 0

show_info ${ICON_INFO} 'Update of the packages to include php repository...'
DEBIAN_FRONTEND=noninteractive apt-get -yq update >/dev/null
show_info ${ICON_OK} 'done.' 0


show_info ${ICON_INFO} 'Starting to check the config file ...'

while true; do

  if [[ -r "${FILE_CONF}" ]]; then

    errors=$(bash -n "${FILE_CONF}" 2>&1)
    if [ $? -ne 0 ]; then
      show_info ${ICON_ERR} "The config file '${FILE_CONF}' contains syntax errors:"
      echo "$errors"
      show_info ${ICON_ERR} "Do you want to correct the errors and then try again?"
      answer_yes_else_stop && continue
    fi
    show_info ${ICON_OK} 'Syntax check passed.'

    unset MAUTIC_SUBDOMAIN
    unset SENDER_EMAIL
    unset SENDER_FIRSTNAME
    unset SENDER_LASTNAME
    unset SENDER_TIMEZONE

    unset SSL_CERTIFICATE
    unset SEND_PASS_TO_SENDER_EMAIL

    unset MAUTIC_COUNT
    unset MYSQL_ROOT_PASSWORD
    unset ROOT_USER_PASSWORD

    unset PHP_VERSION
    unset MAUTIC_VERSION
    unset ADMINER_VERSION

    unset ADMIN_EMAIL
    unset FROM_EMAIL
    unset FROM_SERVER_PORT
    unset FROM_USER
    unset FROM_PASS

    source "${FILE_CONF}"

    show_info ${ICON_OK} "Config file ${FILE_CONF} V${VERSION} loaded !"

    if [ -z "${SENDER_FIRSTNAME}" ]; then
      show_info ${ICON_ERR} "First name is empty. Opening the configuration file in the Editor..."
      # Open the Mautic installation configuration file in the Editor. Continue after saving the file and exiting nano.
      nano "${FILE_CONF}"
      continue
    fi

    file_config_errors=0

    if [[ ("${SENDER_FIRSTNAME}" =~ ^[a-zA-Z0-9_]+$) ]]; then
      show_info ${ICON_OK} "First name '${SENDER_FIRSTNAME}' check passed."
    else
      show_info ${ICON_ERR} "First name '${SENDER_FIRSTNAME}' contains non Alphanumeric chars (a...z, A...Z, 0...9) !"
      file_config_errors=1
    fi

    if [[ ("${SENDER_LASTNAME}" =~ ^[a-zA-Z0-9_]+$) ]]; then
      show_info ${ICON_OK} "Last name '${SENDER_LASTNAME}' check passed."
    else
      show_info ${ICON_ERR} "Last name '${SENDER_LASTNAME}' contains non Alphanumeric chars (a...z, A...Z, 0...9) !"
      file_config_errors=1
    fi


    MAUTIC_DOWNLOAD_URL="https://github.com/mautic/mautic/releases/download/${MAUTIC_VERSION}/${MAUTIC_VERSION}.zip"
    if wget --spider "${MAUTIC_DOWNLOAD_URL}" 2>/dev/null; then
      show_info ${ICON_OK} "Mautic version ${MAUTIC_VERSION} found."
    else
      show_info ${ICON_ERR} "Specified Mautic version ${MAUTIC_VERSION} does not exist !"
      file_config_errors=1
    fi


    if [[ -n "${MAUTIC_EXTENSIONS[*]}" ]]; then
      for extension in "${MAUTIC_EXTENSIONS[@]}"; do
        if [[ ! "$extension" =~ ^[a-z0-9._-]+/[a-z0-9._-]+$ ]]; then
          show_info ${ICON_ERR} "Extension '${extension}' has invalid format (should be vendor/package)."
          file_config_errors=1
          continue
        fi
        PACKAGE_NAME=$(echo "$extension" | sed 's/\//%2F/g')
        if curl -s -f "https://repo.packagist.org/p2/${PACKAGE_NAME}.json" > /dev/null; then
          show_info ${ICON_OK} "Extension '${extension}' exists on Packagist."
        else
          show_info ${ICON_ERR} "Extension '${extension}' is NOT valid or not accessible on Packagist!"
          file_config_errors=1
        fi
      done
    else
      show_info ${ICON_INFO} "No Composer extensions defined in MAUTIC_EXTENSIONS."
    fi


    ADMINER_DOWNLOAD_URL="https://github.com/adminerevo/adminerevo/releases/download/v${ADMINER_VERSION}/adminer-${ADMINER_VERSION}.php"
    if wget --spider "${ADMINER_DOWNLOAD_URL}" 2>/dev/null; then
      show_info ${ICON_OK} "Adminer version ${ADMINER_VERSION} found."
    else
      show_info ${ICON_ERR} "Specified Adminer version ${ADMINER_VERSION} does not exist !"
      file_config_errors=1
    fi


    if [ -z "${MAUTIC_COUNT}" ]; then
      show_info ${ICON_OK} "First installation of Mautic on this server."
    elif [[ "${MAUTIC_COUNT}" =~ ^[0-9]+$ ]]; then
      if [ "${MAUTIC_COUNT}" -gt 5 ]; then
        show_info ${ICON_ERR} "MAUTIC_COUNT=${MAUTIC_COUNT}: I strongly do not recommend to install more than 5 Mautic instances on the same server !"
        file_config_errors=1
      elif [ "${MAUTIC_COUNT}" -gt 1 ]; then
        show_info ${ICON_OK}  "Mautic installation count on this server: ${MAUTIC_COUNT}"
      elif [ "${MAUTIC_COUNT}" -eq 1 ]; then
        show_info ${ICON_OK} "First installation of Mautic on this server."
        unset MAUTIC_COUNT
      else
        show_info ${ICON_OK} "I assume this will be first installation of Mautic on this server."
        unset MAUTIC_COUNT
      fi
    else
      show_info ${ICON_ERR} "Please check the value of MAUTIC_COUNT=${MAUTIC_COUNT} inside the config file: should be a value between 1 to 5 or commented out."
      file_config_errors=1
    fi

    if [ -d "/var/www/mautic${MAUTIC_COUNT}" ]; then
      show_info ${ICON_NOGO} "ATTENTION: There is already the ${MAUTIC_COUNT} installation of Mautic on this server! Please choose another instance or uninstall ${MAUTIC_COUNT} Mautic."
      file_config_errors=1
    fi

    if [[ "${MAUTIC_COUNT}" =~ ^[0-9]+$ ]] && [ "${MAUTIC_COUNT}" -gt 1 ]; then
      if [ -z "${MYSQL_ROOT_PASSWORD}" ]; then
        show_info ${ICON_ERR} 'We need the MYSQL_ROOT_PASSWORD. Please put it inside the config file.'
        file_config_errors=1
      else
        show_info ${ICON_OK} 'MYSQL_ROOT_PASSWORD found.'
      fi
      if [ -z "${ROOT_USER_PASSWORD}" ]; then
        show_info ${ICON_ERR} 'We need the ROOT_USER_PASSWORD. Please put it inside the config file.'
        file_config_errors=1
      else
        show_info ${ICON_OK} 'ROOT_USER_PASSWORD found.'
      fi
    fi

    if [ $file_config_errors -ne 0 ] && answer_yes_else_stop "Do you want to correct the errors? Should I open the editor with the config file?"; then
      # Open the Mautic installation configuration file in the Editor. Continue after saving the file and exiting nano.
      nano "${FILE_CONF}"
      continue
    fi

    if [ ! -z "${PHP_VERSION}" ]; then
      if apt-cache show "php${PHP_VERSION}" > /dev/null 2>&1; then
        show_info ${ICON_INFO} "Installing php${PHP_VERSION}..."
        DEBIAN_FRONTEND=noninteractive apt-get -yq install php${PHP_VERSION} >/dev/null
        show_info ${ICON_OK} 'done.' 0
      else
        show_info ${ICON_ERR} "PHP version ${PHP_VERSION} is not available. Do you want to specify another version and then try again?"
        answer_yes_else_stop && continue
      fi
    else
      show_info ${ICON_ERR} "Please check the value of PHP_VERSION=${PHP_VERSION} inside the config file: should be defined."
      file_config_errors=1
    fi


    VALID_TIMEZONE=$(php -r "echo in_array('${SENDER_TIMEZONE}', timezone_identifiers_list()) ? 'yes' : 'no';")
    if [[ "${VALID_TIMEZONE}" == "yes" ]]; then
      show_info ${ICON_OK} "Time zone '${SENDER_TIMEZONE}' is valid."
    else
      show_info ${ICON_ERR} "Time zone '${SENDER_TIMEZONE}' is not valid !"
      file_config_errors=1
    fi


    SERVER=$(echo ${FROM_SERVER_PORT} | cut -d':' -f1)
    PORT=$(echo ${FROM_SERVER_PORT} | cut -d':' -f2)

    if output=$(nc -z -v -w5 "${SERVER}" "${PORT}" 2>&1); then
      show_info "$ICON_OK" "Successfully connected to server $SERVER on port $PORT."
    else
      show_info "$ICON_ERR" "Connecting to server $SERVER on port $PORT is not possible!"
      echo "$output"
      file_config_errors=1
    fi


    if [ $file_config_errors -ne 0 ] && answer_yes_else_stop "Do you want to correct the errors? Should I open the editor with the config file?"; then
      # Open the Mautic installation configuration file in the Editor. Continue after saving the file and exiting nano.
      nano "${FILE_CONF}"
      continue
    fi


    response=$(curl smtp://$FROM_SERVER_PORT -u $FROM_USER:$FROM_PASS -v 2>&1)
    if [[ "$response" == *"Authentication failed"* ]]; then
      show_info ${ICON_ERR} "Authentification to the server ${FROM_SERVER_PORT} for the user ${FROM_USER} failed. Do you want to retry with another authentification data: username and password?"
      answer_yes_else_stop
      nano "${FILE_CONF}"
      continue
    fi
    show_info ${ICON_OK} "Successfully authentificated to server ${FROM_SERVER_PORT} with user ${FROM_USER}."


  else
    if [[ ! -e "${FILE_CONF}" ]]; then
      show_info ${ICON_ERR} 'Config file for the installation does not exists and should be in the downloaded archive...'
      show_info ${ICON_ERR} "Missing config file: ${FILE_CONF} !"
      show_info ${ICON_NOGO} 'Terminating installation!'
      exit 1
    else
      show_info ${ICON_ERR} "ERROR: Can't load config file, check for permissions: ${FILE_CONF} !"
      show_info ${ICON_NOGO} 'Terminating installation!'
      exit 1
    fi

  fi

  break
done

show_info ${ICON_OK} 'Config file loaded !'
