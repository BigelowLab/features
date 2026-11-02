suppressPackageStartupMessages({
  library(features)
  library(sf)
  library(dplyr)
})

x = read_database()


file = "/mnt/s1/projects/ecocast/coredata/features/temp/Maine_Boat_Launches_GeoLibrary.geojson"
name = "maine_boat_launches"
longname = "Maine Boat Launches"
ref = "Maine Office of GIS"
url = "https://mainegeolibrary-maine.hub.arcgis.com/datasets/maine::maine-boat-launches-geolibrary/about"

r = add_feature(name, longname, file,
                ref = ref,
                url = url)
