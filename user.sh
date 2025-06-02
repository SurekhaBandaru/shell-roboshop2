#!/bin/bash

source ./common.sh

app_name=user
check_root
app_setup
setup_nodejs
systemd_setup

print_time
