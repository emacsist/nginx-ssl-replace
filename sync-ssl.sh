#!/usr/bin/env bash

HOST="$1"

function log() {
    echo "`date` $1"
}

if [[ -z "${HOST}" ]]; then
  log "no host...exit"
  exit -1
fi

log "deploy ${HOST} ..."

. ./${HOST}/meta.data


function backNingx() {
    echo "ssh port ${SSH_PORT} ..."
    ssh -p${SSH_PORT} ${USER_NAME}@${HOST} "echo 'remote uname'; uname -a; uptime"
    ssh -p${SSH_PORT} ${USER_NAME}@${HOST} "cp ${SSL_DIR}/${CRT_NAME} ${SSL_DIR}/${CRT_NAME}.bak; echo 'backup crt ok...'"
    ssh -p${SSH_PORT} ${USER_NAME}@${HOST} "cp ${SSL_DIR}/${KEY_NAME} ${SSL_DIR}/${KEY_NAME}.bak; echo 'backup key ok...'"
}

function syncSSLFile() {
    key_file=`ls ${HOST}/*.key | head -n 1`
    crt_file=`find ${HOST} -iname "*.crt" -o -iname "*.pem"`
    log "key file => ${key_file}"
    log "crt/pem file => ${crt_file}"

    rsync -avzhP -e "ssh -p${SSH_PORT}" "${key_file}" ${USER_NAME}@${HOST}:${SSL_DIR}/${KEY_NAME}
    rsync -avzhP -e "ssh -p${SSH_PORT}" "${crt_file}" ${USER_NAME}@${HOST}:${SSL_DIR}/${CRT_NAME}
    result=$?
    log "rsync status ${result}"
}

function checksum() {
    log "local md5..."
    md5sum ${HOST}/* | grep "meta.data" -v
    echo ""

    log "remote md5..."
    ssh -p${SSH_PORT} ${USER_NAME}@${HOST} "cd ${SSL_DIR}; md5sum ${CRT_NAME} ${KEY_NAME}"
    echo ""
}

function restartNginx() {
    ssh -t -p${SSH_PORT} ${USER_NAME}@"${HOST}" "cd ${NGINX_DIR}; sudo sbin/nginx -t && sudo sbin/nginx -s reload; echo 'restart nginx ok...'"
}

backNingx
syncSSLFile
checksum
restartNginx

log "done..."