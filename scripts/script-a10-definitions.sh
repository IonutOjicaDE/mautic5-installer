#!/bin/bash
VERSION="0.0.2"
show_info ${ICON_INFO} "Start executing ${install_script_file} V${VERSION}." 1

###############################################################################################
#####                                      EMPTY                                          #####
###############################################################################################

show_info ${ICON_ERR} "Test of the retry installation."
show_info ${ICON_QUE} "Stop the installation now?"
answer_yes_else_stop
