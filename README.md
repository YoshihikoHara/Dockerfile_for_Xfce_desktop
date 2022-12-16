# Overview

A Dockerfile to create a container running "Xfce desktop environment that can be connected using a VNC client".


# Example of execution method

1. image creation.
Execute the following command in the directory where the Dockerfile exists.

```
$ docker build -t shinodas/pico-mruby:20220917 .
```

2. container creation.
After creating the image, execute the following command.

```
$ docker run -it -v `pwd`:/home/hoge/data -p 5901:5901 -u hoge --name ESP32_Xfce --privileged ub2204_vncxfce_cutecom_esp32idf:20221213
```

