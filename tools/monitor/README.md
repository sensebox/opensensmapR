# osem-monitor

Get the state of sensors and measurement counts for later analysis every 10 minutes.
The dataframe will reside in `./data/.RData`.

Further analysis can be done with the script `analyze.R`.

## docker image
```bash
# build 
docker build --tag osem-monitor .

# run
docker run -v $(pwd)/data:/script/data osem-monitor
```

## run manually

```bash
# install dependencies once
Rscript -e 'install.packages(c("dplyr", "magrittr", "devtools"))'
Rscript -e 'devtools::install_github("noerw/opensensmapR")'

Rscript --save --restore osem-monitor.R
```
