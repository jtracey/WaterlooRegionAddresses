#!/bin/sh

echo '{ "type": "FeatureCollection",'
echo '  "features": ['
first=true
for csv in slices/*.*.csv ; do
    minmaxlat="$(cut -d, -f1 $csv | tail +2 | sort -n | (head -1 && tail -1))"
    minlat=$(echo "$minmaxlat" | head -1)
    maxlat=$(echo "$minmaxlat" | tail -1)
    minmaxlon="$(cut -d, -f2 $csv | tail +2 | sort -n | (head -1 && tail -1))"
    minlon=$(echo "$minmaxlon" | head -1)
    maxlon=$(echo "$minmaxlon" | tail -1)
    if [ $first ] ; then
        unset first
    else
        echo ,
    fi
    echo '  { "type": "Feature",'
    echo '    "properties": {"name": "'$(basename $csv .csv)'"},'
    echo '    "geometry": {'
    echo '      "type": "Polygon",'
    echo '      "coordinates":' "[[[$minlon, $minlat], [$maxlon, $minlat], [$maxlon, $maxlat], [$minlon, $maxlat], [$minlon, $minlat]]]"
    echo '    }'
    echo -n '  }'
done
echo
echo '  ]'
echo '}'
