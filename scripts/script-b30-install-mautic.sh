#!/bin/bash
VERSION="0.0.3"
show_info ${ICON_INFO} "Start executing ${install_script_file} V${VERSION}." 1

###############################################################################################
#####                                 Install Mautic                                      #####
###############################################################################################

show_info ${ICON_INFO} 'Download and install Mautic - this will take time (~2 min)...'

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

show_info ${ICON_OK} 'done.' 0


if [[ -n "${MAUTIC_EXTENSIONS[*]}" ]]; then
  show_info ${ICON_INFO} "Installing extensions: ${MAUTIC_EXTENSIONS[*]}..."

  # Install all extensions in a single Composer command
  COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_PROCESS_TIMEOUT=10000 \
  composer --working-dir="${MAUTIC_FOLDER}" require "${MAUTIC_EXTENSIONS[@]}" \
    --no-interaction --optimize-autoloader --no-scripts > /dev/null 2>&1

  if [[ $? -ne 0 ]]; then
    show_info ${ICON_ERR} " failed." 0
    show_info ${ICON_QUE} "Should we try installing one after the other to find out which one failed?"
    answer_yes_else_stop

    for extension in "${MAUTIC_EXTENSIONS[@]}"; do
      show_info ${ICON_INFO} "Installing extension: ${extension}..."
      COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_PROCESS_TIMEOUT=10000 \
      composer --working-dir="${MAUTIC_FOLDER}" require "${extension}" \
        --no-interaction --optimize-autoloader --no-scripts > /dev/null 2>&1

      if [[ $? -ne 0 ]]; then
        show_info ${ICON_ERR} " failed." 0
        show_info ${ICON_QUE} "Should we continue with the next extension?"
        answer_yes_else_stop
      else
        show_info ${ICON_OK} 'done.' 0
      fi
    done
  else
    show_info ${ICON_OK} 'done.' 0
  fi

  chown -R www-data:www-data "${MAUTIC_FOLDER}"
  chmod -R 755 "${MAUTIC_FOLDER}"

else
  show_info ${ICON_OK} "No Mautic extensions defined in config file to install."
fi
