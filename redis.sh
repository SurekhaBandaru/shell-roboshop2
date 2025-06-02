#!/bin/bash

source ./common.sh
app_name=redis
check_root


#disable default version
dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling redis default version"

#enable default version
dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling redis 7"

#install redis
dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing redis 7"

#change 127.0.0.1 to internet accessible 0.0.0.0
#protectedmode to no
sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "allow remote access and change protected mode to no"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabling redis"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "Starting redis"

print_time