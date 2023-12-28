#!/bin/bash

# change sendto wallet
# change pass your wallet

# current=$(date +%s)
# sendto=`curl https://raw.githubusercontent.com/toanbk/autonity/main/wallet.txt?v=$current`

# Check if the file exists
file="wallet.txt"
if [ ! -f "$file" ]; then
    echo "File $file not found."
    exit 1
fi

password=123123

n=1
while :
do
     while IFS= read -r line
     do
          echo "send $n"	    
          echo "Processing address: $line"

          aut tx make --to "$line" --value 0.3 | aut tx sign --password "$password" - | aut tx send -
          
          sleep 1.5

          n=$((n+1))
     done < "$file"
done
