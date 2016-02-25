FROM ubuntu:latest
MAINTAINER "Carlos Petricioli" carpetri@gmail.com

RUN useradd docker \
  && mkdir /home/docker \
  && chown docker:docker /home/docker \
  && addgroup docker staff

RUN apt-get update \ 
  && apt-get install -y \
  software-properties-common \
  ed \
  less \
  locales \
  vim-tiny \
  wget \
  ca-certificates \
  && apt-get update 

## Configure default locale.
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && locale-gen en_US.utf8 \
  && /usr/sbin/update-locale LANG=en_US.UTF-8

## Now install R, and create a link for littler in /usr/local/bin
RUN echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list && \
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
  apt-get update

RUN sudo apt-get install -y  \
    r-base \
    r-base-dev \
    r-recommended \
    r-cran-stringr \
    && echo 'options(repos = c(CRAN = "https://cran.itam.mx/"), download.file.method = "wget")' >> /etc/R/Rprofile.site \
    && R --version

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

## Add RStudio binaries to PATH
ENV PATH $PATH:/usr/lib/rstudio-server/bin/

## Download and install RStudio server & dependencies
## Attempts to get detect latest version, otherwise falls back to version given in $VER
## Symlink pandoc, pandoc-citeproc so they are available system-wide
RUN rm -rf /var/lib/apt/lists/ \
  && apt-get update \
  # && apt-get install -y #-t unstable --no-install-recommends \
  && apt-get install -y \
    ca-certificates \
    file \
    git \
    libapparmor1 \
    libedit2 \
    libcurl4-openssl-dev \
    libssl1.0.0 \
    libssl-dev \
    psmisc \
    supervisor \
    sudo \
  && VER=$(wget --no-check-certificate -qO- https://s3.amazonaws.com/rstudio-server/current.ver) \
  && wget -q http://download2.rstudio.org/rstudio-server-${VER}-amd64.deb \
  && dpkg -i rstudio-server-${VER}-amd64.deb \
  && rm rstudio-server-*-amd64.deb \
  && ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc /usr/local/bin \
  && ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc-citeproc /usr/local/bin \
  && wget https://github.com/jgm/pandoc-templates/archive/1.15.0.6.tar.gz \
  && mkdir -p /opt/pandoc/templates && tar zxf 1.15.0.6.tar.gz \
  && cp -r pandoc-templates*/* /opt/pandoc/templates && rm -rf pandoc-templates* \
  && mkdir /root/.pandoc && ln -s /opt/pandoc/templates /root/.pandoc/templates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/

## Ensure that if both httr and httpuv are installed downstream, oauth 2.0 flows still work correctly.
RUN R -s -e 'if(is.na(Sys.getenv("HTTR_LOCALHOST", unset=NA))) { options(httr_oob_default = TRUE) }' >> /etc/R/Rprofile.site
# RUN echo '\n\
# \n# Configure httr to perform out-of-band authentication if HTTR_LOCALHOST \
# \n# is not set since a redirect to localhost may not work depending upon \
# \n# where this Docker container is running. \
# \nif(is.na(Sys.getenv("HTTR_LOCALHOST", unset=NA))) { \
# \n  options(httr_oob_default = TRUE) \
# \n}' >> /etc/R/Rprofile.site

## We want user to be 'rstudio', but it is 'docker'
RUN usermod -l rstudio docker \
  && usermod -m -d /home/rstudio rstudio \
  && groupmod -n rstudio docker \
  && echo '"\e[5~": history-search-backward' >> /etc/inputrc \
  && echo '"\e[6~": history-search-backward' >> /etc/inputrc \
  && echo "rstudio:rstudio" | chpasswd

## User config and supervisord for persistant RStudio session
COPY userconf.sh /usr/bin/userconf.sh
COPY add-students.sh /usr/local/bin/add-students
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/log/supervisor \
  && chgrp staff /var/log/supervisor \
  && chmod g+w /var/log/supervisor \
  && chgrp staff /etc/supervisor/conf.d/supervisord.conf

# Download and install shiny server
RUN sudo apt-get update && sudo apt-get -y install gdebi-core
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb

# Se necesita postgres y otros paquetes.

#python
RUN sudo apt-get update && apt-get install -y \
  python2.7 \
  python-setuptools \
  python-pip \
  python-numpy \
  python-scipy

RUN sudo apt-get install -y \
  libblas-dev \
  liblapack-dev \
  gfortran \
  libcairo2-dev\
  libxt-dev \
  git-core 

RUN sudo apt-get install -y \
  postgresql \
  postgresql-doc \
  libpq5 \
  postgresql-contrib \
  gdal-bin \
  wget

RUN sudo apt-get install -y libpq-dev \
  libxml2-dev libssh2-1-dev

# RUN sudo apt-get -y  install texlive-latex-base
RUN sudo apt-get install -y texlive-full

#R Packages
COPY instala_paquetes.R /home/rstudio/instala_paquetes.R
RUN sudo -i R -f /home/rstudio/instala_paquetes.R

# Para la configuración del servidor de shiny.

COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf
COPY shiny-server.sh /usr/bin/shiny-server.sh
RUN chmod +x /usr/bin/shiny-server.sh

EXPOSE 8787
EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]