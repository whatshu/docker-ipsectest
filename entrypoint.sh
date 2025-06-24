#!/bin/sh
set -e

# 直接调用 libexec 下的 charon
CHARON_BIN=/usr/libexec/ipsec/charon

[ -x "$CHARON_BIN" ] || { echo "ERROR: $CHARON_BIN not found"; exit 1; }
echo "使用的 charon 路径：$CHARON_BIN"

# 启动 charon 守护进程
"$CHARON_BIN" &
CHARON_PID=$!

# 等待几秒让服务就绪
sleep 2

# 加载所有连接定义
swanctl --load-all

# 对 Initiator 端发起 CHILD_SA（Responder 会自动响应）
swanctl --initiate --child=myconn

# 输出状态，持续打印日志
swanctl --list-sas
tail --pid="$CHARON_PID" -f /var/log/syslog
