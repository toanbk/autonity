#!/bin/bash

# change sendto wallet
# change pass your wallet

sendto=`curl https://raw.githubusercontent.com/toanbk/autonity/main/wallet.txt`
pass=123123

echo "Today will set to wallet address: $sendto"

n=1
while :
do
     echo "send $n"
     aut tx make --to $sendto --value 1  | aut tx sign --password $pass - | aut tx send - && sleep 2

     n=$((n+1))

done

