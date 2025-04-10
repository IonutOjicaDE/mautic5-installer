#!/bin/bash

###############################################################################################
#####                        Clear temporary and not needed files                         #####
###############################################################################################

composer remove mautic/core-project-message

show_info ${ICON_INFO} 'Autoremove of not needed packages...'
DEBIAN_FRONTEND=noninteractive apt-get -yq autoremove >/dev/null
show_info ${ICON_INFO} 'Clear cache of installed packages...'
DEBIAN_FRONTEND=noninteractive apt-get -yq clean >/dev/null
show_info ${ICON_OK} 'Autoremove and clean finished.'
