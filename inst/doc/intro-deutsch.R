## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)

## ----results = FALSE----------------------------------------------------------
library(opensensmapr)
all_sensors = osem_boxes()

## -----------------------------------------------------------------------------
summary(all_sensors)

## ---- message=FALSE, warning=FALSE--------------------------------------------
plot(all_sensors)

## -----------------------------------------------------------------------------
phenoms = osem_phenomena(all_sensors)
str(phenoms)

## ----results = FALSE----------------------------------------------------------
pm10_sensors = osem_boxes(
  exposure = 'outdoor',
  date = Sys.time(), # ±4 hours
  phenomenon = 'PM10'
)

## -----------------------------------------------------------------------------
summary(pm10_sensors)
plot(pm10_sensors)

## ---- results=FALSE, message=FALSE--------------------------------------------
# Zunächst werden ein paar Pakete geladen, die es uns ermöglichen mit den räumlichen Daten zu arbeiten
library(sf)
library(units)
library(lubridate)
library(dplyr)
# Dann erstellen wir eine sogenannte Boundingbox, in unserem Fall ein 20 km x 20 km Quadrat um das Zentrum von Münster.
muenster = st_point(c(7.63, 51.95)) %>% # Koordinate Münster Zentrum
  st_sfc(crs = 4326) %>% # Koordinatensystem für geographische Koordinaten
  st_transform(3857) %>% # Koordinatensystem das Meter versteht
  st_buffer(set_units(10, km)) %>% # 10 km Radius um Münster
  st_transform(4326) %>% # Wieder Umwandlung in geographische Koordinaten, welche die openSenseMap API erwartet
  st_bbox() # erstellen eines boundingbox objektes

## ----bbox, results = FALSE----------------------------------------------------
pm10_muenster = osem_measurements(
  muenster, 
  phenomenon = 'PM10',
  from = now() - days(3), # defaults to 2 days
  to = now()
)

## -----------------------------------------------------------------------------
plot(pm10_muenster)

