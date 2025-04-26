#!/bin/bash
VERSION="0.0.3"
show_info ${ICON_INFO} "Start executing ${install_script_file} V${VERSION}" 1

###############################################################################################
#####                           Personalize Mautic raw files                              #####
###############################################################################################

if false; then # first do nothing

# Script name with extension and absolute path
path_scriptName_ext=$(readlink -f "$0")
# The absolute path of the script, terminated with "/"
path_script=$(dirname "$path_scriptName_ext")/
# Script name with extension, but no path
scriptName_ext=$(basename "$path_scriptName_ext")
# Script name without extension
scriptName="${scriptName_ext%.sh}"

if [ -z "${MAUTIC_FOLDER}" ]; then
  current_dir=$(dirname "$(readlink -f "$0")")
  source "${current_dir}/mautic.sh"
else
  cp "${path_scriptName_ext}" "${CRON_FOLDER}"
  cp "${path_script}${scriptName}.perl" "${CRON_FOLDER}"
fi

perl -s "${path_script}${scriptName}.perl" "${MAUTIC_FOLDER}" "${MAUTIC_SUBDOMAIN}"

runuser -u www-data -- php "${MAUTIC_FOLDER}bin/console" cache:clear --no-interaction --no-warmup
runuser -u www-data -- php "${MAUTIC_FOLDER}bin/console" mautic:assets:generate

fi
