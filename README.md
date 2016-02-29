# Docker Base

## ¿Qué es docker?

Es una plataforma de virtualización además de un conjunto de comandos para establecer *workflows* de trabajo que permitan crear, instalar, compartir etc, aplicaciones.

**Docker** está compuesto de dos partes un *daemon* o un servidor y un *cliente*, el comando `docker`. 

## Instalación

- [Mac OS X](https://docs.docker.com/mac/step_one/)
- [Ubuntu](https://docs.docker.com/linux/step_one/)
- [MS Windows](https://docs.docker.com/windows/step_one/)

## Detalles adicionales de Mac-OS X y Windows.

En linux:

![](https://docs.docker.com/engine/installation/images/linux_docker_host.svg)


En Mac y Windows los contenedores de dokcer corren en una máquina virtual que corre en Linux. Por default el controlador es VirtualBox. 

![](https://docs.docker.com/engine/installation/images/mac_docker_host.svg)


La manera de crear nuevas máquinas con características específicas es con el siguiente comando.

```
docker-machine create --driver=virtualbox --virtualbox-disk-size=30000 --virtualbox-memory=12288 --virtualbox-cpu-count=4 maquina
```
En donde `--virtualbox-disk-size` se refiere al tamaño en *megabytes* del disco duro de la máquina virtual que contiene los contenedores de `docker`, `--virtualbox-memory` se refiere al tamaño en *megabytes* de la memoria RAM y, finalmente, `--virtualbox-cpu-count` se refiere al número de procesadores.

> **NOTA** Para ejecutar la imagen base: `carpetri/base` se necesita más disco duro que el default, pesa alrededor de 3GB.

## Imágen y contenedores

Una **imagen** es una especie de cascarón o plantilla no modificable. 

> **Ejemplo** 
> Ejemplos de imágenes son `ubuntu` y la imagen del repositorio (`carpetri/base`).

Un **contenedor** es creado a partir de una *imagen*. Los contenedores es aquello con lo que vas a interactuar. Pueden ser ejecutados, iniciados, detenidos, movidos, borrados, etc. Cada contenedor es un ambiente aislado. Aunque pueden ser [conectados entre sí](http://docs.docker.com/userguide/dockerlinks/).


Para ver qué imágenes hay en tu computadora:

```
docker images
```

> **NOTA:** Si están en `ubuntu` y no configuraron su usuario como miembros del grupo `docker` agreguen `sudo` al principio de cada comando 

> **NOTA** Al final de las instrucciones de instalación en ubuntu, viene como eliminar la molestia de teclear `sudo` antes de todos los comandos.

- Verifiquen que el *daemon* esté corriendo con `docker run hello-world`, se debería de mostrar algo parecido a lo siguiente:

```
docker run hello-world
Unable to find image 'hello-world:latest' locally
hello-world:latest: The image you are pulling has been verified

31cbccb51277: Pull complete 
e45a5af57b00: Pull complete 
511136ea3c5a: Already exists 
Status: Downloaded newer image for hello-world:latest
Hello from Docker.
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (Assuming it was not already locally available.)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

For more examples and ideas, visit:
 http://docs.docker.com/userguide/

```

- Descarguen una *imagen* de `ubuntu`


```
docker pull ubuntu:latest
```

- (Si la red está imposible, pidan el `USB stick` y ejecuten `docker load < /home/ubuntu-latest.tar`)

- Verifiquen que la imagen esté en su computadora

```
docker images
```


- Para crear un contenedor interactivo:

```
docker run -i -t ubuntu /bin/bash
```

(Aquí podemos hacer lo que se pide en las siguientes secciones de este *lecture*)


Para salir de este contendor tecleen `exit`.

- Para verificar que el contenedor está ahí:

```
docker ps -a
```


**Nota** Si estás en MacOS ó Windows, apunta la dirección IP en la cual está corriendo `docker-machine`:

```
docker-machine ip <nombre_del_contenedor>
```


## Imagen base

Descargar

```
docker pull carpetri/base
```

Crear un contenedor:

```
docker run -it --name <nombre_del_contenedor> -d -p 8787:8787 -p 80:80 -v <path_a_una_carpeta_de_shiny>:/srv/shiny-server/ -v <path_a_carpeta>:/home/rstudio/<nombre_de_carpeta> carpetri/base
```


El `path_a_carpeta` se refiere a la salida del comando `pwd` en tu carpeta donde guardes tus proyectos (recomendado: `proyectos`).
En MS Windows regularmente es algo como `/c/Users/<Mi nombre de usuario en mi compu>/proyectos` y en MacOS es `/Users/<Minombre de usuario>/proyectos`.


Podemos probar que está ejecutándose `RStudio`:

Abran en el navegador la página `http://0.0.0.0:8787` (Si estás en GNU/Linux) o `http://192.168.99.100:8787` (quizá sea esta, verifica el paso del `docker-machine ip defalt`), deberían de ver la entrada de RStudio.


Las credenciales son:

  - usuario: `rstudio`
  - password: `rstudio`


Para salir de `docker` usen `Ctrl-C`.


## ¿Y la próxima vez?

- La siguiente vez que quieras ejecutar `docker` usa el siguiente comando:

```
docker start  <nombre_del_contenedor> # Esto funciona si ejecutaste la versión de demonio
```

o

```
docker start -a -i <nombre_del_contenedor> # Esto funciona si ejecutaste la versión de interactiva
```

donde debes de cambiar `<nombre_del_contenedor>` por el nombre del contenedor (la última columna de `docker ps -a`).


## Es posible también...

Lanzar una terminal de `R` sin usar Rstudio

```
docker run  -it --user docker --name r-console -v path_a_carpeta:/home/docker/proyectos carpetri/base /usr/bin/R
```

**Nota** Recuerda que el comando `run` crea un contenedor nuevo, si quieres reutilizar el contenedor, debes de eliminar la bandera `--rm`  y usar `start`.

## Liga de ayuda

Pueden ver [esto](https://github.com/wsargent/docker-cheat-sheet) si tienen dudas

## Referencia:

Repositorio: [ITAM-DS/tutoriales](https://github.com/ITAM-DS/tutoriales)