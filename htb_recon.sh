#!/bin/bash

while getopts ":d:" input;do
        case "$input" in
                d) domain=${OPTARG}
                        ;;
                esac
        done
if [ -z "$domain" ]
        then
                echo "Please give a HTB ip like \"-d 10.10.10.*\""
                exit 1
fi

function runcom(){
    echo "$ @"
    ## Run the command
    $@
}

mkdir command_output
dir=$PWD/command_output/
touch ${dir}command_stack.txt
dir_commands=${dir}command_stack.txt

#NMAP
nmap_command="nmap -T4 -A -p- -Pn -oG nmap-grepable.txt $domain"
echo $nmap_command >> $dir_commands

touch ${dir}nmap.txt
eval "runcom ${nmap_command}" | tee ${dir}nmap.txt

grep -i HTTP nmap-grepable.txt >> /dev/null
has_http=$?


if [ $has_http -eq 0 ];
then

        gobuster_command="gobuster dir -r -k -x .php,.txt,.html -r -k --wordlist ~/tools/SecLists/Directory-Bruting/directory-list-2.3-small.txt --url $domain -o $dir/gobuster.txt"
        echo $gobuster_command >> $dir_commands

        touch ${dir}gobuster.txt
        eval "runcom ${gobuster_command}" | tee ${dir}gobuster.txt
        ## Checking the length of gobuster scan.

        webanalyze_command="webanalyze -host $domain -crawl 1"
        webanalyze -update > /dev/null
        echo $webanalyze_command >> $dir_commands

        touch ${dir}webanalyze.txt
        eval "runcom ${webanalyze_command}" | tee ${dir}webanalyze.txt

        # Searchsploit with webanalyze findings
        searchsploit_command="searchsploit"
        while read in; do echo $in | eval "runcom $searchsploit_command" | tee ${dir}searchsploit.txt; done < ${dir}webanalyze.txt >${dir}searchsploit.txt
        echo $searchsploit_command >> $dir_commands
        
        curl_command=" curl -L -k $domain"
        echo $curl_command >> $dir_commands
        touch ${dir}curl.txt
        eval "runcom ${curl_command}" | tee ${dir}curl.txt

fi






htb_converter_to_markdown.sh
