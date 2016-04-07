#!/bin/bash

INSTALLATION_PATH="/var/www/html"
INSTALLATION_NAME="mautic"
DEFAULT_MAUTIC_FOLDER_NAME="mautic-master"

while getopts 'p:b:v' opts; do
    case ${opts} in
        p) INSTALLATION_PATH=${OPTARG} ;;
        b) INSTALLATION_NAME=${OPTARG} ;;
        v) verbose='true' ;;
        *) error "Unexpected option ${opts}" ;;
    esac
done


# download mautic
wget https://github.com/mautic/mautic/archive/master.zip

if [[ $? -ne 0 ]]; then
    echo "Failed to download mautic"
else 
    echo "Download successull!"
    echo "Unpacking mautic to " $INSTALLATION_PATH

    if [[ "$(ls -A)" = "" ]] ; then 
        echo  'Mautic file not found'
    else
        if [ -d $INSTALLATION_PATH ]; then
            unzip master.zip -d $INSTALLATION_PATH

            # rename mautic folder
            echo "Changing directory to "$INSTALLATION_PATH
            
            cd $INSTALLATION_PATH

            sleep 2s

            mv $INSTALLATION_PATH"/"$DEFAULT_MAUTIC_FOLDER_NAME $INSTALLATION_PATH"/"$INSTALLATION_NAME

            sleep 2s

            cd $INSTALLATION_PATH"/"$INSTALLATION_NAME

            sleep 2s

            # update package by running composer
            if [ -f "composer.phar" ]; then
                php composer.phar update
            else
                php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php
                php -r "if (hash('SHA384', file_get_contents('composer-setup.php')) === '7228c001f88bee97506740ef0888240bd8a760b046ee16db8f4095c0d8d525f2367663f22a46b48d072c816e7fe19959') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
                php composer-setup.php --install-dir=$INSTALLATION_PATH"/"$INSTALLATION_NAME
                php -r "unlink('composer-setup.php');"

                sleep 3s

                #php $INSTALLATION_PATH"/"$INSTALLATION_NAME"/"composer.phar update                
                php composer.phar update
            fi
        else
            echo $INSTALLATION_PATH " not existing"
        fi
    fi
fi
