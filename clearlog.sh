#!/bin/bash
# clearlog.sh
# Clear [coin]daemon.log every other day
# Add the following to the crontab (i.e. crontab -e)
# 0 0 */2 * * /usr/local/bin/clearlog.sh

/bin/date > /[coin]daemon.log
