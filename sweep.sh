#!/bin/bash

from=$1
to=$2
fee=0.001
utxos=$(./src/navcoin-cli listunspent 1 99999999 [\"$from\"]|jq -c "[.[] | {txid: .txid,vout: .vout}]")
amount=$(./src/navcoin-cli listunspent 1 99999999 [\"$from\"]|jq "[.[] | .amount]" | awk '{sum+=$0} END{printf "%.8f", sum}')
rawtx=$(./src/navcoin-cli createrawtransaction $utxos {\"$to\":$(bc <<< "$amount - $fee")})
sigtx=$(./src/navcoin-cli signrawtransaction $rawtx|jq -r .hex)
./src/navcoin-cli decoderawtransaction $sigtx
read -p "Do you want to submit the transaction? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
        ./src/navcoin-cli sendrawtransaction $sigtx
fi
