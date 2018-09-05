# osem-monitr

Get the state of sensors and measurement counts for later analysis every 15 minutes.
The dataframes will reside in `./data/.RData`.

Further analysis can be done with the script `analyz.R`.

## docker image
```bash
alias dockr='docker '

# build 
docker build --tag osem-monitr .

# run
docker run -v $(pwd)/data:/script/data osem-monitr
```

## run manually

```bash
# install dependencies once
Rscript -e 'install.packages(c("dplyr", "magrittr", "devtools"))'
Rscript -e 'devtools::install_github("sensebox/opensensmapR")'

Rscript --save --restore get-counts.R
Rscript --save --restore get-boxes.R
```
