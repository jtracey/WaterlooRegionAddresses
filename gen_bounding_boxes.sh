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
    name=$(basename $csv .csv)
    if [ $first ] ; then
        unset first
    else
        echo ,
    fi
    echo '  { "type": "Feature",'
    echo '    "properties": {'
    echo '      "name": "'$name'",'
    echo '      "github_url": "https://github.com/jtracey/WaterlooRegionAddresses/blob/main/slices/'$name'.geojson",'
    echo '      "raw_url": "https://github.com/jtracey/WaterlooRegionAddresses/raw/main/slices/'$name'.geojson"'
    echo '    },'
    echo '    "geometry": {'
    echo '      "type": "Polygon",'
    echo '      "coordinates":' "[[[$minlon, $minlat], [$maxlon, $minlat], [$maxlon, $maxlat], [$minlon, $maxlat], [$minlon, $minlat]]]"
    echo '    }'
    echo -n '  }'
done
echo
echo '  ]'
echo '}'
