#!/bin/bash

# 检查并创建$HOME/.ssh目录
ssh_dir="$HOME/.ssh"
if [ ! -d "$ssh_dir" ]; then
  mkdir -p "$ssh_dir"
fi

# 检查并创建tunnel.json文件
tunnel_file="$ssh_dir/tunnel.json"
if [ ! -f "$tunnel_file" ]; then
  echo '{"tunnels":[]}' > "$tunnel_file"
fi

# 安装依赖项
install_dependencies() {
  sudo apt install -y peco fzy sshpass sshfs jq
}

# 添加隧道
add_tunnel() {
  tunnel_data=($(fzy -p "Enter tunnel data: " -q "host port user password remote_ip remote_port local_port"))

  new_tunnel=$(jq -n --argjson tunnel_data "${tunnel_data[@]}" '{
    host: $tunnel_data[0],
    port: $tunnel_data[1],
    user: $tunnel_data[2],
    password: $tunnel_data[3],
    remote_ip: $tunnel_data[4],
    remote_port: $tunnel_data[5],
    local_port: $tunnel_data[6]
  }')

  jq ".tunnels += [$new_tunnel]" "$tunnel_file" > "${tunnel_file}.tmp" && mv "${tunnel_file}.tmp" "$tunnel_file"

  echo "Tunnel added successfully."
}

# 删除隧道
delete_tunnel() {
  tunnel_to_delete=$(jq -r '.tunnels[] | "\(.host):\(.port)[\(.remote_port)]->[\(.local_port)]"' "$tunnel_file" | peco --query "Please select a tunnel to be deleted: ")

  if [ -n "$tunnel_to_delete" ]; then
    host=$(echo "$tunnel_to_delete" | cut -d: -f1)
    port=$(echo "$tunnel_to_delete" | cut -d: -f2 | cut -d[ -f1 | tr -d ' ')

    jq "del(.tunnels[] | select(.host == \"$host\" and .port == \"$port\"))" "$tunnel_file" > "${tunnel_file}.tmp" && mv "${tunnel_file}.tmp" "$tunnel_file"

    echo "Tunnel deleted successfully."
  fi
}

# 选择隧道转发
select_tunnel() {
  declare -A tunnel_map
  for tunnel in $(jq -r '.tunnels[] | @base64' $tunnel_file); do
  # 解码隧道数据
  _jq() {
    echo "${tunnel}" | base64 --decode | jq -r ${1}
  }

  # 获取隧道信息
  host=$(_jq '.host')
  port=$(_jq '.port')
  user=$(_jq '.user')
  password=$(_jq '.password')
  remote_ip=$(_jq '.remote_ip')
  remote_port=$(_jq '.remote_port')
  local_port=$(_jq '.local_port')

  tunnel_map["aaa"]="bbb"

  # 检查host和port是否满足特定条件
  if [ "$host" = "xxx" ] && [ "$port" = "1234" ]; then
  echo "特定条件满足：host=$host, port=$port"
  fi

  # 在这里处理每个隧道的信息
  echo "Host: $host"
  echo "Port: $port"
  echo "User: $user"
  echo "Password: $password"
  echo "Remote IP: $remote_ip"
  echo "Remote Port: $remote_port"
  echo "Local Port: $local_port"
  echo tunnel_map["aaa"]
  done
}

# 主菜单
while true; do
    PS3="Please select an option: "
    options=("Choose Tunnel Forwarding" "Install Dependencies" "Add Tunnel" "Delete Tunnel" "Quit")
    selected_option=$(printf '%s\n' "${options[@]}" | peco --prompt "Please select an option:")
    
    case $selected_option in
        "Choose Tunnel Forwarding")
            select_tunnel
            exit 0
            ;;
        "Install Dependencies")
            install_dependencies
            ;;
        "Add Tunnel")
            add_tunnel
            ;;
        "Delete Tunnel")
            delete_tunnel
            ;;
        "Quit")
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option $REPLY"
            ;;
    esac
done
