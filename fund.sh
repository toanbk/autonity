#!/bin/bash

password='123123'

# Check if the file exists
file="cloner_address.txt"
if [ ! -f "$file" ]; then
    echo "File $file not found."
    exit 1
fi

while IFS= read -r line
do
    echo "Processing address: $line"

    # Second command
    echo "Executing sent ATN..."
    aut tx make --to "$line" --value 10000 | aut tx sign --password "$password" - | aut tx send -
    second_command_exit_code=$?
    echo "Exit code sent ATN: $second_command_exit_code"
    sleep 10
done < "$file"

accountbalanceatnafter=`aut account balance`

echo Balance ATN after send: $accountbalanceatnafter
