#!/bin/bash

###############################################################################################
#####                                INSTALL MAUTIC 5 SCRIPT                              #####
#####                                    BY IONUT OJICA                                   #####
#####                                    IONUTOJICA.COM                                   #####
###############################################################################################


#Run with: bash <(wget -qO- https://raw.githubusercontent.com/IonutOjicaDE/mautic4-installer/main/scripts/mautic-install.sh)
# ✅ ❌ ❓ ❗ ❎ ⛔ 🛈 ℹ️ 📝

###############################################################################################
#####                              DEFINE COLORS AS NAMES                                 #####
###############################################################################################

echo "[$(date +%Y-%m-%d_%H:%M:%S)]  InstallScript  📝  Loading definitions ..."

RCol='\e[0m'    # Text Reset

# Regular           Bold                Underline           High Intensity      BoldHigh Intens     Background          High Intensity Backgrounds
Bla='\e[0;30m';     BBla='\e[1;30m';    UBla='\e[4;30m';    IBla='\e[0;90m';    BIBla='\e[1;90m';   On_Bla='\e[40m';    On_IBla='\e[0;100m';
Red='\e[0;31m';     BRed='\e[1;31m';    URed='\e[4;31m';    IRed='\e[0;91m';    BIRed='\e[1;91m';   On_Red='\e[41m';    On_IRed='\e[0;101m';
Gre='\e[0;32m';     BGre='\e[1;32m';    UGre='\e[4;32m';    IGre='\e[0;92m';    BIGre='\e[1;92m';   On_Gre='\e[42m';    On_IGre='\e[0;102m';
Yel='\e[0;33m';     BYel='\e[1;33m';    UYel='\e[4;33m';    IYel='\e[0;93m';    BIYel='\e[1;93m';   On_Yel='\e[43m';    On_IYel='\e[0;103m';
Blu='\e[0;34m';     BBlu='\e[1;34m';    UBlu='\e[4;34m';    IBlu='\e[0;94m';    BIBlu='\e[1;94m';   On_Blu='\e[44m';    On_IBlu='\e[0;104m';
Pur='\e[0;35m';     BPur='\e[1;35m';    UPur='\e[4;35m';    IPur='\e[0;95m';    BIPur='\e[1;95m';   On_Pur='\e[45m';    On_IPur='\e[0;105m';
Cya='\e[0;36m';     BCya='\e[1;36m';    UCya='\e[4;36m';    ICya='\e[0;96m';    BICya='\e[1;96m';   On_Cya='\e[46m';    On_ICya='\e[0;106m';
Whi='\e[0;37m';     BWhi='\e[1;37m';    UWhi='\e[4;37m';    IWhi='\e[0;97m';    BIWhi='\e[1;97m';   On_Whi='\e[47m';    On_IWhi='\e[0;107m';

###############################################################################################
#####                             DEFINE USEFULL FUNCTIONS                                #####
###############################################################################################

ICON_OK='✅'   # ${ICON_OK}
ICON_ERR='❌'  # ${ICON_ERR}
ICON_INFO='📝' # ${ICON_INFO}
ICON_QUE='❓'  # ${ICON_QUE}
ICON_IMP='❗'  # ${ICON_IMP}
ICON_NOGO='⛔' # ${ICON_NOGO}

execution_count=0

function show_info() {
  local state="$1"
  local comment="$2"
  local seconds="$3"

  if [[ "$seconds" =~ ^[1-9]$ ]]; then
    execution_count=$((execution_count + 1))
    echo -e "\n${BCya}[$(date +%Y-%m-%d_%H:%M:%S)]  InstallScript  ${state}  ${comment}"
    echo -e "[$(date +%Y-%m-%d_%H:%M:%S)]  InstallScript  ⌛  (${execution_count}) We continue after ${seconds} second$([[ $seconds != 1 ]] && echo "s") ..."
    echo -e "${RCol}"

    line=$(printf '%.0s.' {1..100})
    printf "%s\r" "${line}"
    for ((i=1; i<=100; i++)); do
      line="${line:0:i-1}=${line:i}"
      printf "%s\r" "${line}"
      sleep "0.0${seconds}"
    done

    echo -e "\n"
  else
    echo -e "${BCya}[$(date +%Y-%m-%d_%H:%M:%S)]  InstallScript  ${state}  ${comment}${RCol}"
  fi
}

show_debug() {
	execution_count=$((execution_count + 1))
	echo ; echo ; echo -e "${BCya}${execution_count}. $1 : ⌛ We continue after 1 second ..."; echo -e "${RCol}"; echo ; sleep 1
}


function answer_yes_else_stop() {
  show_info ${ICON_QUE} "$1"
  read -p 'Answer: ' answer
  if ! check_positive "${answer}"; then
    exit 1
  fi
  return 0
}

function check_positive() {
  local answer="$1"
  if [[ "${answer,,}" == 'da' || "${answer,,}" == 'yes' || "${answer,,}" == 'y' || "${answer,,}" == '1' ]]; then
    return 0
  fi
  return 1
}

show_info ${ICON_OK} 'Definitions loaded !'


###############################################################################################
#####                                  GET SCRIPT FILES                                   #####
###############################################################################################

URL_TO_ARCHIVE='https://github.com/IonutOjicaDE/mautic5-installer/archive/refs/heads/main.zip'
PWD="$(pwd)/"
INSTALL_FOLDER="${PWD}mautic5-installer-main/"
FILE_CONF="${INSTALL_FOLDER}scripts/mautic-install.conf"

show_info ${ICON_INFO} 'Update of the packages...'
DEBIAN_FRONTEND=noninteractive apt-get -yq update >/dev/null
show_info ${ICON_INFO} 'Upgrade of the packages...'
DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade >/dev/null
show_info ${ICON_OK} 'Update and upgrade finished.'
#DEBIAN_FRONTEND=noninteractive apt-get -yq autoremove
#DEBIAN_FRONTEND=noninteractive apt-get -yq clean

show_info ${ICON_INFO} 'Installing unzip...'
DEBIAN_FRONTEND=noninteractive apt-get -yq install unzip >/dev/null
show_info ${ICON_OK} 'Unzip installed.'


if [[ -e "${PWD}mautic5-installer.zip" ]]; then
  rm "${PWD}mautic5-installer.zip"
  show_info ${ICON_INFO} 'Old scripts archive removed...'
fi
if [[ -d "${INSTALL_FOLDER}" ]]; then
  rm -r "${INSTALL_FOLDER}"
  show_info ${ICON_INFO} 'Old installation folder removed...'
fi

show_info ${ICON_INFO} 'Downloading scripts and utilities needed for installation...'
wget -q "${URL_TO_ARCHIVE}" -O "${PWD}mautic5-installer.zip"
if [[ ! -e "${PWD}mautic5-installer.zip" ]]; then
  show_info ${ICON_ERR} 'ERROR: archive with scripts could not be loaded!'
  show_info ${ICON_ERR} "Archive to download: ${URL_TO_ARCHIVE}"
  show_info ${ICON_NOGO} 'Terminating installation!'
  exit 1
fi
unzip -q "${PWD}mautic5-installer.zip" -d "${PWD}"
if [[ ! -d "${INSTALL_FOLDER}" ]]; then
  show_info ${ICON_ERR} 'ERROR: downloaded archive with scripts not compatible with this install script!'
  show_info ${ICON_ERR} "Archive to download: ${URL_TO_ARCHIVE}"
  show_info ${ICON_ERR} "Following folder should exist after unziping: ${INSTALL_FOLDER}"
  show_info ${ICON_NOGO} 'Terminating installation!'
  exit 1
fi
rm "${PWD}mautic5-installer.zip"


###############################################################################################
#####                               EXECUTE SCRIPT FILES                                  #####
###############################################################################################

install_script_files=(
  'script-a10-definitions.sh'
  'script-a20-precheck.sh'
  'script-a30-input-values.sh'
  'script-a40-create-pass.sh'
  'script-b10-update-nginx-mariadb.sh'
  'script-b20-install-php-default-conf.sh'
  'script-b30-install-mautic.sh'
  'script-b40-install-adminer.sh'
  'script-c10-database-certbot.sh'
  'script-c20-install-theme.sh'
  'script-c30-mysql-localphp.sh'
  'script-c32-mysql-owner.sh'
  'script-c40-plugins.sh'
  'script-d10-adjusting.sh'
  'script-e10-ufw-fail2ban.sh'
  'script-e20-crons.sh'
  'script-e30-send-pass-to-email.sh'
  'script-e40-summary.sh'
)

for install_script_file in "${install_script_files[@]}"; do
  show_info ${ICON_INFO} "Executing ${install_script_file}..." 1
  source "${INSTALL_FOLDER}scripts/${install_script_file}"
done

show_info ${ICON_INFO} 'Removing installation folder...'
rm -rf "${INSTALL_FOLDER}"
show_info ${ICON_OK} 'Installation folder removed. Execution of installation script finished.'

####################################################################################
#              IonutOjica: External resources to create the script:                #
#                                                                                  #
# Source script from Matthias Reich - Info@Online-Business-Duplicator.de           #
# https://online-business-duplicator.de/mautic                                     #
#                                                                                  #
# https://github.com/littlebizzy/slickstack/blob/master/bash/ss-install.txt        #
#                                                                                  #
# https://stackoverflow.com/questions/16843382/colored-shell-script-output-library #
#                                                                                  #
####################################################################################
