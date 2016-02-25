#!/bin/bash

# If you are using docker-machine, you need to create a bigger machine.
# To do so you can take my example. (sizes are in MB.)
# docker-machine create --driver=virtualbox --virtualbox-disk-size=30000 --virtualbox-memory=12288 --virtualbox-cpu-count=4 maquina

# After creating the machine you will want to add it to your bash profile so that your docker knows where to find it

docker-machine env maquina                                                                                                       

# export DOCKER_TLS_VERIFY="1"
# export DOCKER_HOST="tcp://192.168.99.101:2376"
# export DOCKER_CERT_PATH="/Users/Carlos/.docker/machine/machines/maquina"
# export DOCKER_MACHINE_NAME="maquina"
# Run this command to configure your shell: 
# eval "$(docker-machine env maquina)"

# Once created you can pull the docker image: carpetri/base
docker pull carpetri/base

# To start the docker pick your machine name, and add the shared folders you want (-v flag). Ports 80 and 8787 correspond to shiny and rstudio server. 

docker run -it --name rstudio -d -p 8787:8787 -p 80:80 -v $aliada_dir/stats/Dashboard/:/srv/shiny-server/ -v $aliada_dir/aliada_app:/home/rstudio/aliada_app -v $aliada_dir/stats:/home/rstudio/stats carpetri/base

# Once created start it and exec shiny-server
docker start rstudio && docker exec shiny-server &

# Now you are ready to use rstudio and preview the shiny server.