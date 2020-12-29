#!/bin/bash


machine_name=${PWD##*/}
markdown_report=$machine_name.md
touch $markdown_report
echo '' > $markdown_report
dir_output=$PWD/command_output



while read full_command; 
do	
	command=$(echo $full_command | awk '{print $1;}')
	command_file=$(ls $dir_output/ | grep $command)
	command_file=${command_file}
	uppercase_command=${command^^}
	#is_blank=find ${dir_output}/ -empty -name ${command_file}
	#is_blank=$0
	if [ -s $dir_output/$command_file ]
	then

		echo "### $uppercase_command" >> $markdown_report
		echo "\`\`\` $ $full_command \`\`\`" >> $markdown_report
		printf '``` bash ' >> $markdown_report
		printf "\n" >> $markdown_report
		cat $dir_output/$command_file >> $markdown_report
		echo '```' >> $markdown_report
	fi
	#printf "\n">> $markdown_report
done < ${dir_output}/command_stack.txt