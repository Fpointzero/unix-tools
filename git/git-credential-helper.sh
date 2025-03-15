#!/bin/bash
# 默认凭据存储路径
DEFAULT_CREDENTIAL_FILE="$HOME/.custom-git-credentials"

# 默认加密密钥（请确保密钥安全，不要硬编码在生产环境中）
DEFAULT_SECRET_KEY="your-secret-key"

# 解析命令行参数
CREDENTIAL_FILE="$DEFAULT_CREDENTIAL_FILE"
SECRET_KEY="$DEFAULT_SECRET_KEY"
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --file)
            CREDENTIAL_FILE="$2"
            shift 2
            ;;
        --secret-key)
            SECRET_KEY="$2"
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

# 加密函数
encrypt() {
    echo "$1" | openssl enc -aes-256-cbc -pbkdf2 -salt -pass pass:"$SECRET_KEY" | base64
}

# 解密函数
decrypt() {
    echo "$1" | base64 --decode | openssl enc -d -aes-256-cbc -pbkdf2 -pass pass:"$SECRET_KEY"
}

# 读取 Git 发送的输入
while read -r line; do
    case "$line" in
        protocol=*) protocol="${line#*=}" ;;
        host=*) host="${line#*=}" ;;
        username=*) username="${line#*=}" ;;
        password=*) password="${line#*=}" ;;
        *) ;;
    esac
done

case "$1" in
    get)
        # 获取凭据
        if [[ -f "$CREDENTIAL_FILE" ]]; then
            while IFS=: read -r proto hst usr enc_pwd; do
                if [[ "$proto" == "$protocol" && "$hst" == "$host" ]]; then
                    decrypted_password=$(decrypt "$enc_pwd")
                    echo "username=$usr"
                    echo "password=$decrypted_password"
                    exit 0
                fi
            done < "$CREDENTIAL_FILE"
        fi
        ;;
    store)
        # 存储凭据
        encrypted_password=$(encrypt "$password")
        # 检查是否已存在相同的凭据
        if [[ -f "$CREDENTIAL_FILE" ]]; then
            sed -i "/^$protocol:$host:/d" "$CREDENTIAL_FILE"
        fi
        echo "$protocol:$host:$username:$encrypted_password" >> "$CREDENTIAL_FILE"
        chmod 600 "$CREDENTIAL_FILE"
        ;;
    erase)
        # 删除凭据
        if [[ -f "$CREDENTIAL_FILE" ]]; then
            sed -i "/^$protocol:$host:/d" "$CREDENTIAL_FILE"
        fi
        ;;
esac
exit 0