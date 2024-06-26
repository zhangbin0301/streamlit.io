#!/usr/bin/env bash

# Define Environment Variables
export V_PORT=${V_PORT:-'8080'}
export CFPORT=${CFPORT:-'443'} # 2053 2083 2087 2096 8443
export UUID=${UUID:-'7160b696-dd5e-42e3-a024-145e92cec916'}
export VMESS_WSPATH=${VMESS_WSPATH:-'startvm'}
export VLESS_WSPATH=${VLESS_WSPATH:-'startvl'}
export CF_IP=${CF_IP:-'icook.tw'}
export SUB_NAME=${SUB_NAME:-'streamlit'}
export FILE_PATH=${FILE_PATH:-'./.npm'}

# 当值大于1时用argo,当值为其他值时不用argo，,默认为1
export openserver=${openserver:-'1'}

export SUB_URL=${SUB_URL:-'https://myjyup.shiguangda.nom.za/upload-a4aa34be-4373-4fdb-bff7-0a9c23405dac'}

NEZHA_SERVER=${NEZHA_SERVER:-'nezha.tcguangda.eu.org'}
NEZHA_KEY=${NEZHA_KEY:-'rZYB3POw666WxuEcDG'}
NEZHA_PORT=${NEZHA_PORT:-'443'}
tlsPorts=("443" "8443" "2096" "2087" "2083" "2053")
if [[ " ${tlsPorts[@]} " =~ " ${NEZHA_PORT} " ]]; then
  NEZHA_TLS="--tls"
else
  NEZHA_TLS=""
fi

# export ARGO_DOMAIN=${ARGO_DOMAIN:-'cs.drst.cloudns.org'}
# export ARGO_AUTH=${ARGO_AUTH:-'eyJhIjoiY2Y4OWNmMDcwOGEzZjRlMjY0ZmJmNDFhNDdkMTdjYTMiLCJ0IjoiMmIyZjE3ZDQtMjc1MS00YzZmLWJlODQtY2VlOTZjNDkzNWRiIiwicyI6Ik5USTJNbVU1TnpndE5HVTFNaTAwTWpaaUxXRTJOMk10WVRkaVl6SXhNell6TlRGbSJ9'}

if [ ! -d "$FILE_PATH" ]; then
  mkdir -p "$FILE_PATH"
fi

cleanup_files() {
  rm -rf ${FILE_PATH}/boot.log ${FILE_PATH}/out.json ${FILE_PATH}/*.sh
}
cleanup_files

# Download Dependency Files
set_download_url() {
  local program_name="$1"
  local default_url="$2"
  local x64_url="$3"

  if [ "$(uname -m)" = "x86_64" ] || [ "$(uname -m)" = "amd64" ] || [ "$(uname -m)" = "x64" ]; then
    download_url="$x64_url"
  else
    download_url="$default_url"
  fi
}

download_program() {
  local program_name="$1"
  local default_url="$2"
  local x64_url="$3"

  set_download_url "$program_name" "$default_url" "$x64_url"

  if [ ! -f "$program_name" ]; then
    if [ -n "$download_url" ]; then
      echo "Downloading $program_name..." > /dev/null
      # wget -qO "$program_name" "$download_url"
      curl -sSL "$download_url" -o "$program_name"
      echo "Downloaded $program_name" > /dev/null
    else
      echo "Skipping download for $program_name" > /dev/null
    fi
  else
    echo "$program_name already exists, skipping download" > /dev/null
  fi
}

if [ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_KEY}" ]; then
  download_program "${FILE_PATH}/agent" "https://raw.githubusercontent.com/kahunama/myfile/main/nezha/nezha-agent(arm)" "https://raw.githubusercontent.com/kahunama/myfile/main/nezha/nezha-agent"
  chmod +x ${FILE_PATH}/agent
  sleep 3
fi

download_program "${FILE_PATH}/web" "https://raw.githubusercontent.com/kahunama/myfile/main/my/web.js(arm)" "https://raw.githubusercontent.com/kahunama/myfile/main/my/web.js"
chmod +x ${FILE_PATH}/web
sleep 3

if [ ${openserver} -eq 1 ]; then
  download_program "${FILE_PATH}/server" "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64" "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64"
  chmod +x ${FILE_PATH}/server
  sleep 3
fi

if [ -n "${SUB_URL}" ]; then
  download_program "${FILE_PATH}/up.sh" "https://raw.githubusercontent.com/mytcgd/myfiles/main/my/x/up_s.sh" "https://raw.githubusercontent.com/mytcgd/myfiles/main/my/x/up_s.sh"
  chmod +x ${FILE_PATH}/up.sh
  sleep 3
fi

# Generate configuration
generate_config() {
  cat > ${FILE_PATH}/out.json << EOF
{
    "log":{
        "access":"/dev/null",
        "error":"/dev/null",
        "loglevel":"none"
    },
    "inbounds":[
        {
            "port":$V_PORT,
            "protocol":"vless",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "flow":"xtls-rprx-vision"
                    }
                ],
                "decryption":"none",
                "fallbacks":[
                    {
                        "dest":3001
                    },
                    {
                        "path":"/${VLESS_WSPATH}",
                        "dest":3002
                    },
                    {
                        "path":"/${VMESS_WSPATH}",
                        "dest":3003
                    }
                ]
            },
            "streamSettings":{
                "network":"tcp"
            }
        },
        {
            "port":3001,
            "listen":"127.0.0.1",
            "protocol":"vless",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}"
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "security":"none"
            }
        },
        {
            "port":3002,
            "listen":"127.0.0.1",
            "protocol":"vless",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "level":0
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "security":"none",
                "wsSettings":{
                    "path":"/${VLESS_WSPATH}"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3003,
            "listen":"127.0.0.1",
            "protocol":"vmess",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "alterId":0
                    }
                ]
            },
            "streamSettings":{
                "network":"ws",
                "wsSettings":{
                    "path":"/${VMESS_WSPATH}"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        }
    ],
    "dns":{
        "servers":[
            "https+local://8.8.8.8/dns-query"
        ]
    },
    "outbounds":[
        {
            "protocol":"freedom"
        },
        {
            "tag":"WARP",
            "protocol":"wireguard",
            "settings":{
                "secretKey":"YFYOAdbw1bKTHlNNi+aEjBM3BO7unuFC5rOkMRAz9XY=",
                "address":[
                    "172.16.0.2/32",
                    "2606:4700:110:8a36:df92:102a:9602:fa18/128"
                ],
                "peers":[
                    {
                        "publicKey":"bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=",
                        "allowedIPs":[
                            "0.0.0.0/0",
                            "::/0"
                        ],
                        "endpoint":"162.159.193.10:2408"
                    }
                ],
                "reserved":[78, 135, 76],
                "mtu":1280
            }
        }
    ],
    "routing":{
        "domainStrategy":"AsIs",
        "rules":[
            {
                "type":"field",
                "domain":[
                    "domain:openai.com",
                    "domain:ai.com"
                ],
                "outboundTag":"WARP"
            }
        ]
    }
}
EOF
}

argo_type() {
  if [ -z "$ARGO_AUTH" ] && [ -z "$ARGO_DOMAIN" ]; then
    echo "ARGO_AUTH or ARGO_DOMAIN is empty, use Quick Tunnels" > /dev/null
    return
  fi

  if [ -n "$(echo "$ARGO_AUTH" | grep TunnelSecret)" ]; then
    echo $ARGO_AUTH > tunnel.json
    cat > tunnel.yml << EOF
tunnel=$(echo "$ARGO_AUTH" | cut -d\" -f12)
credentials-file: ./tunnel.json
protocol: http2

ingress:
  - hostname: $ARGO_DOMAIN
    service: http://localhost: $V_PORT
    originRequest:
      noTLSVerify: true
  - service: http_status:404
EOF
  else
    echo "ARGO_AUTH Mismatch TunnelSecret" > /dev/null
  fi
}

args() {
if [ -e ${FILE_PATH}/server ] && [ ${openserver} -eq 1 ]; then
  if [ -n "$(echo "$ARGO_AUTH" | grep '^[A-Z0-9a-z=]\{120,250\}$')" ]; then
    args="tunnel --edge-ip-version auto --protocol http2 --logfile ${FILE_PATH}/boot.log run --url http://localhost:$V_PORT --token ${ARGO_AUTH}"
  elif [ -n "$(echo "$ARGO_AUTH" | grep TunnelSecret)" ]; then
    args="tunnel --edge-ip-version auto --config tunnel.yml run"
  else
    args="tunnel --edge-ip-version auto --protocol http2 --no-autoupdate --logfile ${FILE_PATH}/boot.log --url http://localhost:$V_PORT"
  fi
fi
}

generate_config
argo_type
args

generate_server() {
  cat > ${FILE_PATH}/server.sh << EOF
#!/usr/bin/env bash

check_run() {
  [[ \$(pidof server) ]] && echo "server is runing!" && exit
}

${FILE_PATH}/server $args >/dev/null

check_run
wait
EOF
}

generate_web() {
  cat > ${FILE_PATH}/web.sh << EOF
#!/usr/bin/env bash

check_run() {
  [[ \$(pidof web) ]] && echo "web is runing!" && exit
}

${FILE_PATH}/web run -c ${FILE_PATH}/out.json

check_run
wait
EOF
}

generate_nezha() {
  cat > ${FILE_PATH}/nezha.sh << EOF
#!/usr/bin/env bash

check_run() {
  [[ \$(pidof agent) ]] && echo "nez is runing" && exit
}

${FILE_PATH}/agent -s ${NEZHA_SERVER}:${NEZHA_PORT} -p ${NEZHA_KEY} ${NEZHA_TLS}

check_run
wait
EOF
}

# run
run() {
  # openserver等于1
  if [ -e ${FILE_PATH}/server ] && [ ${openserver} -eq 1 ]; then
    generate_server
    [[ $(pidof server.sh) ]] && exit
    [ -e ${FILE_PATH}/server.sh ] && bash ${FILE_PATH}/server.sh >/dev/null
  fi

  if [ -e ${FILE_PATH}/web ]; then
    generate_web
    [[ $(pidof web.sh) ]] && exit
    [ -e ${FILE_PATH}/web.sh ] && bash ${FILE_PATH}/web.sh
  fi

  if [ -n "${NEZHA_SERVER}" ] && [ -n "${NEZHA_KEY}" ] && [ -e ${FILE_PATH}/agent ]; then
    generate_nezha
    [[ $(pidof nezha.sh) ]] && exit
    [ -e ${FILE_PATH}/nezha.sh ] && bash ${FILE_PATH}/nezha.sh
  fi
}

run

sleep 30

# get IP and country
export server_ip=$(curl -s https://speed.cloudflare.com/meta | tr ',' '\n' | grep -E '"clientIp"\s*:\s*"' | sed 's/.*"clientIp"\s*:\s*"\([^"]*\)".*/\1/')
# export server_ip=$(curl -s https://ipv4.icanhazip.com)
export country_abbreviation=$(curl -s https://speed.cloudflare.com/meta | tr ',' '\n' | grep -E '"country"\s*:\s*"' | sed 's/.*"country"\s*:\s*"\([^"]*\)".*/\1/')

# list
list() {
  if [ -z "$ARGO_AUTH" ] && [ -z "$ARGO_DOMAIN" ]; then
    [ -s ${FILE_PATH}/boot.log ] && export ARGO_DOMAIN=$(cat ${FILE_PATH}/boot.log | grep -o "info.*https://.*trycloudflare.com" | sed "s@.*https://@@g" | tail -n 1)
  fi

  # openserver不等于1
  if [ ${openserver} -ne 1 ]; then
    export ARGO_DOMAIN="${server_ip}"
  fi

VMESS="{ \"v\": \"2\", \"ps\": \"vmess-${country_abbreviation}-${SUB_NAME}\", \"add\": \"${CF_IP}\", \"port\": \"${CFPORT}\", \"id\": \"${UUID}\", \"aid\": \"0\", \"scy\": \"none\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"${ARGO_DOMAIN}\", \"path\": \"/${VMESS_WSPATH}?ed=2048\", \"tls\": \"tls\", \"sni\": \"${ARGO_DOMAIN}\", \"alpn\": \"\" }"

  cat > ${FILE_PATH}/list.txt <<ABC
***************************************************

      IP : ${server_ip}     Country： ${country_abbreviation}

***************************************************

vmess://$(echo "$VMESS" | base64 | tr -d '\n')

vless://${UUID}@${CF_IP}:${CFPORT}?host=${ARGO_DOMAIN}&path=%2F${VLESS_WSPATH}%3Fed%3D2048&type=ws&encryption=none&security=tls&sni=${ARGO_DOMAIN}#vless-${country_abbreviation}-${SUB_NAME}

***************************************************
ABC

  cat > ${FILE_PATH}/encode.txt <<EOF
vmess://$(echo "$VMESS" | base64 | tr -d '\n')
vless://${UUID}@${CF_IP}:${CFPORT}?host=${ARGO_DOMAIN}&path=%2F${VLESS_WSPATH}%3Fed%3D2048&type=ws&encryption=none&security=tls&sni=${ARGO_DOMAIN}#vless-${country_abbreviation}-${SUB_NAME}
EOF

  base64 ${FILE_PATH}/encode.txt | tr -d '\n' > ${FILE_PATH}/sub.txt
  rm ${FILE_PATH}/encode.txt
}

# up
if [ -z "$SUB_URL" ]; then
  list
else
  list
  [[ $(pidof ${FILE_PATH}/up.sh) ]] && exit
  bash ${FILE_PATH}/up.sh >/dev/null
fi
