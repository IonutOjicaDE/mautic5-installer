#!/bin/bash

###############################################################################################
#####                                 Customize Mautic                                    #####
###############################################################################################


show_info ${ICON_INFO} 'Customize Mautic...'

LOCAL_PHP="${MAUTIC_FOLDER}config/local.php"

declare -A PARAMS_TO_ADD=(
  ["default_timezone"]="${SENDER_TIMEZONE}"
  ["date_format_full"]="j F Y H:i:s"
  ["date_format_short"]="D, d M"
  ["date_format_dateonly"]="j.m.Y"
  ["date_format_timeonly"]="H:i:s"
  ["mailer_from_name"]="${SENDER_FIRSTNAME} ${SENDER_LASTNAME}"
  ["mailer_from_email"]="${SENDER_EMAIL}"
)

if [[ ! -f "$LOCAL_PHP" ]]; then
  show_info ${ICON_ERR} "${LOCAL_PHP} not found. Do you want to continue?"
  answer_yes_else_stop
else

  new_content=""

  while IFS= read -r line; do
    if [[ "$line" == ");" ]]; then
      for key in "${!PARAMS_TO_ADD[@]}"; do
        if ! grep -q "'$key'" <<< "$new_content"; then
          new_content+=$'\t'"'$key' => '${PARAMS_TO_ADD[$key]}',"$'\n'
        fi
      done
    fi
    new_content+="$line"$'\n'
  done < "$LOCAL_PHP"

  printf "%s" "$new_content" > "$LOCAL_PHP"


  chown -R www-data:www-data "${MAUTIC_FOLDER}"
  chmod -R 755 "${MAUTIC_FOLDER}"

  show_info ${ICON_OK} 'Mautic customized.'

fi
