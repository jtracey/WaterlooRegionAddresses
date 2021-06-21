#!/bin/sh

# the number of horizontal and vertical slices
rows=5
columns=5
# which orientation to slice first/second
columns_or_rows="columns then rows"
#columns_or_rows="rows then columns"

# the default filename to take as input
src=ODA_RoWAll_v1.csv

# if/when compacting, remove these fields
fields_to_remove='"source_id", "id", "group_id", "str_name", "str_type", "str_dir", "str_name_pcs", "str_type_pcs", "str_dir_pcs", "csduid", "csdname", "pruid"'

# if/when compacting, replace some long, repeated names with shorter ones
replace_names() {
    filename=$1
    for replacement in \
        'Region of Waterloo/RoW'  'The Corporation of the City of Kitchener/Kitchener' 'City of Cambridge/Cambridge'
    do
        sed -i "s/$replacement/g" "$filename"
    done
}

rm -rf slices
mkdir slices

if [ "$1" ] ; then
    src=$1
    echo "Using $src as data source"
else
    echo "Using default data source $src"
fi

if ! [ -f "$src" ] ; then
    echo "Data source not found; giving up"
    exit 1
fi

if ! command -v ogr2ogr > /dev/null ; then
    echo "ogr2ogr not installed; only generating csv files"
else
    geojson=true
    if ! command -v jq > /dev/null ; then
        echo "jq not installed; not generating compact geojson files"
    else
        compactjson=true
    fi
fi

if [ "$columns_or_rows" = "columns then rows" ] ; then
    first=2
    second=1
elif [ "$columns_or_rows" = "rows then columns" ] ; then
    first=1
    second=2
else
    echo 'columns_or_rows must be set to one of "columns then rows" or "rows then columns"'
    exit 1
fi

keys=$(head -1 "$src")
tail +2 "$src" | sort -n -t, -k$first > .sort1
linecount=$(wc -l .sort1 | cut -d' ' -f1)
rowcount=$(($linecount / $rows + 1))
columncount=$(($rowcount / $columns + 1))

split -d -l "$rowcount" \
      --filter="sort -n -t, -k$second | \
                split -d -l $columncount \
                      --filter='echo $keys > slices/\$FILE.csv ; \
                                tee foo >> slices/\$FILE.csv' \
                      - \$FILE." \
      .sort1 ''
rm .sort1

if ! [ "$geojson" ] ; then exit 0 ; fi

for csv in slices/*.csv ; do
    filename=${csv%.csv}
    echo "creating $filename.full.geojson..."
    ogr2ogr -f "geojson" \
            $filename.full.geojson \
            $csv \
            -oo X_POSSIBLE_NAMES=longitude \
            -oo Y_POSSIBLE_NAMES=latitude \
            -oo KEEP_GEOM_COLUMNS=NO \
            -oo EMPTY_STRING_AS_NULL=YES
    if [ "$compactjson" ] ; then
        echo "removing extraneous fields and compacting to $filename.geojson..."
        jq -c "del(.features[].properties [$fields_to_remove]) | \
               walk(if type == \"object\" then \
                       with_entries(select(.value != null)) \
                    else . end)" $filename.full.geojson > $filename.geojson
        replace_names $filename.geojson
    fi
done
