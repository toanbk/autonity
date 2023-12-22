#!/bin/bash

# change sendto wallet
# change pass your wallet

# current=$(date +%s)
# sendto=`curl https://raw.githubusercontent.com/toanbk/autonity/main/wallet.txt?v=$current`
sendto=`cat ./wallet.txt`
pass=123123

echo "Today will set to wallet address: $sendto"

n=1
while :
do
     echo "send $n"
     aut tx make --to $sendto --value 0.3  | aut tx sign --password $pass - | aut tx send - && sleep 3

     n=$((n+1))

done
