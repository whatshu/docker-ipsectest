# 使用 docker 搭建 ike 测试环境

使用 docker compose 自动化搭建 ipsec 测试环境, 并抓包.

输出的日志/pcap 文件都被保存在 ./[initiator, responder]/capture 下.

## 开始测试

开始测试需要执行下面的几个步骤, 在没有特殊说明的情况下, 下面的指令均在 *.* 目录下执行.

1. 构建测试用 docker, 包含 strongswan 和 tcpdump;
   1. `docker compose build`
2. 启动 docker compose;
   1. `docker compose up -d`
3. 抓包.
   1. 抓包将自动开始

使用下面的指令停止, 构建, 重新开始测试.

`docker compose down && docker compose build && docker compose up -d`

如果在 build 的过程中出现了许多名为 `<none>` 的镜像, 可以使用下面的指令一并删除.

`docker image rm $(docker images -f "dangling=true" -q)`

为镜像启动交互式终端可以使用下面的指令,

`docker run -it --rm --entrypoint /bin/bash ikev2-test-initiator`

停止测试可以执行下面的指令,

1. 停止 docker compose.
   1. `docker compose down`.

重新开始测试可以执行下面的指令,

1. 重新启动 initiator 和 responder.
   1. `docker compose restart initiator responder`.

查看 ipsec 状态可以使用下面的指令,

1. 查看日志;
   1. `docker logs -f [ike_initiator, ike_responder]`.
2. 查看 ispec status.
   1. `docker exec -it [ike_initiator, ike_responder] swanctl --list-sas`.

## 查看抓包

在 wireshark 中导入密钥文件,

1. 将 *capture/keys/esp_sa* 复制到 *C:\Users\{username}\AppData\Roaming\Wireshark\esp_sa* (windows), 以解密 ESP payload;
2. 将 *capture/keys/ikev2_decryption_table* 复制到 *C:\Users\{username}\AppData\Roaming\Wireshark\ikev2_decryption_table* (windows), 以解密 ike 数据包.

打开对应的 pcap 文件即可自动解密.
