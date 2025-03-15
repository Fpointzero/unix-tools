function setproxy() {
    if [ $# -eq 0 ]; then
            echo "Usage: setproxy [proxy]"
            return 1
    fi
    local proxy=$1
    export http_proxy="http://${proxy}"
    export all_proxy="http://${proxy}"
    export https_proxy="http://${proxy}"
    export socks5_proxy="socks5://${proxy}"
}

function clearproxy() {
    unset http_proxy;
    unset all_proxy;
    unset https_proxy;
    unset socks5_proxy;
}