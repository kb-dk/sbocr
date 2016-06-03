#!/bin/bash

# Merges 2 or more outputs from word_compress.sh

function usage() {
    echo "./word_merge.sh normalised normalised+"
    echo ""
    echo "normalised: Output from word_normalise.sh"
    exit
}

if [ "." == "$1" ]; then
    usage
fi

TMPSRC=`mktemp`
TMPDEST=`mktemp`

cp "$1" $TMPSRC
shift
for FILE in $@; do
    join -j 2 $TMPSRC $FILE | awk '{print $2+$3 " " $1}' > $TMPDEST
    mv $TMPDEST $TMPSRC
done
cat $TMPSRC
rm $TMPSRC
