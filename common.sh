#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FOLDER="/var/log/roboshop-logs"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOG_FOLDER
echo "Script started executing at : $(date)" | tee -a $LOG_FILE

#Check if user has root access
check_root() {
    if [ $USERID -ne 0 ]; then
        echo -e "$R ERROR:: Please run the command with sudo access $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$Y You are running with root access $N" | tee -a $LOG_FILE
    fi
}

app_setup() {
    id roboshop
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "Roboshop System User" roboshop &>>$LOG_FILE
        VALIDATE $? "Creating System user Roboshop"

    else
        echo -e "User already created... $Y $SKIPPING $N" | tee -a $LOG_FILE

    fi

    mkdir -p /app
    VALIDATE $? "Creating app directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "Dowloading $app_name service"

    rm -rf /app/* &>>$LOG_FILE
    VALIDATE $? "Remove content from app directly"

    cd /app

    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "Unzipping $app_name"
}

VALIDATE() {
    if [ $1 -eq 0 ]; then
        echo -e "$2 is ..... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ...... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

setup_nodejs() {

    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disable Default nodejs version"

    dnf module enable nodejs:20 -y &>>LOG_FILE
    VALIDATE $? "Enable node js 20 version"

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Install nodejs"

    npm install &>>$LOG_FILE
    VALIDATE $? "Installing npm packages-dependencies"
}

setup_maven() {
    dnf install maven -y
    VALIDATE $? "Installing maven and java"

    mvn clean package &>>$LOG_FILE
    VALIDATE $? "Creating jar file - packaging the shipping application"

    mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
    VALIDATE $? "move and renaming shipping jar"
}

setup_python() {
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "Installing python version 3 packages"
    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "Installing python dependencies"

    cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
    VALIDATE $? "Copying payment service info to system directory"
}

systemd_setup() {
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service &>>$LOG_FILE

    VALIDATE $? "Copying $app_name service to systemd folder"

    systemctl daemon-reload &>>$LOG_FILE
    VALIDATE $? "Loading after changes in systemd folder"

    systemctl enable $app_name &>>$LOG_FILE
    VALIDATE $? "Enabling $app_name service"

    systemctl start $app_name
    VALIDATE $? "Starting $app_name service"
}

print_time() {
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME - $START_TIME))
    echo -e "Script executed successfully... time taken: $Y $TOTAL_TIME seconds $N"
}
