#!/bin/bash

host=$1
cipher_list=":"$(openssl ciphers)":"

function get_prefered() {
    echo -n | openssl s_client -$1 -cipher $2 -connect $host:443 2>&1 | grep "Cipher    :" | cut -d" " -f 10
}

echo "Cipher suit preference list"

for protocol in ssl3 tls1 tls1_1 tls1_2
do
    temp_list=$cipher_list
    first_preference=$(get_prefered $protocol "$temp_list")
    declare -a pref_$protocol
    case $first_preference in
        0000) echo -e "\033[1m$protocol\033[0m not supported"; continue;;
        
        "") echo -e "\033[1m$protocol\033[0m not supported"; continue;;
        
        *)echo -e "\033[1m$protocol\033[0m"
            echo -e "\t$first_preference"
            temp_list=$(echo $temp_list | sed -e "s/\:$first_preference\:/\:/");;
    esac
    while true
    do
        next_preference=$(get_prefered $protocol "$temp_list")
        case $next_preference in
            0000) break ;;
            *)echo -e "\t$next_preference"
                temp_list=$(echo $temp_list | sed -e "s/\:$next_preference\:/\:/");;
        esac
    done

done
