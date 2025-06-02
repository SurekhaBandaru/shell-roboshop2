#!/bin/bash

source ./common.sh

app_name=mongodb
check_root



#till here, everything is normal process
#now the actual process which is related to mongodb will be created

#----------------- Actual script starts --------------

#create a repo file and paste the repo info there eg: mongodb.repo - can be any readable name
# copy the info of mongodb.repo to below location
cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying mongodb repo"
#install mongo db
dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing mongo db server"

#by default mongodb is locally accessible, so we need to change that 127.0.0.1 to internet access 0.0.0.0 at
#/etc/mongod.conf

#enable mongodb
systemctl enable mongod &>>$LOG_FILE

VALIDATE $? "Enabling mongodb" 

#start mongodb
systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Starting mongodb" 

#s -- substiture
#replace (g indicates replace) 127.0.0.1 with 0.0.0.0 at /etc/mongod.conf
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
# $? previously (last) executed command status
VALIDATE $? "Editing mongo db conf file for remote connection"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarting mongodb"

print_time
