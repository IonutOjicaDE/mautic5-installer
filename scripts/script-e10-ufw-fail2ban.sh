#!/bin/bash
VERSION="0.0.2"
show_info ${ICON_INFO} "Start executing ${install_script_file} V${VERSION}." 1

###############################################################################################
#####                               Install ufw and fail2ban                              #####
###############################################################################################


if [ -z "${MAUTIC_COUNT}" ]; then

  show_info ${ICON_INFO} 'Installing ufw (Firewall)...'
  DEBIAN_FRONTEND=noninteractive apt-get -yq install ufw >/dev/null
  ufw allow ssh 
  ufw allow 80
  ufw allow 443
  ufw --force enable
  show_info ${ICON_OK} 'ufw (Firewall) is installed.'

  show_info ${ICON_INFO} 'Installing fail2ban (against BruteForce attacks)...'
  DEBIAN_FRONTEND=noninteractive apt-get -yq install fail2ban >/dev/null
  cp /etc/fail2ban/jail.{conf,local}
  sed -i "s|bantime  = 10m|bantime  = 1d|g" /etc/fail2ban/jail.local
  systemctl restart fail2ban
  show_info ${ICON_OK} 'fail2ban is installed.'

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
