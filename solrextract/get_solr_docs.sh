#!/bin/bash

ID=recordID
PAGE=1000

# Extracts key values from all Solr docs matching a query.
# ./get_solr_docs.sh "http://tokemon:56708/aviser/sbsolr/collection1/select" "recordBase:doms_aviser AND sort_year_asc:1974*" "fulltext_org" ttt1974

# We cannot use deep paging as sorting on recordID blows a 13GB heap

function usage() {
    echo "./get_solr_docs.sh solr query [fields] [out]"
    echo ""
    echo "solr:   http://mars:56708/aviser/sbsolr/collection1/select"
    echo "query:  Limiting query. Use '*:*' to match all documents"
    echo "fields: Comma-separated list of fields. Defaults to 'recordID'"
    echo "out:    Output file"
    exit
}
# » messes up sed. Strange!?
function get_fields() {
    cat $1 | tr '»' ' ' | tr '\n' ' ' | sed 's/<doc>/¼<doc>/g' | tr '¼' '\n' | grep "<doc>" | sed -e 's/.*<doc>\(.*\)<\/doc>.*/\1/g' -e 's/[ ]*<[^>]\+name[^>]\+>\([^<]\+\)<[^>]\+>/\1\t/g' -e 's/\(.*\)\t$/\1/' -e 's/<\/*str>//g' -e 's/<doc>//' -e 's/<\/arr>//'  -e 's/<\/doc>//' -e 's/<\/response>//' -e 's/\s\+/ /g' -e 's/^ //' >> $OUT
}

SOLR="$1"
QUERY=`echo "$2" | sed 's/ /+/g'`
if [ "." == ".$SOLR" -o "." == ".$QUERY" ]; then
    usage
fi
FIELDS="$3"
if [ "." == ".$FIELDS" ]; then
    FIELDS="$ID"
fi
OUT="$4"
if [ "." == ".$OUT" ]; then
    OUT="documents_`date +%Y%m%d-%H%M%S`.dat"
fi
if [ -f "$OUT" -o -f "${OUT}.gz" ]; then
    echo "$OUT already processed"
    exit
fi

BASE_URL="$SOLR?q=$QUERY&wt=xml&indent=false&facet=false"
T=`mktemp`
wget "$BASE_URL&fl=recordID" -O $T 2> /dev/null
HITS=`cat $T | grep "<result name=.response. " | sed 's/.*<result name=.response. numFound=.\([0-9]*\).*/\1/'`

echo "Solr:   $SOLR"
echo "Query:  $QUERY ($HITS hits, batch size $PAGE)"
echo "Fields: $FIELDS"
echo "Output: $OUT"

#echo "#"`echo "$FIELDS" |  tr ',' '\t'`" ($SOLR $QUERY)" > $OUT
PAGE_BASE="$BASE_URL&fl=$FIELDS&rows=$PAGE"
#PAGE_BASE="$BASE_URL&fl=$FIELDS&rows=$PAGE&sort=$ID+asc"
COUNT=0
while true; do
    if [ $COUNT -eq 0 ]; then
        INITIAL="$PAGE_BASE&start=0"
#        INITIAL="$PAGE_BASE&cursorMark=*"
        echo "Initial:$INITIAL"
        wget "$INITIAL" -O $T 2> /dev/null
    else 
#        wget "$PAGE_BASE&cursorMark=$NEXT_MARK" -O $T 2> /dev/null
        wget "$PAGE_BASE&start=$COUNT" -O $T 2> /dev/null
    fi
    get_fields $T
    # <str name="nextCursorMark">AoE/LWRvbXNfbmV3c3BhcGVyQ29sbGVjdGlvbjp1dWlkOjAxOWZmZDg4LWE0NmEtNDg5My05NTVhLTJhYzY4MWE4MDBhZS1zZWdtZW50XzQ=</str>
    HITS=`cat $T | grep "<result name=.response. " | sed 's/.*<result name=.response. numFound=.\([0-9]*\).*/\1/'`
    if [ "0" -eq "$HITS" -o "$HITS" -lt "$COUNT" ]; then
        break
    fi

#    OLD_MARK="$NEXT_MARK"
#    NEXT_MARK=`cat $T | grep nextCursorMark | sed 's/.*nextCursorMark..\(.*\)<\/str>.*/\1/'`
#    if [ ".$OLD_MARK" == ".$NEXT_MARK" ]; then
#        break
#    fi
#    echo -ne "\033[2K$COUNT/$HITS $NEXT_MARK\r"
    echo -ne "\033[2K$COUNT/$HITS\r"
    COUNT=$((COUNT+$PAGE))
done
echo ""
echo "Extracted `cat $OUT | wc -l` lines to ${OUT}. GZIPping and exiting"
gzip "$OUT"
#rm $T

# http://mars:56708/aviser/sbsolr/collection1/select?q=hest&fl=recordID&wt=xml&indent=true
#http://mars:56708/aviser/sbsolr/collection1/select?q=hest&sort=recordID+asc&fl=recordID&wt=xml&indent=true&facet=false&cursorMark=*
