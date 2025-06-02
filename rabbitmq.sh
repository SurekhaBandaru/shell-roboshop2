#!/bin/bash

source ./common.sh
app_name=rabbitmq
check_root

echo "Please enter rabbitmq password to set up"
read -s RABBITMQ_PASSWORD

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "Copying rabbit mq repo"

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Installing rabbit mq server"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enabling RabbitMq server"

systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Starting RabbitMq server"

# RabbitMQ comes up with default username/password guest/guest but using this we connect to rabbitmq, we need to create one user for application

rabbitmqctl add_user roboshop $RABBITMQ_PASSWORD
VALIDATE $? "Creating new user for rabbit mq server"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "Set rabbitmq user permissions"

#systemctl restart rabbitmq-server
#VALIDATE $? "Restarting Rabbit mq server"

print_time
