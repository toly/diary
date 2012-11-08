#!/bin/bash

# вывод помощи
if [ "$1" = "help" -o "$1" = "h" -o "$1" = "?" ]; then
	echo "Usage: diary.sh [option|date]"
	echo "	?, h, help		view help page"
	echo "	t, template		edit template file"
	echo "	-[n]			n days before"
	echo "	+[n]			n days later"
	exit 0
fi

# проверка каталога
main_dir=".diary"
cd ~
if [ ! -d $main_dir ]; then
	mkdir .diary
fi

# редактор шаблона
template="$main_dir/template.txt"
if [ "$1" = "template" -o "$1" = "t" ]; then
	vim $template
	exit 0
fi

# запись по дате
DATE=`date +%s`
if [ ! "$1" = "" ]; then
	param=${1:0:1}
	if [ $param = '-' ]; then
		DATE=$(($DATE-${1:1}*24*3600))
	fi
	if [ $param = '+' ]; then
		DATE=$(($DATE+${1:1}*24*3600))
	fi
fi

# инициализация даты
day=`date +%d --date="@$DATE"` 
mounth=`date +%m --date="@$DATE"`
year=`date +%Y --date="@$DATE"`


# новая запись
mkdir -p $main_dir/$year/$mounth
entry=$main_dir/$year/$mounth/$day.txt
if [ ! -e $entry ]; then
	date +%F --date="@$DATE" >> $entry
	
	if [ -e $template ]; then
		echo "" >> $entry
		more $template >> $entry
	fi

	echo -e "\n" >> $entry
fi

vim + $entry

LAST_LINE=`tail -n 1 $entry`
if [ ! "$LAST_LINE" = '' ]; then
	date +----------------------[%H:%M]--- >> $entry
	echo -e "\n" >> $entry
fi
