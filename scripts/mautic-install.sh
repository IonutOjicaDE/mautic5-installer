#!/bin/bash

###############################################################################################
#####                                INSTALL MAUTIC 5 SCRIPT                              #####
#####                                    BY IONUT OJICA                                   #####
#####                                    IONUTOJICA.RO                                   #####
###############################################################################################

# Connect to the VPS using command (as an example):
# ssh root@m.ionutojica.ro
# ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@m.ionutojica.ro

# Run with: bash <(wget -qO- https://raw.githubusercontent.com/IonutOjicaDE/mautic5-installer/main/scripts/mautic-install.sh)
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
    echo -e "[$(date +%Y-%m-%d_%H:%M:%S)]  InstallScript  ⌛  (${execution_count}) We continue after ${seconds} second$([[ ${seconds} != 1 ]] && echo "s") ..."
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
TEMP_FOLDER="${PWD}temp/"
FILE_CONF_ORIG="${INSTALL_FOLDER}scripts/mautic-install.conf"
FILE_CONF="${TEMP_FOLDER}mautic-install.conf"
FILE_PASS="${TEMP_FOLDER}mautic.sh"

INSTALL_RESUME_FILE="${PWD}.install_resume"
FORCE_INSTALL=false


mkdir -p "${TEMP_FOLDER}"

show_info ${ICON_INFO} 'Update of the packages...'
DEBIAN_FRONTEND=noninteractive apt-get -yq update >/dev/null
show_info ${ICON_INFO} 'Upgrade of the packages...'
DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade >/dev/null
show_info ${ICON_OK} 'Update and upgrade finished.'

show_info ${ICON_INFO} 'Installing unzip...'
DEBIAN_FRONTEND=noninteractive apt-get -yq install unzip >/dev/null
show_info ${ICON_OK} 'Unzip installed.'


if [[ -e "${PWD}mautic-installer.zip" ]]; then
  rm "${PWD}mautic-installer.zip"
  show_info ${ICON_INFO} 'Old scripts archive removed...'
fi
if [[ -d "${INSTALL_FOLDER}" ]]; then
  rm -r "${INSTALL_FOLDER}"
  show_info ${ICON_INFO} 'Old installation folder removed...'
fi

show_info ${ICON_INFO} 'Downloading scripts and utilities needed for installation...'
wget -q "${URL_TO_ARCHIVE}" -O "${PWD}mautic-installer.zip"
if [[ ! -e "${PWD}mautic-installer.zip" ]]; then
  show_info ${ICON_ERR} 'ERROR: archive with scripts could not be loaded!'
  show_info ${ICON_ERR} "Archive to download: ${URL_TO_ARCHIVE}"
  show_info ${ICON_NOGO} 'Terminating installation!'
  exit 1
fi
unzip -q "${PWD}mautic-installer.zip" -d "${PWD}"
if [[ ! -d "${INSTALL_FOLDER}" ]]; then
  show_info ${ICON_ERR} 'ERROR: downloaded archive with scripts not compatible with this install script!'
  show_info ${ICON_ERR} "Archive to download: ${URL_TO_ARCHIVE}"
  show_info ${ICON_ERR} "Following folder should exist after unziping: ${INSTALL_FOLDER}"
  show_info ${ICON_NOGO} 'Terminating installation!'
  exit 1
fi
rm "${PWD}mautic-installer.zip"
cp ${FILE_CONF_ORIG} ${FILE_CONF}


###############################################################################################
#####                               CHECK PREVIOUS RUNS                                   #####
###############################################################################################


for arg in "$@"; do
  if [[ "$arg" == "--force" ]]; then
    FORCE_INSTALL=true
    show_info ${ICON_INFO} 'Installation starts from beginning, ignoring the previous executions...'
  fi
done


START_FROM=""
if [[ "$FORCE_INSTALL" == false && -f "$INSTALL_RESUME_FILE" ]]; then
  START_FROM=$(<"$INSTALL_RESUME_FILE")
  show_info ${ICON_INFO} "Previous installation failed. Restart from: ${START_FROM}"

  if [[ -e "${FILE_CONF}" ]]; then
    source "${FILE_CONF}"
    show_info ${ICON_INFO} "Configuration file ${FILE_CONF} found and loaded."
  fi

  if [[ -e "${FILE_PASS}" ]]; then
    source "${FILE_PASS}"
    show_info ${ICON_INFO} "Passwords file ${FILE_PASS} found and loaded."
  fi
fi

###############################################################################################
#####                              POPULATE SCRIPTS ARRAY                                 #####
###############################################################################################

install_script_files=()

for file in "${INSTALL_FOLDER}scripts"/script-[a-zA-Z][0-9][0-9]-*.sh; do
  # check that the file exists (avoid the case where the glob doesn't find anything)
  [[ -e "$file" ]] || continue

  filename=$(basename "$file")
  install_script_files+=("$filename")
done

IFS=$'\n' sorted=($(printf "%s\n" "${install_script_files[@]}" | sort))
unset IFS
install_script_files=("${sorted[@]}")


###############################################################################################
#####                           CHOOSE START SCRIPT ON RESTART                            #####
###############################################################################################
# If we restart, offer an interactive selector
if [[ "$FORCE_INSTALL" != true && -f "$INSTALL_RESUME_FILE" ]]; then
  START_FROM=$(<"$INSTALL_RESUME_FILE")
  show_info ${ICON_INFO} "Previous installation failed. Select a script to continue from."

  selected_index=0
  for i in "${!install_script_files[@]}"; do
    if [[ "${install_script_files[$i]}" == "$START_FROM" ]]; then
      selected_index=$i
      break
    fi
  done

  # Function to draw the menu
  draw_menu() {
    clear
    echo -e "\nUse ↑ ↓ arrows to select a script to continue from. Press Enter to confirm. Ctrl+C to cancel.\n"
    for i in "${!install_script_files[@]}"; do
      if [[ $i -eq $selected_index ]]; then
        echo -e " ${BWhi}${On_IBlu}> [${install_script_files[$i]}]${RCol}"
      else
        echo "   ${install_script_files[$i]}"
      fi
    done
  }


  draw_menu

  # Lissen to the keys ↑ ↓ Enter
  while true; do
    read -rsn1 key
    if [[ $key == $'\x1b' ]]; then
      read -rsn2 -t 0.1 key2
      key+="$key2"
    fi

    case "$key" in
      $'\x1b[A') # UP
        (( selected_index-- ))
        (( selected_index < 0 )) && selected_index=$((${#install_script_files[@]} - 1))
        ;;
      $'\x1b[B') # DOWN
        (( selected_index++ ))
        (( selected_index >= ${#install_script_files[@]} )) && selected_index=0
        ;;
      "") # ENTER
        START_FROM="${install_script_files[$selected_index]}"
        break
        ;;
    esac
    draw_menu
  done
fi


###############################################################################################
#####                               EXECUTE SCRIPT FILES                                  #####
###############################################################################################

SKIP=true
for install_script_file in "${install_script_files[@]}"; do
  if [[ "$install_script_file" == "$START_FROM" || "$START_FROM" == "" ]]; then
    SKIP=false
  fi

  if [[ "$SKIP" == true ]]; then
    continue
  fi

  show_info ${ICON_INFO} "Executing ${install_script_file}..." 1

  if ! source "${INSTALL_FOLDER}scripts/${install_script_file}"; then
    show_info ${ICON_INFO} "Error executing ${install_script_file}."
    echo "$install_script_file" > "$INSTALL_RESUME_FILE"
    exit 1
  fi
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
