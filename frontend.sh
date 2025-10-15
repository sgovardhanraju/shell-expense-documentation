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
    echo -e "$R ERROR::Please run the script with root Previleges $W" &>>$LOG_NAME
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
dnf list installed nginx
if [ $? -ne 0 ]; then
    dnf install nginx -y &>>$LOG_NAME
    VALIDATE $? "nginx"
else
    echo -e "$R Installing nginx already exist ...$Y SKIPPING $W" &>>$LOG_NAME
fi
systemctl enable nginx &>>$LOG_NAME
VALIDATE $? "enable nginx"
systemctl start nginx &>>$LOG_NAME
VALIDATE $? "start nginx"
rm -rf /usr/share/nginx/html/*
VALIDATE $? "removed old html"
curl -o /tmp/frontend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOG_NAME
VALIDATE $? "unzipped frontend code"
cp $SCRIPT_DIR/frontend.repo /etc/nginx/default.d/expense.conf &>>$LOG_NAME
VALIDATE $? "copied frontend repo"
systemctl restart nginx &>>$LOG_NAME
VALIDATE $? "restarted nginx"