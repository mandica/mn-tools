# mn-tools

Checking script setup
wget xxxx.sh
wget clearlog.sh

chmod +x xxxx.sh
sudo mv xxxx.sh /usr/local/bin
crontab -e

ADD LINE
*/15 * * * * /usr/local/bin/xxxx.sh >>~/xxxx.log 2>&1

DELETE LOG FILE EVERY 2 DAYS
0 0 */2 * * /usr/local/bin/clearlog.sh
