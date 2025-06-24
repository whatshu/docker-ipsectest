#!/bin/sh
set -e

exec > /usr/capture/entrypoint.log 2>&1

tcpdump -i any -U -s 0 -w /usr/capture/output.pcap &

# 直接调用 libexec 下的 charon
CHARON_BIN=/usr/libexec/ipsec/charon

[ -x "$CHARON_BIN" ] || { echo "ERROR: $CHARON_BIN not found"; exit 1; }

# 启动 charon 守护进程
"$CHARON_BIN" &

# 等待几秒让服务就绪
sleep 2

# 加载所有连接定义
swanctl --load-all

# 对 Initiator 端发起 CHILD_SA（Responder 会自动响应）
swanctl --initiate --child=myconn

# 输出状态，持续打印日志
swanctl --list-sas

wait
