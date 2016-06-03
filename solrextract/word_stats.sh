#!/bin/bash

# Takes a text from word_compress.sh and extracts character count, word count, unique word count

function usage() {
    echo "./word_stats.sh normalised"
    echo ""
    echo "normalised: Output from word_normalise.sh or word_merge.sh"
    exit
}

if [ "." == "$1" ]; then
    usage
fi
if [ ! -s "$1" ]; then
    exit
fi


CHARS=0
WORDS=0
UNIQ=0

# No globbing as that messes up the split
set -f
while IFS= read -r LINE; do
    ARR=($LINE)
    COUNT=${ARR[0]}
    TERM=${ARR[1]}
    LENGTH=${#TERM} 
    
    # COUNT=`echo "$LINE" | cut -d\  -f1`
    # TERM=`echo "$LINE" | cut -d\  -f2`

    CHARS=$(( CHARS + (COUNT * LENGTH) ))
    WORDS=$(( WORDS + COUNT ))
    UNIQ=$(( UNIQ + 1 ))
done < "$1"

#echo "#file #chars #words #uniques"
echo "$1 $CHARS $WORDS $UNIQ"
