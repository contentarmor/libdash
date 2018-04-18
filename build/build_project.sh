#! /bin/sh
# -*- coding: utf-8 -*-

set -e

cmake .

if cat /etc/os-release | grep -qi ubuntu ; then
    make build_deb
else
    make package
fi
