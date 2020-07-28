#!/bin/sh

[ $# -lt 3 ] && exit

DEST_DIR=${MESON_INSTALL_DESTDIR_PREFIX:-/usr}/$1

ln -sf "$2" "${DEST_DIR}/$3"
