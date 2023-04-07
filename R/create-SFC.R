

## Check python install, if no results or version < 3, see README
Sys.which("python")

library(reticulate)
library(sf)
library(tidyverse)

theme_set(theme_bw())


## RUN ONE TIME 
if (!("r-reticulate" %in% virtualenv_list())) {
  virtualenv_create("r-reticulate")
  
  virtualenv_install("r-reticulate", "numpy")
  virtualenv_install("r-reticulate", "geopandas")
  virtualenv_install("r-reticulate", "dask_geopandas")
}

## Work in specific virtual environment
use_virtualenv("r-reticulate")


## Load python function run_dgpd_hilbert(input_file, output_file)
## The function reads a point geodataframe, calculate hilbert distance and 
## save the results as a .gpkg file
source_python("python/run_dgpd_hilbert.py")

## Get path to grid points
path_in  <- "data/TL_point.gpkg"
path_out <- "data/TL_point_withSFC.gpkg"

## ---
## Run python function
run_dgpd_hilbert(input_file=path_in, output_file=path_out)
## ---
  
## Check 
sf_aoi   <- st_read("data/TimorLeste.geoJSON")
sf_grid  <- st_read("data/TL_grid.gpkg")
sf_point <- st_read("data/TL_point.gpkg") 
sf_sfc   <- st_read("data/TL_point_withSFC.gpkg") %>% arrange(dist)

gr <- ggplot() +
  geom_sf(data = sf_aoi, fill = "grey80", color = NA) +
  geom_sf(data = sf_grid, fill = NA) +
  geom_sf(data = sf_sfc, aes(color = dist)) +
  geom_path(data = sf_sfc, aes(x = x, y = y)) +
  coord_sf(crs = 4326)

print(gr)

summary(sf_sfc$x)
summary(sf_sfc$y)
