# Development Documentation
This file contains documentation for running the scripts, as well as modifying them.

## Creating the files yourself

The [fetch_data.sh](fetch_data.sh) script will generate four or five CSV files:
 - **ODA_ON_v1.csv**: The entire data set for Ontario. If you already have this, you can provide the full path as the first argument to the script; otherwise, the script will try to find it by default in the same directory the script is being run from. If the script can't find it, it will be extracted from the ODA_ON_v1.zip file StatCan provides, downloading it if necessary (requires `wget` and `unzip` for download and extraction, respectively).
 - **ODA_RoW_v1.csv**: Data from the `ODA_ON_v1.csv` file that lists the Region of Waterloo as its source.
 - **ODA_Kitchener_v1.csv**: Data from the `ODA_ON_v1.csv` file that lists the City of Kitchener as its source.
 - **ODA_Cambridge_v1.csv**: Data from the `ODA_ON_v1.csv` file that lists the City of Cambridge as its source.
 - **ODA_RoWAll_v1.csv**: The union of the above three CSV files.

The City of Waterloo doesn't seem to have any data provided. Note that many of the addresses provided by the two municipalities are also provided by the Region.

Assuming your computer has enough memory for it, any of the last four CSV files can be opened in JOSM with the opendata plugin. But, CSV files are not supported in iD, and even if it could open them, iD would struggle with their size. As such, another script is provided.

The [gen_slices.sh](gen_slices.sh) script breaks the `ODA_RoWAll_v1.csv` script generated above into 25 equally sized (by address count) "slices", turns them into geojson files iD can use, and cleans them up to reduce their size. The conversion step requires [ogr2ogr](https://gdal.org/programs/ogr2ogr.html), which comes with the popular [gdal](https://gdal.org) library, and the compacting step requires the standard [jq](https://stedolan.github.io/jq/) utility.

The [gen_bounding_boxes.sh](gen_bounding_boxes.sh) script creates the `bounding_boxes.geojson` file, which can be used to show what area each of the slices represents.

## Porting to other locations
The scripts are written with the intent of making them simple to port to other locations.

To change the [fetch_data.sh](fetch_data.sh) script, modify the variables in the top lines of the file. If you want to change it to a province/territory other than Ontario, modify the `ODA` variable to the respective part of the name of the corresponding file provided on the [ODA web page](https://www.statcan.gc.ca/eng/lode/databases/oda) (look at the end of the URLs of the links; should be a 2 letter difference). You'll also want to manually download the file, so you can examine the files to replace the other variables. (You probably don't want to open the actual ODA CSV in a spreadsheet program or text editor; if you aren't comfortable with exploring data via the command line, everything you need to modify the scripts should be in the more manageable Data_sources.csv and *_metadata.pdf files.) The comments in the script explain what you need to change.

The [gen_slices.sh](gen_slices.sh) script technically does not require any changes, but you'll likely want to make some anyway. The number of slices needed will depend on the density of the area you're accommodating -- too few slices, and the files it makes will be too big to open in iD; too many slices, and the files will cover areas too small to be of much use. Changing the orientation of the slices is optional, and a purely aesthetic decision (they're the same size in terms of number of addresses regardless, though you might be able to get them closer to uniform size physically in one orientation vs. the other). You'll also likely want to change the default filename it looks for to match the one you set in `fetch_data.sh`. The `fields_to_remove` should be fine everywhere as-is, but might need to be changed if there is a different set of fields that are relevant for some reason. Finally, the `replace_names` function near the top has a list of string replacements that help keep the size of the file down. E.g., repeating "The Corporation of the City of Kitchener" for every single address Kitchener provided takes up a lot more space than the equally informative (for our purposes) "Kitchener". You may add additional replacements of the form `'text being replaced/text to replace it with'` to that line to make the compacted geojson files smaller, and remove replacements you don't need to make the script run a bit faster.

There shouldn't be any reason changing the [gen_bounding_boxes.sh](gen_bounding_boxes.sh) script would be necessary, but feel free to if you'd like to change how it looks (see [GitHub's documentation](https://docs.github.com/en/github/managing-files-in-a-repository/working-with-non-code-files/mapping-geojson-files-on-github)).
