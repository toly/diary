#!/bin/bash

# вывод помощи
if [ "$1" = "help" -o "$1" = "h" -o "$1" = "?" ]; then
	echo "Usage: diary.sh [option|date]"
	echo "	?, h, help		view help page"
	echo "	t, template		edit template file"
	echo "	d-|+[n]			n days before|later, example d-2 or d+5"
	echo "	date=[Y-m-d]	note at Y-m-d (example d=2012-10-28)"
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
	param=${1:0:2}
	f_letter=${1:0:1}
	if [ $param = 'd-' ]; then
		DATE=$(($DATE-${1:2}*24*3600))
	fi
	if [ $param = 'd+' ]; then
		DATE=$(($DATE+${1:2}*24*3600))
	fi
	if [ ${1:0:5} = 'date=' ]; then
		DATE=`date +%s --date=${1:5}`
	fi
	if [ $f_letter = 'w' ]; then
		need_week=1
		if [ $param = 'w+' ]; then
			DATE=$(($DATE+${1:2}*24*3600*7))
		fi
		if [ $param = 'w-' ]; then
			DATE=$(($DATE-${1:2}*24*3600*7))
		fi
	fi
fi

# инициализация даты
day=`date +%d --date="@$DATE"` 
mounth=`date +%m --date="@$DATE"`
year=`date +%Y --date="@$DATE"`
if [ $need_week ]; then
	week=`date +%W --date="@$DATE"`
	day_week=`date +%u`
	begin_week=$(( $DATE-($day_week-1)*3600*24 ))
	BEGIN_WEEK=`date +%F --date="@$begin_week"`
	end_week=$(( $DATE+(7-$day_week)*3600*24 ))
	END_WEEK=`date +%F --date="@$end_week"`
fi

# новая запись
if [ $need_week ]; then
	mkdir -p $main_dir/$year/weeks
	entry=$main_dir/$year/weeks/$week.txt
	if [ ! -e $entry ]; then
		echo "$BEGIN_WEEK - $END_WEEK" >> $entry
		echo -e "\n" >> $entry
	fi
else
	mkdir -p $main_dir/$year/$mount
	entry=$main_dir/$year/$mounth/$day.txt
	if [ ! -e $entry ]; then
		date +%F --date="@$DATE" >> $entry
	
		if [ -e $template ]; then
			echo "" >> $entry
			more $template >> $entry
		fi

		echo -e "\n" >> $entry
	fi
fi

vim + $entry

if [ ! $need_week ]; then
	LAST_LINE=`tail -n 1 $entry`
	if [ ! "$LAST_LINE" = '' ]; then
		date +----------------------[%H:%M]--- >> $entry
		echo -e "\n" >> $entry
	fi
fi
