# get windows ip address by dns proxy
# export WIN_IP=$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }')
# get windows ip address by default gateway
export WIN_IP=$(ip route | grep default | awk '{print $3}')