#!/bin/bash

###############################################################################################
#####                                 Install Mautic                                      #####
###############################################################################################

show_info ${ICON_INFO} 'Download and install Mautic - this will take time...'

COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_PROCESS_TIMEOUT=10000 \
composer create-project mautic/recommended-project:"${MAUTIC_VERSION}" "${MAUTIC_FOLDER}" \
  --no-interaction > /dev/null 2>&1

if [[ $? -ne 0 ]]; then
  show_info ${ICON_ERR} "Error: Installation of Mautic${MAUTIC_COUNT} failed."
  show_info ${ICON_QUE} "Should the installation continue?"
  answer_yes_else_stop
fi

chown -R www-data:www-data "${MAUTIC_FOLDER}"
chmod -R 755 "${MAUTIC_FOLDER}"

show_info ${ICON_OK} ' done.' 0

show_info ${ICON_INFO} "Installing Mautic extensions listed in config..."

if [[ -n "${MAUTIC_EXTENSIONS[*]}" ]]; then
  show_info ${ICON_INFO} "Preparing to install extensions: ${MAUTIC_EXTENSIONS[*]}"

  # Install all extensions in a single Composer command
  COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_PROCESS_TIMEOUT=10000 \
  composer --working-dir="${MAUTIC_FOLDER}" require "${MAUTIC_EXTENSIONS[@]}" \
    --no-interaction --optimize-autoloader --no-scripts > /dev/null 2>&1

  if [[ $? -ne 0 ]]; then
    show_info ${ICON_ERR} "Error: One or more extensions failed to install."
    show_info ${ICON_QUE} "Should the installation continue?"
    answer_yes_else_stop
  else
    show_info ${ICON_OK} "All extensions installed successfully."
  fi

  chown -R www-data:www-data "${MAUTIC_FOLDER}"
  chmod -R 755 "${MAUTIC_FOLDER}"

else
  show_info ${ICON_WARN} "No Mautic extensions defined in config."
fi
