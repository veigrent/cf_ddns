#!/bin/bash
. cfapi.sh

export EMAIL='xxx@gmail.com'
export GAPI_KEY='xxxxxxxxx'
export ZONE_ID='xxxxxxxxxx'

getmyip6 () {
    myip6=$(curl --connect-timeout 3 6.ipw.cn 2>/dev/null)
    if [ -z "$myip6" ] ; then
        ifconfig eth0 down
        sleep 6
        ifconfig eth0 up
        sleep 3
        myip6=$(curl --connect-timeout 3 6.ipw.cn 2>/dev/null)
        sleep 3
        myip6=$(curl --connect-timeout 3 6.ipw.cn 2>/dev/null)
    fi
    echo $myip6
}

echo ""
echo "========================================================="
echo $(date)
myip6=$(getmyip6)
echo myipv6 $myip6

[ -z "$myip6" ] && echo no ip6 addr get && exit 0

set_dns_record homeipv6 AAAA $myip6

