#!/bin/bash
set -e

DORIS_VERSION="2.0.3"

if [[ $# -gt 1 || ($# -eq 1 && "$1" != "--skip-download") ]]; then
    echo "Usage: ./build_images.sh [--skip-download]"
    exit 1
fi

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
SKIP_DOWNLOAD=false
if [ $# -eq 1 ]; then
    SKIP_DOWNLOAD=true
fi

log() {
    echo "[BUILD_IMAGES] $1"
}

dowdload_doris_binary() {
    if [ ! -f "$1" ]; then
        log "Download doris binary package..."
        wget https://apache-doris-releases.oss-accelerate.aliyuncs.com/$1
    else
        log "Doris binary package already exists, skip download."
    fi
    if [ ! -f "$2" ]; then
        log "Download doris sha512..."
        wget https://apache-doris-releases.oss-accelerate.aliyuncs.com/$2
    else
        log "Doris sha512 already exists, skip download."
    fi
}

check_sha512() {
    log "Check sha512..."
    sha512=$(sha512sum $1)
    if [ "$sha512" != "$(cat $2)" ]; then
        log "sha512 check failed. File sha512: $sha512, expected: $(cat $2)"
        exit 1
    fi
}

unpack() {
    log "Remove old doris binary..."
    rm -rf $1
    log "Unpack $2..."
    tar -xzf $2
}

build_docker_image() {
    log "Build images: $2..."
    docker build --build-arg http_proxy --build-arg https_proxy -f $1/Dockerfile -t $2 .
}

main() {
    log "Doris version: $DORIS_VERSION"
    doris_dir="apache-doris-$DORIS_VERSION-bin-x64"
    if [ "$SKIP_DOWNLOAD" = true ]; then
        log "Skip downloading doris binary package."
    elif [ -d "$doris_dir/fe" ] && [ -d "$doris_dir/be" ]; then
        log "Doris binary directory already exists."
    else
        binary_file="apache-doris-$DORIS_VERSION-bin-x64.tar.gz"
        sha512_file="apache-doris-$DORIS_VERSION-bin-x64.tar.gz.sha512"
        dowdload_doris_binary $binary_file $sha512_file
        check_sha512 $binary_file $sha512_file
        unpack $doris_dir $binary_file
    fi
    log "Create symbolic link 'apache-doris-bin-x64'..."
    rm -rf "apache-doris-bin-x64"
    ln -s $doris_dir "apache-doris-bin-x64"

    fe_image="apache/doris:$DORIS_VERSION-fe-x64"
    be_image="apache/doris:$DORIS_VERSION-be-x64"
    build_docker_image "fe" $fe_image
    build_docker_image "be" $be_image
}

cd ${SCRIPTPATH}
main
