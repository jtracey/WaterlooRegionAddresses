#!/bin/sh
set -e

# Change this to use a different province/territory:
ODA=ODA_ON_v1

# Change the following to use different regions/municipalities:
# A hack to avoid arrays, to maintain portability, these names must match
# the locationSearch* variable names below. They're also used in the filenames
# we output to.
locationNames="RoW Kitchener Cambridge"
# These search variables are set to the source names, which can be found in
# Data_Sources.csv, or the "provider" column in the actual data CSV.
# Again, the variable names should match what you put in locationNames ^
locationSearchRoW="Region of Waterloo"
locationSearchKitchener="The Corporation of the City of Kitchener"
locationSearchCambridge="City of Cambridge"
# The name used for the combined file
combinedName="RoWAll"

if [ "$1" ] ; then
    src=$1
    echo "using $src as data source"
    if ! [ -f "$src" ] ; then
        echo "File \"$src\" not found. Either download and extract the file yourself, providing the full path to the extracted file as the first option, or run without arguments to let the script download and extract it for you."
        exit 1
    fi
else
    src=$ODA.csv
    echo "using default filename $src as data source"
fi

if ! [ -f "$src" ] ; then
    echo "File \"$src\" not found, attempting to fetch..."
    if ! [ -f $ODA.zip ] ; then
        echo "downloading zip from statcan..."
        wget https://www150.statcan.gc.ca/n1/pub/46-26-0001/2021001/$ODA.zip
    fi
    echo "unzipping..."
    unzip $ODA.zip $ODA.csv
fi

keys=$(head -1 "$src")

echo $keys > ODA_${combinedName}_v1.csv
for name in $locationNames ; do
    echo "creating ODA_${name}_v1.csv and adding it to ODA_${combinedName}_v1.csv..."
    # the hack to avoid arrays mentioned above
    locationSearch=$(eval echo \${locationSearch$name})
    (echo $keys && grep "$locationSearch" "$src") |
            tee "ODA_${name}_v1.csv" |
            tail -n +2 >> "ODA_${combinedName}_v1.csv"
done
