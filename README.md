# gis_ml_workflow_example

The above notebook provides an example of how to work with raster & vector files using some of the most popular open source libraries such as geopandas, shapely, rasterio etc...

In addition to interacting with raster files, the notebook will demonstrate how to use Solaris to carry out semantic segmentation on the builigs in the raster file.

The above is a work in progress and will be updated to include more examples such as: 

* Creating chips from a larger raster image.
* Finetuning a model
* Creating a model from scratch

For now there is one example image with its corresponding vector file. 

# Setting up the environment

## Using Conda

`conda create env -n env_name -f environment.yml python 3.8.6`

`conda activate env_name`

## Using Docker

`docker-compose up -d`

`docker-compose logs`

extract the notebooke address from the command above and run it in the environment of you choice.
