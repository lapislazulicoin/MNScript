#!/bin/bash

#stop_daemon function
function stop_daemon {
    if pgrep -x 'lapislazulid' > /dev/null; then
        echo -e "${YELLOW}Attempting to stop lapislazulid${NC}"
        lapislazuli-cli stop
        sleep 30
        if pgrep -x 'lapislazulid' > /dev/null; then
            echo -e "${RED}lapislazulid daemon is still running!${NC} \a"
            echo -e "${RED}Attempting to kill...${NC}"
            sudo pkill -9 lapislazulid
            sleep 30
            if pgrep -x 'lapislazulid' > /dev/null; then
                echo -e "${RED}Can't stop lapislazulid! Reboot and try again...${NC} \a"
                exit 2
            fi
        fi
    fi
}


echo "Your LapisLazuli Masternode Will be Updated To The Latest Version v1.0.2 Now" 
sudo apt-get -y install unzip

#remove crontab entry to prevent daemon from starting
crontab -l | grep -v 'lilliauto.sh' | crontab -

#Stop lapislazulid by calling the stop_daemon function
stop_daemon

rm -rf /usr/local/bin/lapislazuli*
mkdir LILLI_1.0.2
cd LILLI_1.0.2
wget https://github.com/lapislazulicoin/lilli/releases/download/1.0.2/lilli-1.0.2-linux.tar.gz
tar -xzvf lilli-1.0.2-linux.tar.gz
mv lapislazulid /usr/local/bin/lapislazulid
mv lapislazuli-cli /usr/local/bin/lapislazuli-cli
chmod +x /usr/local/bin/lapislazuli*
rm -rf ~/.lapislazuli/blocks
rm -rf ~/.lapislazuli/chainstate
rm -rf ~/.lapislazuli/sporks
rm -rf ~/.lapislazuli/peers.dat
cd ~/.lapislazuli/
wget https://github.com/lapislazulicoin/lilli/releases/download/1.0.2/bootstrap.zip
unzip bootstrap.zip

cd ..
rm -rf ~/.lapislazuli/bootstrap.zip ~/LILLI_1.0.2


# add new nodes to config file
sed -i '/addnode/d' ~/.lapislazuli/lapislazuli.conf

echo "addnode=45.130.104.65
addnode=155.138.247.115
addnode=45.76.234.234
addnode=144.202.70.149
addnode=45.32.193.245" >> ~/.lapislazuli/lapislazuli.conf

#start lapislazulid
lapislazulid -daemon

printf '#!/bin/bash\nif [ ! -f "~/.lapislazuli/lapislazuli.pid" ]; then /usr/local/bin/lapislazulid -daemon ; fi' > /root/lilliauto.sh
chmod -R 755 /root/lilliauto.sh
#Setting auto start cron job for LapisLazuli  
if ! crontab -l | grep "lilliauto.sh"; then
    (crontab -l ; echo "*/5 * * * * /root/lilliauto.sh")| crontab -
fi

echo "Masternode Updated!"
echo "Please wait a few minutes and start your Masternode again on your Local Wallet"
