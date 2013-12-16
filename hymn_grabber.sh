#!/bin/bash

KWFILE=keywords.txt
GCSVFILE=stats_guitar.csv
PCSVFILE=stats_piano.csv

if [ -d "notes/guitar" ]
then
  echo
else
   mkdir -p notes/guitar
fi

if [ -d "notes/piano" ]
then
  echo
else
  mkdir -p notes/piano
fi

echo "keywords, filename, category, url" > $GCSVFILE
echo "keywords, filename, category, url" > $PCSVFILE

cat $KWFILE | while read KEYWORD
do
  SEARCHKEY=`echo ${KEYWORD} | sed 's/,/ /g' | sed 's/\./ /g' | sed 's/:/ /g'| sed 's/;/ /g' | sed 's/"/ /g'| sed 's/\( \)\{1,\}/%20/g'`
  echo "searching ${SEARCHKEY} ......"
	URL="http://www.hymnal.net/en/search.php/all/all/${SEARCHKEY}"
  wget -U safari -O "song.tmp" "$URL" -e robots=off
  COUNTER=0
  cat "song.tmp" | grep "hymn.php" | grep -o '<a href=['"'"'"][^"'"'"']*['"'"'"]' | sed -e 's/^<a href=['"'"'"]//' -e 's/["'"'"']$//' | while read PAGE
  do
    let "COUNTER+=1"
    if [ "$COUNTER" -gt "2" ]
    then
      break
    fi
    wget -U safari -O "page.tmp" "$PAGE" -e robots=off
    CATEGORY=`cat page.tmp | tr -d " \t\n\r" | sed 's/^.*\/category\//\/category\//' | awk -F'">' '{print $1}' | sed 's/\/category\///g'`
    echo $CATEGORY
#####################################
# grab guitar notes
#####################################    
    cat "page.tmp" | grep Hymns | grep -o '<span>http://[^"'"'"']*' | grep g.png | sed -e 's/^<span>//' -e 's/<\/span>//' | tr -d '\r' |  while read -r out
    do
      echo $out | rev | awk -F \/ '{print $1}' | rev | while read -r filename
      do
        echo $filename
        if [ -f ./notes/guitar/$filename ]
        then
          echo "file exists"
        else
          echo "=================="
          wget -U safari -O ./notes/guitar/$filename "$out"
        fi
				NEWKEYWORD=`echo $SEARCHKEY | sed 's/%20/ /g'`
        echo "$NEWKEYWORD, $filename, $CATEGORY, $out" >> $GCSVFILE
      done
    done 
#####################################
# grab piano notes
#####################################    
    cat "page.tmp" | grep Hymns | grep -o '<span>http://[^"'"'"']*' | grep p.png | sed -e 's/^<span>//' -e 's/<\/span>//' | tr -d '\r' |  while read -r out
    do
      echo $out | rev | awk -F \/ '{print $1}' | rev | while read -r filename
      do
        echo $filename
        if [ -f ./notes/piano/$filename ]
        then
          echo "file exists"
        else
          echo "=================="
          wget -U safari -O ./notes/piano/$filename "$out"
        fi
				NEWKEYWORD=`echo $SEARCHKEY | sed 's/%20/ /g'`
        echo "$NEWKEYWORD, $filename, $CATEGORY, $out" >> $PCSVFILE
      done
    done 
  done
done
rm -f *.tmp
