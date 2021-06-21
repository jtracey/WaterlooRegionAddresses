# WaterlooRegionAddresses
Scripts for generating smaller, more manageable address data from the [StatCan ODA](https://www.statcan.gc.ca/eng/lode/databases/oda), targeted at the Region of Waterloo.

## What is the StatCan ODA?
Statistics Canada has released a collection of address data from across the country called The Open Database of Addresses, or ODA for short. All of this data was nominally publicly available before, but from various sources, under different licenses. This made it more difficult to find, and more difficult to have legal assurance that it could be collated into other projects. Notably, the license the ODA is released under (the [OGL Canada](https://open.canada.ca/en/open-government-licence-canada)) is one of the licenses that have been [approved by the legal working group](https://wiki.osmfoundation.org/wiki/OGL_Canada_and_local_variants) for integration into [OpenStreetMap](https://www.openstreetmap.org/).

## Why is this necessary?
Statistics Canada only provides the ODA divided on a provincial/territorial level. This is far too much data to comfortably operate on with any GUI OpenStreetMap editor. These scripts filter and break down the data into what is relevant for OpenStreetMap contributors in Waterloo Region. The scripts are fairly simple, and can therefore also be [adopted to other regions](PORTING.md) as desired, with some basic familiarity with Unix shell scripting.

## What can I get here?
The [fetch_data.sh](fetch_data.sh) script will generate four or five CSV files:
 - **ODA_ON_v1.csv**: The entire data set for Ontario. If you already have this, you can provide the full path as the first argument to the script; otherwise, the script will try to find it by default in the same directory the script is being run from. If the script can't find it, it will be extracted from the ODA_ON_v1.zip file StatCan provides, downloading it if necessary (requires `wget` and `unzip` for download and extraction, respectively).
 - **ODA_RoW_v1.csv**: Data from the `ODA_ON_v1.csv` file that lists the Region of Waterloo as its source.
 - **ODA_Kitchener_v1.csv**: Data from the `ODA_ON_v1.csv` file that lists the City of Kitchener as its source.
 - **ODA_Cambridge_v1.csv**: Data from the `ODA_ON_v1.csv` file that lists the City of Cambridge as its source.
 - **ODA_RoWAll_v1.csv**: The union of the above three CSV files.

The City of Waterloo doesn't seem to have any data provided. Note that many of the addresses provided by the two municipalities are also provided by the Region.

Assuming your computer has enough memory for it, any of the last four CSV files can be opened in JOSM with the opendata plugin. But, CSV files are not supported in iD (the default OSM editor on the OSM website), and even if it could open them, iD would struggle with their size. As such, another script is provided.

The [gen_slices.sh](gen_slices.sh) script breaks the `ODA_RoWAll_v1.csv` script generated above into 25 equally sized (by address count) "slices", turns them into geojson files iD can use, and cleans them up to reduce their size. The conversion step requires [ogr2ogr](https://gdal.org/programs/ogr2ogr.html), which comes with the popular [gdal](https://gdal.org) library, and the compacting step requires the standard [jq](https://stedolan.github.io/jq/) utility.

## What can I do with this?
**Do not import this data to OSM.** It is not structured for direct import, and the quality isn't always great. The Region already has, from previous StatCan imports, block-level address data represented as [address interpolations](https://wiki.openstreetmap.org/wiki/Addresses#Using_interpolation) in OSM which are in many ways better than this data. What you *can* use it for is another reference while editing, similar to aerial imagery, but for addresses. E.g., if you notice all the houses on a block have address data except one, you can use this to look up what the address of that house is.

In iD (again, that's the default web editor on the OpenStreetMap website), press F or the Map Data button on the right, then hit the three dot menu on Custom Map Data to upload a geojson file. It'll take a bit to open, but once it does, these slices seem small enough to not have a significant impact on performance. In JOSM, you can just open any of the geojson files -- just be sure to keep OSM data and this data in separate layers. If you enabled the opendata plugin in JOSM's settings, you can also open any of the CSV files.

Some tips for using the data:
 - Cite it as `StatCan 46-26-0001` in your changeset's sources. Even if your edits in this changeset consist mostly of other things, if you used this data, you need to cite it.
 - When you're using this data, do some basic sanity checks on it. Sometimes errors can be found with obvious context, like an address that's half a block away from the supposed street it's on, or if the house number is far too large/small for this block, or an even number on the odd side of the street.
 - City data is usually, but not always, more accurate than RoW data. If the two disagree, it should be left to a ground survey (or if it's something that has a website, you can check that), but if even that is inconclusive, defer to city data.
 - Sometimes there will be a bunch of apartment addresses (typically with unit numbers) clustered in an apartment building, haphazardly thrown about on it. These are essentially unusable, since they often don't correspond to actual physical location within the building, and will sometimes list units that don't actually exist, or miss units that do. The situation is similar for row houses.

# A Note About Licensing
This repository is licensed under the Apache 2.0 license, but as stated above, the address data itself is released under the terms of the OGL Canada. I.e., any scripts or code hosted here are under the terms given in the [LICENSE](LICENSE) file, but any downloaded or generated data, such as CSV or geojson files, are produced under the terms of the [OGL Canada](https://open.canada.ca/en/open-government-licence-canada).
