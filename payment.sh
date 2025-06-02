#!/bin/bash

source ./common.sh

app_name=payment
check_root

app_setup

setup_python

systemd_setup

print_time
