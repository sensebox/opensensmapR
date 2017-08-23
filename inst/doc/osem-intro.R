## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## ----results = F---------------------------------------------------------
library(magrittr)
library(opensensmapr)

all_sensors = osem_boxes()

## ------------------------------------------------------------------------
summary(all_sensors)

## ----message=F, warning=F------------------------------------------------
if (!require('maps'))     install.packages('maps')
if (!require('maptools')) install.packages('maptools')
if (!require('rgeos'))    install.packages('rgeos')

plot(all_sensors)

## ------------------------------------------------------------------------
phenoms = osem_phenomena(all_sensors)
str(phenoms)

## ------------------------------------------------------------------------
phenoms[phenoms > 20]

## ----results = F---------------------------------------------------------
pm25_sensors = osem_boxes(
  exposure = 'outdoor',
  date = Sys.time(), # ±4 hours
  phenomenon = 'PM2.5'
)

## ------------------------------------------------------------------------
summary(pm25_sensors)
plot(pm25_sensors)

## ------------------------------------------------------------------------
library(sf)
library(units)
library(lubridate)

# construct a bounding box: 12 kilometers around Berlin
berlin = st_point(c(13.4034, 52.5120)) %>%
  st_sfc(crs = 4326) %>%
  st_transform(3857) %>% # allow setting a buffer in meters
  st_buffer(units::set_units(12, km)) %>%
  st_transform(4326) %>% # the opensensemap expects WGS 84
  st_bbox()

## ----results = F---------------------------------------------------------
pm25 = osem_measurements(
  berlin,
  phenomenon = 'PM2.5',
  from = now() - days(7), # defaults to 2 days
  to = now()
)

plot(pm25)

## ------------------------------------------------------------------------
pm25_sf = osem_as_sf(pm25)
plot(st_geometry(pm25_sf), axes = T)

