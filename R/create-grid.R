

library(sf)
library(dggridR)
library(tidyverse)
library(tmap)
theme_set(theme_bw())


## USER INPUT: DGGRID RESOLUTION
## See https://github.com/r-barnes/dggridR
res  <- 12

sf_aoi <- st_read("data/TimorLeste.geoJSON") %>% 
  st_transform(4326) %>%
  mutate(country = "Timor Leste")

bbox_aoi <- st_bbox(sf_aoi)

dggs     <- dgconstruct(res = res)
dist     <- dggridR:::GridStat_cellDistKM(dggs[['projection']], dggs[['topology']], dggs[['aperture']], res)
dist_deg <- round(dist / 111 * 0.75, 6) ## calc degree with some margin of error
sf_grid1 <- dgrectgrid(
  dggs     = dggs,
  minlat   = floor(bbox_aoi$ymin),
  minlon   = floor(bbox_aoi$xmin),
  maxlat   = ceiling(bbox_aoi$ymax),
  maxlon   = ceiling(bbox_aoi$xmax),
  cellsize = dist_deg
)

sf_point <- st_centroid(sf_grid1) %>%
  st_join(sf_aoi) %>%
  filter(!is.na(country)) %>%
  mutate(
    x = st_coordinates(.)[,1],
    y = st_coordinates(.)[,2]
  )

sf_grid <- sf_grid1 %>%
  filter(seqnum %in% sort(sf_point$seqnum))

ggplot() +
  geom_sf(data = sf_aoi, fill = "grey80", color = NA) +
  geom_sf(data = sf_grid, fill = NA) +
  geom_sf(data = sf_point, aes(color = seqnum)) 

st_write(sf_grid , "data/TL_grid.gpkg" , append = F)
st_write(sf_point, "data/TL_point.gpkg", append = F)
