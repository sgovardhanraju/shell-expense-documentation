#!/bin/bash
USERID=$(id -u)
R='\e[31m'
G='\e[32m'
Y='\e[33m'
W='\e[0m'
SCRIPT_DIR=$PWD
LOGS_FOLDER="/etc/var/logs/"
LOGS_FILENAME=$(echo $0 | cut -d "." -f1)
LOG_NAME=$LOGS_FOLDER/$LOGS_FILENAME.log
if [ $? -ne 0 ]; then
    echo -e "$R ERROR::Please run the script with root Previleges $W"
    exit 1
fi
VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$R Installing $2 is FAILURE $W" &>>$LOG_NAME
        exit 1
    else
        echo -e "$G Installing $2 is SUCCESS $W" &>>$LOG_NAME
    fi
}
dnf list installed nodejs &>>$LOG_NAME
if [ $? -ne 0 ]; then
    dnf module disable nodejs -y &>>$LOG_NAME
    dnf module enable nodejs:20 -y &>>$LOG_NAME
    dnf install nodejs -y &>>$LOG_NAME
    VALIDATE $? "nodejs:20"
    else
        echo -e "$R Installing nojdejs already exist ... $Y SKIPPING $W"
    fi
useradd expense &>>$LOG_NAME
VALIDATE $? "user expense is added"
mkdir -p /app &>>$LOG_NAME
VALIDATE $? "app directory is created"
curl -o /tmp/backend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
cd /app/ &>>$LOG_NAME
VALIDATE $? "changed to app directory"
unzip /tmp/backend.zip
npm install &>>$LOG_NAME
VALIDATE $? "npm installed"
cp $SCRIPT_DIR/backend.repo /etc/systemd/system/backend.service &>>$LOG_NAME
VALIDATE $? "backend repo copied"
systemctl start backend &>>$LOG_NAME
VALIDATE "started backend service"
systemctl enable backend &>>$LOG_NAME
VALIDATE $? "Enabled backed"
dnf install mysql -y &>>$LOG_NAME
VALIDATE $? "installed mysql"
mysql -h mysql.sgrdevsecops.fun -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_NAME
systemctl restart backend &>>$LOG_NAME
VALIDATE $? "Restarted backend"
