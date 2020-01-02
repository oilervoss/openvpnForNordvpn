## Problem
Some USB 4G modems don't reconnect after losing the connection. 
This is frequently with [modded Hauwei](http://blog.asiantuntijakaveri.fi/2015/07/convert-huawei-e3372h-153-from.html) modems in order to work with the ncm protocol.

## Solution
This init script will ping a public IP. If its success rate is less than 20%, it will drop the ncm interface and send AT commands to the modem forcing it to reconnect.
Only then it will bring the ncm interface back.

It must be called using `/etc/init.d/ncm-fix start`. The best use is scheduling a cron job to check the connection each X minutes.
I'm using the following in my /etc/crontabs/root to run the script every 20 minutes:

~~~~sh
# /etc/crontabs/root

*/20    *    *     *     *     /etc/init.d/ncm-fix start
~~~~

If your /etc/crontabs/root is empty or doesn't exist probably the cron service is disabled too. Use the following to start it:

~~~~sh
/etc/init.d/cron enable
/etc/init.d/cron start
~~~~

Each time you change the /etc/crontabs/root file, you will need to restart the cron service using `/etc/init.d/cron restart`.
