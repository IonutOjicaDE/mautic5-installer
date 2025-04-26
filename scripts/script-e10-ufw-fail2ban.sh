#!/bin/bash
VERSION="0.0.3"
show_info ${ICON_INFO} "Start executing ${install_script_file} V${VERSION}." 1

###############################################################################################
#####                               Install ufw and fail2ban                              #####
###############################################################################################


if [ -z "${MAUTIC_COUNT}" ]; then

  show_info ${ICON_INFO} 'Installing ufw (Firewall) and allow only ssh, http and https...'
  errors=()
  DEBIAN_FRONTEND=noninteractive apt-get -yq install ufw >/dev/null 2>&1 || errors+=("Installing ufw.")
  ufw allow ssh >/dev/null 2>&1 || errors+=("ufw allow ssh.")
  ufw allow 80 >/dev/null 2>&1 || errors+=("ufw allow 80.")
  ufw allow 443 >/dev/null 2>&1 || errors+=("ufw allow 443.")
  ufw --force enable >/dev/null 2>&1 || errors+=("ufw --force enable.")

  if [[ ${#errors[@]} -gt 0 ]]; then
    show_info ${ICON_ERR} "ERROR:"
    for err in "${errors[@]}"; do
      show_info ${ICON_NOGO} "$err"
    done

    show_info ${ICON_QUE} "Should we continue installation?"
    answer_yes_else_stop
  else
    show_info ${ICON_OK} 'done.' 0
  fi

  show_info ${ICON_INFO} 'Installing fail2ban (against BruteForce attacks)...'
  errors=()
  DEBIAN_FRONTEND=noninteractive apt-get -yq install fail2ban >/dev/null 2>&1 || errors+=("Installing fail2ban.")
  cp /etc/fail2ban/jail.{conf,local} >/dev/null 2>&1 || errors+=("Copy conf file.")
  sed -i "s|bantime  = 10m|bantime  = 1d|g" /etc/fail2ban/jail.local >/dev/null 2>&1 || errors+=("Increase ban time from 10m to 1d.")
  systemctl restart fail2ban >/dev/null 2>&1 || errors+=("systemctl restart fail2ban.")

  if [[ ${#errors[@]} -gt 0 ]]; then
    show_info ${ICON_ERR} "ERROR:"
    for err in "${errors[@]}"; do
      show_info ${ICON_NOGO} "$err"
    done

    show_info ${ICON_QUE} "Should we continue installation?"
    answer_yes_else_stop
  else
    show_info ${ICON_OK} 'done.' 0
  fi

else

  if dpkg -l | grep -qw ufw; then
    show_info ${ICON_OK} 'Ufw (Firewall) is already installed.'
  else
    show_info ${ICON_ERR} "Error: Ufw (Firewall) should already be installed, when installing ${MAUTIC_COUNT} instance of Mautic !"
    exit 1
  fi
  if dpkg -l | grep -qw fail2ban; then
    show_info ${ICON_OK} 'fail2ban is already installed.'
  else
    show_info ${ICON_ERR} "Error: fail2ban should already be installed, when installing ${MAUTIC_COUNT} instance of Mautic !"
    exit 1
  fi

fi
