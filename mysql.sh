#!/bin/bash
USERID=$(id -u)
R='\e[31m'
G='\e[32m'
Y='\e[33m'
W='\e[0m'
LOGS_FOLDER="/etc/var/logs/"
LOGS_FILENAME=$(echo $0 | cut -d "." -f1)
LOG_NAME=$LOGS_FOLDER/$LOGS_FILENAME.log
if [ $USERID -ne 0 ]; then
    echo -e "$R ERROR::Please run the script wiht roor Previleges $W"
    exit 1
fi
VALIDATE(){
    if [ $1 -ne 0 ]; then
    echo -e "$R Installing $2 is FALIURE $W" &>>$LOG_NAME
    exit 1
    else
    echo -e "$G Installing $2 SUCCESS $W" &>>$LOG_NAME
    fi
}

dnf install mysql-server -y &>>$LOG_NAME
VALIDATE $? "mysql-server"
systemctl enable mysqld &>>$LOG_NAME
VALIDATE $? "enabled mysqld"
systemctl start mysqld &>>$LOG_NAME
VALIDATE "started mysqld"
mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_NAME
VALIDATE $? "password is set"

