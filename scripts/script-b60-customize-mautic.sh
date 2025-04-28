#!/bin/bash
VERSION="0.0.5"
show_info ${ICON_INFO} "Start executing ${install_script_file} V${VERSION}" 1

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

  ["brand_name"]="${SENDER_FIRSTNAME} ${SENDER_LASTNAME}"

	["do_not_track_404_anonymous"]="1"
	["track_by_tracking_url"]="1"
	["anonymize_ip"]="1"
# 'anonymize_ip_address_in_background' => false,
# php bin/console mautic:ip-anonymize
	["track_contact_by_ip"]="0"
  ["brand_name"]="${SENDER_FIRSTNAME} ${SENDER_LASTNAME}"

	["background_import_if_more_rows_than"]="50"
# 'import_leads_dir' => '/var/www/mautic/var/import',
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


  mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -h "localhost" mautic${MAUTIC_COUNT} << EOF
DELETE FROM lead_fields WHERE alias IN ('fax', 'facebook', 'foursquare', 'instagram', 'linkedin', 'skype', 'twitter', 'companyfax');

UPDATE lead_fields SET is_published = 0 WHERE alias IN (
  'company', 'phone', 'address2', 'companyaddress1', 'companyaddress2',
  'companyemail', 'companyphone', 'companycity', 'companystate',
  'companyzipcode', 'companycountry', 'companyname', 'companywebsite',
  'companynumber_of_employees', 'companyannual_revenue', 'companyindustry', 
  'companydescription', 'position');

UPDATE lead_fields SET field_order = 10 WHERE alias = 'website';
UPDATE lead_fields SET field_order = 23 WHERE alias = 'companyname';
UPDATE lead_fields SET field_order = 24 WHERE alias = 'companyemail';
UPDATE lead_fields SET field_order = 25 WHERE alias = 'companyphone';
UPDATE lead_fields SET field_order = 26 WHERE alias = 'companywebsite';
UPDATE lead_fields SET field_order = 27 WHERE alias = 'companyaddress1';
UPDATE lead_fields SET field_order = 28 WHERE alias = 'companyaddress2';
UPDATE lead_fields SET field_order = 29 WHERE alias = 'companycity';
UPDATE lead_fields SET field_order = 30 WHERE alias = 'companystate';
UPDATE lead_fields SET field_order = 31 WHERE alias = 'companyzipcode';
UPDATE lead_fields SET field_order = 32 WHERE alias = 'companycountry';
UPDATE lead_fields SET field_order = 33 WHERE alias = 'companyindustry';
UPDATE lead_fields SET field_order = 34 WHERE alias = 'companynumber_of_employees';
UPDATE lead_fields SET field_order = 35 WHERE alias = 'companyannual_revenue';
UPDATE lead_fields SET field_order = 36 WHERE alias = 'companydescription';
EOF


  show_info ${ICON_OK} 'done.' 0

fi
