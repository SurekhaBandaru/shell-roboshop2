#!/bin/bash

source ./common.sh
app_name=shipping
check_root
app_setup

echo "Enter password to connect mysql"
read -s MYSQL_ROOT_PASSWORD

setup_maven
systemd_setup

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing mysql client"

#Checking whether data already loaded or not in db
mysql -h mysql.devopspract.site -uroot -p$MYSQL_ROOT_PASSWORD -e 'use cities' &>>$LOG_FILE

if [ $? -ne 0 ]; then
    mysql -h mysql.devopspract.site -uroot -p$MYSQL_ROOT_PASSWORD </app/db/schema.sql &>>$LOG_FILE

    mysql -h mysql.devopspract.site -uroot -p$MYSQL_ROOT_PASSWORD </app/db/app-user.sql &>>$LOG_FILE

    mysql -h mysql.devopspract.site -uroot -p$MYSQL_ROOT_PASSWORD </app/db/master-data.sql &>>$LOG_FILE
    VALIDATE $? "Loading data into Mysql"

else
    echo -e "Data is already loaded into Mysql .... $Y SKIPPING $N"
fi

systemctl restart shipping &>>$LOG_FILE

VALIDATE $? "Restarting Shipping Service"

print_time
