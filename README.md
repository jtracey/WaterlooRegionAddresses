# WaterlooRegionAddresses
Scripts for generating smaller, more manageable address data from the [StatCan ODA](https://www.statcan.gc.ca/eng/lode/databases/oda), targeted at the Region of Waterloo.

## What is the StatCan ODA?
Statistics Canada has released a collection of address data from across the country called The Open Database of Addresses, or ODA for short. All of this data was nominally publicly available before, but from various sources, under different licenses. This made it more difficult to find, and more difficult to have legal assurance that it could be collated into other projects. Notably, the license the ODA is released under (the [OGL Canada](https://open.canada.ca/en/open-government-licence-canada)) is one of the licenses that have been [approved by the legal working group](https://wiki.osmfoundation.org/wiki/OGL_Canada_and_local_variants) for integration into [OpenStreetMap](https://www.openstreetmap.org/).

## Why is this necessary?
Statistics Canada only provides the ODA divided on a provincial/territorial level. This is far too much data to comfortably operate on with any GUI OpenStreetMap editor. These scripts filter and break down the data into what is relevant for OpenStreetMap contributors in Waterloo Region. The scripts are fairly simple, and can therefore also be [adopted to other regions](PORTING.md) as desired, with some basic familiarity with Unix shell scripting.

## What can I get here?
If all you want is the data for use in iD, the geojson files are located in the [slices directory](slices). Anything else, you can generate manually yourself using the provided scripts.

The [fetch_data.sh](fetch_data.sh) script will generate four or five CSV files:
 - **ODA_ON_v1.csv**: The entire data set for Ontario. If you already have this, you can provide the full path as the first argument to the script; otherwise, the script will try to find it by default in the same directory the script is being run from. If the script can't find it, it will be extracted from the ODA_ON_v1.zip file StatCan provides, downloading it if necessary (requires `wget` and `unzip` for download and extraction, respectively).
 - **ODA_RoW_v1.csv**: Data from the `ODA_ON_v1.csv` file that lists the Region of Waterloo as its source.
 - **ODA_Kitchener_v1.csv**: Data from the `ODA_ON_v1.csv` file that lists the City of Kitchener as its source.
 - **ODA_Cambridge_v1.csv**: Data from the `ODA_ON_v1.csv` file that lists the City of Cambridge as its source.
 - **ODA_RoWAll_v1.csv**: The union of the above three CSV files.

The City of Waterloo doesn't seem to have any data provided. Note that many of the addresses provided by the two municipalities are also provided by the Region.

Assuming your computer has enough memory for it, any of the last four CSV files can be opened in JOSM with the opendata plugin. But, CSV files are not supported in iD (the default OSM editor on the OSM website), and even if it could open them, iD would struggle with their size. As such, another script is provided.

The [gen_slices.sh](gen_slices.sh) script breaks the `ODA_RoWAll_v1.csv` script generated above into 25 equally sized (by address count) "slices", turns them into geojson files iD can use, and cleans them up to reduce their size. The conversion step requires [ogr2ogr](https://gdal.org/programs/ogr2ogr.html), which comes with the popular [gdal](https://gdal.org) library, and the compacting step requires the standard [jq](https://stedolan.github.io/jq/) utility.


# A Note About Licensing
This repository is licensed under the Apache 2.0 license, but as stated above, the address data itself is released under the terms of the OGL Canada. I.e., any scripts or code hosted here are under the terms given in the [LICENSE](LICENSE) file, but any downloaded or generated data, such as CSV or geojson files, including those in the [slices directory](slices), are produced under the terms of the [OGL Canada](https://open.canada.ca/en/open-government-licence-canada).
