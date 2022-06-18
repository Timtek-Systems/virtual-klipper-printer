#!/usr/bin/env bash

#=======================================================================#
# Copyright (C) 2022 mainsail-crew <https://github.com/mainsail-crew>   #
# Author: Dominik Willner <th33xitus@gmail.com>                         #
#                                                                       #
# This file is part of virtual-klipper-printer                          #
# https://github.com/mainsail-crew/virtual-klipper-printer              #
#                                                                       #
# This file may be distributed under the terms of the GNU GPLv3 license #
#=======================================================================#

set -e

REQUIRED_FOLDERS=(
  "${HOME}/klipper_config"
  "${HOME}/klipper_logs"
  "${HOME}/gcode_files"
  "${HOME}/webcam_images"
  "${HOME}/.moonraker_database"
)

function status_msg() {
  echo "###[$(date +%T)]: ${1}"
}

######
# Test for correct ownership of all required folders
###
function check_folder_perms() {
  status_msg "Check folders permissions ..."
  for folder in "${REQUIRED_FOLDERS[@]}"; do
    if [[ $(stat -c "%U" "${folder}") != "printer" ]]; then
      status_msg "chown for user: 'printer' on folder: ${folder}"
      sudo chown printer:printer "${folder}"
    fi
  done
  status_msg "OK!"
}

######
# Copy example configs if ~/klipper_config is empty
###
function copy_example_configs() {
  if [[ ! "$(ls -A "${HOME}/klipper_config")" ]]; then
    status_msg "Directory ${HOME}/klipper_config is empty!"
    status_msg "Copy example configs ..."
    cp -R ~/example-configs/* ~/klipper_config
    status_msg "OK!"
  fi
}

######
# Copy dummy images if ~/webcam_images is empty
###
function copy_dummy_images() {
  if [[ ! "$(ls -A "${HOME}/webcam_images")" ]]; then
    status_msg "Directory ${HOME}/webcam_images is empty!"
    status_msg "Copy dummy images ..."
    cp -R ~/mjpg_streamer_images/*.jpg ~/webcam_images
    status_msg "OK!"
  fi
}

#===================================================#
#===================================================#

[[ ! -e /bin/systemctl ]] && sudo -S ln -s /bin/true /bin/systemctl

check_folder_perms
copy_example_configs
copy_dummy_images

sudo -S rm /bin/systemctl
sudo -S ln -s /bin/service_control /bin/systemctl

cd ~ && status_msg "Everything is ready! Starting ..."
/usr/bin/supervisord