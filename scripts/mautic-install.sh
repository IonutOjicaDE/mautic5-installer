#!/bin/bash
VERSION="0.0.8"

###############################################################################################
#####                                INSTALL MAUTIC 5 SCRIPT                              #####
#####                                    BY IONUT OJICA                                   #####
#####                                    IONUTOJICA.RO                                   #####
###############################################################################################

# Connect to the VPS using command (as an example):
# ssh root@m.ionutojica.ro
# ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@m.ionutojica.ro

# Run with:
# bash <(wget -qO- "https://raw.githubusercontent.com/IonutOjicaDE/mautic5-installer/main/scripts/mautic-install.sh?$(date +%s)")
# or
# filename="mautic-install-$(date +%Y%m%d-%H%M%S).sh"; wget -qO "$filename" https://raw.githubusercontent.com/IonutOjicaDE/mautic5-installer/main/scripts/mautic-install.sh && bash "$filename"

# ✅ ❌ ❓ ❗ ❎ ⛔ 🛈 ℹ️ 📝

###############################################################################################
#####                              DEFINE COLORS AS NAMES                                 #####
###############################################################################################

echo "[$(date +%Y-%m-%d_%H:%M:%S)]  InstallScript  📝  Start executing mautic-install.sh V${VERSION}."

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
ICON_WARN='⚠️' # ${ICON_WARN}
ICON_QUE='❓'  # ${ICON_QUE}
ICON_IMP='❗'  # ${ICON_IMP}
ICON_NOGO='⛔' # ${ICON_NOGO}

execution_count=0
LAST_COMMENT=ICON_INFO

function show_info() {
  local state="$1"
  local comment="$2"
  local seconds="$3"

  local now="[$(date +%Y-%m-%d_%H:%M:%S)]  InstallScript"

  if [[ "$seconds" =~ ^[1-9]$ ]]; then
    execution_count=$((execution_count + 1))
    echo -e "\n${BCya}${now}  ${state}  (${execution_count}) ${comment}; waiting for ${seconds} second$([[ ${seconds} != 1 ]] && echo "s") ..."

    line=$(printf '%.0s.' {1..100})
    printf "%s\r" "${line}"
    for ((i=1; i<=100; i++)); do
      line="${line:0:i-1}=${line:i}"
      printf "%s\r" "${line}"
      sleep "0.0${seconds}"
    done

    echo -e "${RCol}"
  else
    if [[ "$seconds" == 0 ]]; then
      tput cuu1 && tput el
      echo -e "${BCya}${now}  ${state}  ${LAST_COMMENT} ${comment}${RCol}"
    else
      echo -e "${BCya}${now}  ${state}  ${comment}${RCol}"
    fi
  fi
  LAST_COMMENT="$comment"
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

show_info ${ICON_OK} 'Definitions loaded.'


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
show_info ${ICON_OK} 'done.' 0
show_info ${ICON_INFO} 'Upgrade of the packages...'
DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade >/dev/null
show_info ${ICON_OK} 'done.' 0

show_info ${ICON_INFO} 'Installing unzip...'
DEBIAN_FRONTEND=noninteractive apt-get -yq install unzip >/dev/null
show_info ${ICON_OK} 'done.' 0


if [[ -e "${PWD}mautic-installer.zip" ]]; then
  rm "${PWD}mautic-installer.zip"
  show_info ${ICON_OK} 'Old scripts archive removed.'
fi
if [[ -d "${INSTALL_FOLDER}" ]]; then
  rm -r "${INSTALL_FOLDER}"
  show_info ${ICON_OK} 'Old installation folder removed.'
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
if [[ ! -e "${FILE_CONF}" ]]; then
  cp "${FILE_CONF_ORIG}" "${FILE_CONF}"
fi
show_info ${ICON_OK} 'done.' 0


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
  show_info ${ICON_OK} "Previous installation failed. Restart from: ${START_FROM}"

  if [[ -e "${FILE_CONF}" ]]; then
    source "${FILE_CONF}"
    show_info ${ICON_OK} "Configuration file ${FILE_CONF} found and loaded."
  fi

  if [[ -e "${FILE_PASS}" ]]; then
    source "${FILE_PASS}"
    show_info ${ICON_OK} "Passwords file ${FILE_PASS} found and loaded."
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

  # Find the index of the selected script in the array
  selected_index=0
  max_length=0
  for i in "${!install_script_files[@]}"; do
    name="${install_script_files[$i]}"
    if [[ "$name" == "$START_FROM" ]]; then
      selected_index=$i
    fi
    len=${#name}
    (( len > max_length )) && max_length=$len
  done

  # Take the size of the terminal
  rows=$(tput lines)
  cols=$(tput cols)

  # Count the options from the menu
  menu_items_count=${#install_script_files[@]}

  # Vertical lines needed: 6 (title + text + 2 margins) + 1 line per option
  menu_height=$((menu_items_count + 6))

  # Asure that we do not exceed the height of the terminal
  if (( menu_height > rows - 2 )); then
    menu_height=$((rows - 2))
  fi

  # Height of the options in the menu
  menu_display_height=$((menu_height - 6))

  # Min recomended width
  menu_width=$(( (max_length + 20) < cols ? (max_length + 20) : cols ))

  # Create the menu options
  whiptail_options=()
  for i in "${!install_script_files[@]}"; do
    whiptail_options+=("$i" "${install_script_files[$i]}")
  done

  # Display the menu
  tput sc
  choice=$(whiptail --title 'Continue installation' \
    --default-item "$selected_index" \
    --menu "Choose the script to continue from:" "$menu_height" "$menu_width" "$menu_display_height" \
    "${whiptail_options[@]}" \
    3>&1 1>&2 2>&3)
  tput rc
  tput ed

  # Check if the user pressed Cancel
  if [[ $? -eq 0 ]]; then
    START_FROM="${install_script_files[$choice]}"
    show_info ${ICON_INFO} "You chose to continue from: $START_FROM"
  else
    show_info ${ICON_IMP} 'You canceled the installation.'
    exit 1
  fi
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

  echo "$install_script_file" > "$INSTALL_RESUME_FILE"

  if ! source "${INSTALL_FOLDER}scripts/${install_script_file}"; then
    show_info ${ICON_INFO} "Error executing ${install_script_file}."
    exit 1
  fi
done

if [[ -f "$INSTALL_RESUME_FILE" ]]; then
  rm "$INSTALL_RESUME_FILE"
  show_info ${ICON_INFO} "File $INSTALL_RESUME_FILE has been deleted."
fi

show_info ${ICON_INFO} 'Removing installation folder...'
rm -rf "${INSTALL_FOLDER}"
show_info ${ICON_OK} 'done.' 0
show_info ${ICON_OK} "Execution of installation script finished. Enjoy Mautic ${MAUTIC_VERSION} !"

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
