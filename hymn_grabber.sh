#!/bin/bash

cat "keywords.txt" | while read KEYWORD
do
	echo $KEYWORD
	URL="http://www.hymnal.net/en/search.php/all/all/${KEYWORD}"
	wget -U safari -O "song_${KEYWORD}.tmp" "$URL" -e robots=off
	COUNTER=0
	cat "song_${KEYWORD}.tmp" | grep "hymn.php" | grep -o '<a href=['"'"'"][^"'"'"']*['"'"'"]' | sed -e 's/^<a href=['"'"'"]//' -e 's/["'"'"']$//' | while read PAGE
	do
		let "COUNTER+=1"
		if [ "$COUNTER" -gt "2" ]
		then
			break
		fi
		wget -U safari -O "page.tmp" "$PAGE" -e robots=off
		cat "page.tmp" | grep Hymns | grep -o '<span>http://[^"'"'"']*' | grep g.png | sed -e 's/^<span>//' -e 's/<\/span>//' | tr -d '\r' |  while read -r out
		do
#			echo $out
			echo $out | rev | awk -F \/ '{print $1}' | rev | while read -r filename
			do
				echo $filename
				if [ -f ./notes/$filename ]
				then
					echo "file exists"
				else
					echo "=================="
					wget -U safari -O ./notes/$filename "$out"
				fi
			done
		done 
	done
done
rm -f *.tmp