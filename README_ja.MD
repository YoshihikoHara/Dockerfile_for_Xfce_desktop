# 概要

「VNCクライアントで接続できるXfceデスクトップ環境」を実行するコンテナを作成するためのDockerfileです。

# 実行方法例

1. イメージ作成
Dockerfileが存在するディレクトリで、以下のコマンドを実行します。

```
$ docker build --no-cache -t ub2204_vncxfce_cutecom_esp32idf:20221213 .
```

2. コンテナ作成
イメージ作成後以下のコマンドを実行します。

```
$ docker run -it -v `pwd`:/home/hoge/data -p 5901:5901 -u hoge --name ESP32_Xfce --privileged ub2204_vncxfce_cutecom_esp32idf:20221213
```

