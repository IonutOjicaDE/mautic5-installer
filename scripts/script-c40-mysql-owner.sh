#!/bin/bash
VERSION="0.0.2"
show_info ${ICON_INFO} "Start executing ${install_script_file} V${VERSION}." 1

###############################################################################################
#####                  Assign new contacts to first mautic user by default                #####
###############################################################################################

if false; then # first do nothing

show_info ${ICON_INFO} 'Assign new contacts to first mautic user by default...'

# https://forum.mautic.org/t/default-or-form-contact-owner/14112/2

# MySQL trigger that switches a lead from blank to a certain user ID.
# This lets them be created with a default contact owner but can be updated later to none if needed for whatever reason.

mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -h "localhost" mautic${MAUTIC_COUNT} -e "DELIMITER $$ DROP TRIGGER IF EXISTS \`default_owner\`; CREATE TRIGGER \`default_owner\` BEFORE INSERT ON \`leads\` FOR EACH ROW BEGIN IF NEW.owner_id IS NULL THEN SET NEW.owner_id = 1; END IF; END$$ DELIMITER ;"

show_info ${ICON_OK} 'New contacts will be assigned to first mautic user by default.'

fi
