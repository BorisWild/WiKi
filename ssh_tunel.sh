#!/bin/bash
#run command
#chmod +x scripts/ssh_tunnel.sh 
#nohup ./scripts/ssh_tunnel.sh > /dev/null 2>&1 &
#Таким образом, команда будет продолжать выполняться в фоновом режиме и после того, как пользователь выйдет из системы
#end running
#ps -aux | grep ssh_tunnel.sh
#kill -9 2221901

#Конфигурация
USER="ubuntu"                                                           #Имя пользователя для SSH
HOST="3.68.47.148"                                                      #Адрес бастион-сервера
LOCAL_PORT="3306"                                                       #Локальный порт для прокси
TARGET_HOST="db.czwjxykkhydg.eu-central-1.rds.amazonaws.com"   # Целевой хост внутри сети
TARGET_PORT="3306"                                                      #Целевой порт на целевом хосте
KEY="/home/forge/scripts/bastion.pem"                             	#Путь к приватному ключу SSH

#Бесконечный цикл для поддержания туннеля
while true; do
    #Установка SSH туннеля
    ssh -i "$KEY" -N -L $LOCAL_PORT:$TARGET_HOST:$TARGET_PORT $USER@$HOST
    
    #Ждать 5 секунд перед попыткой переподключения после обрыва
    sleep 5
done
