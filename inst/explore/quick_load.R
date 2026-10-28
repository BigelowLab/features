suppressPackageStartupMessages({
  library(features)
  library(sf)
  library(dplyr)
})

x = read_database(add_feature = TRUE)


file = "/mnt/s1/projects/ecocast/coredata/features/temp/Maine_Ecoregions.geojson"
name = "maine_ecoregions"
longname = "Maine Ecoregions"
ref = "Maine Office of GIS"
url = "https://maine.hub.arcgis.com/maps/maine::maine-ecoregions/about"

r = add_feature(name, longname, file,
                ref = ref,
                url = url)
