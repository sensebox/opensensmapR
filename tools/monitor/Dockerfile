FROM r-base

RUN apt-get update && \
    apt-get install -y libssl-dev libcurl3-dev cron

# install dependencies
RUN Rscript -e 'install.packages("httr")'
RUN Rscript -e 'install.packages("dplyr")'
RUN Rscript -e 'install.packages("magrittr")'
#RUN Rscript -e 'install.packages("readr")'

# install opensensemap package
RUN Rscript -e 'install.packages("devtools")'
RUN Rscript -e 'devtools::install_github("noerw/opensensmapR")'

COPY docker-entry.sh /docker-entry.sh
RUN chmod 0755 /docker-entry.sh

# install crontab
COPY crontab /crontab
RUN /usr/bin/crontab /crontab


# install script
COPY osem-monitor.R /script/osem-monitor.R
WORKDIR /script/data

CMD ["/docker-entry.sh"]
