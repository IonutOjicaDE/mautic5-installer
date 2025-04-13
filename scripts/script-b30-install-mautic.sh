#!/bin/bash

###############################################################################################
#####                                 Install Mautic                                      #####
###############################################################################################

show_info ${ICON_INFO} 'Download and install Mautic - this will take time...'

COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_PROCESS_TIMEOUT=10000 composer create-project mautic/recommended-project:"${MAUTIC_VERSION}" "${MAUTIC_FOLDER}" --no-interaction > /dev/null 2>&1

if [[ $? -ne 0 ]]; then
  show_info ${ICON_ERR} "Error: Installation of Mautic${MAUTIC_COUNT} failed."
  show_info ${ICON_QUE} "Should the installation continue?"
  answer_yes_else_stop
fi

chown -R www-data:www-data "${MAUTIC_FOLDER}"
chmod -R 755 "${MAUTIC_FOLDER}"


show_info ${ICON_INFO} "Installing Mautic extensions listed in config..."

if [[ -n "${MAUTIC_EXTENSIONS[*]}" ]]; then
  for extension in "${MAUTIC_EXTENSIONS[@]}"; do
    show_info ${ICON_INFO} "Installing extension: ${extension}..."

    COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_PROCESS_TIMEOUT=10000 \
    composer --working-dir="${MAUTIC_FOLDER}" require "$extension" --no-interaction > /dev/null 2>&1

    if [[ $? -ne 0 ]]; then
      show_info ${ICON_ERR} "Error: Installation of ${extension} for Mautic${MAUTIC_COUNT} failed."
      show_info ${ICON_QUE} "Should the installation continue?"
      answer_yes_else_stop
    else
      show_info ${ICON_OK} "Extension ${extension} installed successfully."
    fi
  done
else
  show_info ${ICON_WARN} "No Mautic extensions defined in config."
fi

chown -R www-data:www-data "${MAUTIC_FOLDER}"
chmod -R 755 "${MAUTIC_FOLDER}"

show_info ${ICON_OK} 'Mautic is installed.'
