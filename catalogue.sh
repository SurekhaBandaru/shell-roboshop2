#!/bin/bash

source ./common.sh
app_name=catalogue

check_root

#till here, everything is normal process
#now the actual process which is related to mongodd will be created

#----------------- Actual script starts --------------
app_setup
setup_nodejs

#we face issues-failures when we run this entire script from second time onwards, it is good to check roboshop already created or not

systemd_setup

#systemctl restart catalogue &>>$LOG_FILE
#VALIDATE $? "Restart Catalogue service"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copy mongo db repo content..."

dnf install mongodb-mongosh -y &>>$LOG_FILE

VALIDATE $? "Installing mongo client"

#Load data only if catalogue db exists - it will us the index of catalogue db
STATUS=$(mongosh --host mongodb.devopspract.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
#indices starts from 0
if [ $STATUS -lt 0 ]; then
    mongosh --host mongodb.devopspract.site </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading data into mongodb"
else
    echo -e "Data is already loaded...$Y SKIPPING $N"
fi

print_time