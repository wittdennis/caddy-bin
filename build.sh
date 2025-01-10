#!/bin/bash

CADDY_VERSION=$1
XCADDY_VERSION=$2

ensure_clean_path() {
    if [ -d "$@" ]; then
        rm -rf "$@"
    fi

    mkdir -p "$@"
}

xcaddy() {
    export GOOS=$1
    export GOARCH=$2

    EXT=""
    if [ $GOOS = "windows" ]; then
        EXT=".exe"
    fi

    DIRNAME=caddy_${CADDY_VERSION:1}_${GOOS}_${GOARCH}
    FILENAME=caddy${EXT}

    $PWD/tools/xcaddy build $CADDY_VERSION \
        --with github.com/caddy-dns/cloudflare \
        --output dist/$DIRNAME/$FILENAME

    if [ -f "dist/$DIRNAME/$FILENAME" ]; then
        pushd dist
        tar czf caddy_${CADDY_VERSION:1}_${GOOS}_${GOARCH}.tar.gz $DIRNAME
        sha512sum caddy_${CADDY_VERSION:1}_${GOOS}_${GOARCH}.tar.gz >>caddy_${CADDY_VERSION:1}_checksums.txt
        popd
    else
        exit 1
    fi
}

ensure_clean_path tools
ensure_clean_path dist

GOBIN=$PWD/tools go install github.com/caddyserver/xcaddy/cmd/xcaddy@$XCADDY_VERSION

xcaddy darwin amd64
xcaddy darwin arm64
xcaddy linux 386
xcaddy linux amd64
xcaddy linux arm64
xcaddy windows 386
xcaddy windows amd64
xcaddy windows arm64
