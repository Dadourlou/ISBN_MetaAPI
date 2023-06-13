FROM rocker/r-base
MAINTAINER Alexandre LECOEUR <alexandre.lecoeur@dadourlou.fr>
RUN apt-get update -qq && apt-get install -y \
  git-core \
  libssl-dev \
  libcurl4-gnutls-dev \
  libxml2-dev \
  libsodium-dev

RUN R -e 'install.packages("xml2")'
RUN R -e 'install.packages("httr")'
RUN R -e 'install.packages("rlist")'
RUN R -e 'install.packages("jsonlite")'
RUN R -e 'install.packages("plumber")'
RUN mkdir /usr/scripts
COPY torun.R /home/admin/Api_ISBN_Plumber/torun.R
COPY plumber.R /home/admin/Api_ISBN_Plumber/plumber.R
EXPOSE 7777
CMD Rscript /home/admin/Api_ISBN_Plumber/torun.R
