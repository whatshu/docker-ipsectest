#!/bin/bash
set -e

exec > /usr/capture/entrypoint.log 2>&1

journalctl -f > /usr/capture/syslog.txt &

# 生成 Wireshark ESP 解密密钥文件
generate_wireshark_keys() {
  outfile="/usr/capture/wireshark.keys"
  : > "$outfile"
  while IFS= read -r line; do
    if echo "$line" | grep -qE '^src'; then
      src=$(echo "$line" | awk '{print $2}')
      dst=$(echo "$line" | awk '{print $4}')
    elif echo "$line" | grep -qE 'spi'; then
      spi=$(echo "$line" | grep -o '0x[a-fA-F0-9]\+')
    elif echo "$line" | grep -q 'auth-trunc'; then
      auth_key=$(echo "$line" | awk '{print $3}')
      auth_len=$(echo "$line" | awk '{print $4}')
      auth_name="HMAC-SHA-256-${auth_len} [RFC4868]"
    elif echo "$line" | grep -q 'enc cbc'; then
      enc_key=$(echo "$line" | awk '{print $3}')
      enc_name="AES-CBC [RFC3602]"
      printf '"IPv4","%s","%s","%s","%s","%s","%s","%s"\n' \
         "$src" "$dst" "$spi" "$enc_name" "$enc_key" "$auth_name" "$auth_key" >> "$outfile"
    fi
  done < <(ip xfrm state)
  echo "Wireshark ESP 解密密钥文件已生成：$outfile"
}

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

# 等待 10s
sleep 10

# 输出内核 XFRM 状态
ip xfrm state > /usr/capture/xfrm_state.txt

generate_wireshark_keys

# 触发 rekey
swanctl --rekey --child=myconn

swanctl --list-sas

sleep 30

wait
