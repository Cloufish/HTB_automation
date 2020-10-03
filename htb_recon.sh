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
mkdir command_output
dir=$PWD/command_output
touch ${dir}/command_stack.txt
dir_commands=${dir}/command_stack.txt

nmap_command="nmap -T4 -A -p- -Pn $domain"
echo $nmap_command > $dir_commands

touch ${dir}/nmap.txt
eval ${nmap_command} > ${dir}/nmap.txt
cat ${dir}/nmap.txt

grep -i HTTP ${dir}/nmap.txt >> /dev/null
has_http=$?


if [ $has_http -eq 0 ]; 
then

        gobuster_command="gobuster dir -x .php,.txt,.html -r -k --wordlist ~/tools/SecLists/Discovery/Web-Content/raft-medium-directories.txt --wildcard --url $domain -o $dir/gobuster.txt"
        echo $gobuster_command >> $dir_commands

        touch ${dir}/gobuster.txt
        eval ${gobuster_command}
        ## Checking the length of gobuster scan.
        
        webanalyze_command="webanalyze -host $domain -crawl 1"
        echo $webanalyze_command >> $dir_commands

        webanalyze -update > /dev/null

        touch ${dir}/webanalyze.txt
        eval ${webanalyze_command} > ${dir}/webanalyze.txt

        # Searchsploit with webanalyze findings

       while read in; do echo $in | searchsploit; done < ${dir}webanalyze.txt

        curl_command=" curl -L -k $domain"
        echo $curl_command >> $dir_commands

        touch ${dir}/curl.txt
        eval ${curl_command} >${dir}/curl.txt

fi






converter_to_markdown.sh