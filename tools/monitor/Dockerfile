FROM r-base

RUN apt-get update && \
    apt-get install -y libssl-dev libcurl3-dev cron libgdal-dev libgeos-dev libproj-dev libudunits2-dev liblwgeom-dev

# install dependencies
RUN Rscript -e 'install.packages("sf")'
RUN Rscript -e 'install.packages("magrittr")'
RUN Rscript -e 'install.packages("devtools")'
RUN Rscript -e 'devtools::install_github("noerw/opensensmapR")'

# install crontab
COPY crontab /crontab
RUN /usr/bin/crontab /crontab

RUN apt-get clean && apt-get autoremove -y

# install script
COPY get-counts.R /script/get-counts.R
COPY get-boxes.R /script/get-boxes.R

WORKDIR /script/data
CMD ["cron", "-f"]
