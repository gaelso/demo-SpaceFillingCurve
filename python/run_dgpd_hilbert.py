
import numpy as np
import geopandas as gpd
import dask_geopandas as dgpd


def run_dgpd_hilbert(input_file, output_file):
  
  gdf = gpd.read_file(input_file)
  
  dgdf = dgpd.from_geopandas(gdf, npartitions=4)
  
  gdf["dist"] = dgdf.geometry.hilbert_distance()
  
  gdf = gdf.sort_values("dist").reset_index()
  
  gdf.to_file(output_file)
  
  return 1
