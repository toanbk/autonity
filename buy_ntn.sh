#!/bin/bash

# Define the wallet address and perform transactions
TO_WALLET="0x52B74068f498A8491d1acd1752E517B977146b4f"
KEYSTORE_DIR="$HOME/piccadilly-keystore"
WALLET_PASSWORD="123123"

install_expect() {
    sudo apt install -y expect
}

# Function to create account using aut command
create_account() {
    local keyfile="$1"
    local password="$2"

    expect << EOF
    spawn aut account new --keyfile $keyfile
    expect "Password for new account:"
    send "$password\r"
    expect "Confirm account password:"
    send "$password\r"
    expect eof
EOF
}

# Check if expect is installed, if not, install it
if ! command -v expect &>/dev/null; then
    echo "Expect is not installed. Installing..."
    install_expect
fi

# Fetch the API key
MESSAGE=$(jq -nc --arg nonce "$(date +%s%N)" '$ARGS.named')
aut account sign-message $MESSAGE message.sig
KEY_JSON=$(echo -n $MESSAGE | https https://cax.piccadilly.autonity.org/api/apikeys api-sig:@message.sig)

# Extract the apikey
API_KEY=$(echo $KEY_JSON | jq -r '.apikey')

# Update .bash_profile
if grep -q 'export KEY=' ~/.bash_profile; then
    # Replace the existing key
    sed -i "s|export KEY=.*|export KEY=$API_KEY|" ~/.bash_profile
else
    # Add the new key
    echo "export KEY=$API_KEY" >> ~/.bash_profile
fi

# Source .bash_profile to use the new API key
source ~/.bash_profile

echo -e "new API key: $API_KEY"

# Fetch the ask price
ORDERBOOK_JSON=$(https GET https://cax.piccadilly.autonity.org/api/orderbooks/NTN-USD/quote API-Key:$KEY)
ASK_PRICE=$(echo $ORDERBOOK_JSON | jq -r '.ask_price')

# Calculate buy_amount
BUY_AMOUNT=$(echo "1000000 / $ASK_PRICE" | bc)

echo -e "Buy $BUY_AMOUNT NTN with price $ASK_PRICE ..."

# Place an order
https POST https://cax.piccadilly.autonity.org/api/orders/ API-Key:$KEY pair=NTN-USD side=bid price=$ASK_PRICE amount=$BUY_AMOUNT

# Wait for 10 seconds
sleep 5

# Make a withdrawal
https POST https://cax.piccadilly.autonity.org/api/withdraws/ API-Key:$KEY symbol=NTN amount=$BUY_AMOUNT

# Wait for another 10 seconds
sleep 5

aut account info

# Make and send the transaction
aut tx make --to $TO_WALLET --value $BUY_AMOUNT --ntn | aut tx sign - | aut tx send -

sleep 5

https GET https://cax.piccadilly.autonity.org/api/balances/ API-Key:$KEY

aut account info

echo -e "Buy and send NTN success, Please backup wallet info before create new one: "

old_wallet=$(cat ~/piccadilly-keystore/wallet.key)

echo -e "\n============ OLD WALLET =============\n"
echo -e "\e[1m\e[32m$old_wallet \e[0m"
echo -e "\n=====================================================\n"


echo -e "\n============ OLD API KEY =============\n"
echo -e "\e[1m\e[32m$KEY \e[0m"
echo -e "\n=====================================================\n"

echo -e "\n=============== Create new address ... ===============\n"

rm -rf ~/piccadilly-keystore/wallet.key

create_account "$KEYSTORE_DIR/wallet.key" "$WALLET_PASSWORD"

new_account=$(aut account info | jq -r '.[0].account')

sign_message=$(aut account sign-message 'I have read and agree to comply with the Piccadilly Circus Games Competition Terms and Conditions published on IPFS with CID QmVghJVoWkFPtMBUcCiqs7Utydgkfe19wkLunhS5t57yEu')

echo -e "\n============ NEW ACCOUNT =============\n"
echo -e "\e[1m\e[32m$new_account \e[0m"
echo -e "\n=====================================================\n"

echo -e "\n============ REGISTER SIGN MESSAGE =============\n"
echo -e "\e[1m\e[32m$sign_message \e[0m"
echo -e "\n=====================================================\n"

echo -e "\n=============== Register new account and re run this script, Thank you ===============\n"
