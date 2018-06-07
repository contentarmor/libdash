#!/bin/bash

ROOT_DIR="$(dirname $(readlink -f ${0}))"
DEBFULLNAME="ContentArmor SAS"
DEBEMAIL="support@contentarmor.net"
DEBURL="http://www.contentarmor.net"
PKG_NAME="libdash3.0-ca"
PKG_VERS="1.0.2"
CONTENT_ARMOR_HOME="/usr"
LIBDASH_BUILD_LIB="."
OUT_DEBS_DIR="./debs"

function LOG
{
    echo "$1"
}

function ERROR
{
    echo $1
    return -1
}

function ASSERT_OK
{
    if [ ${?} -ne 0 ]; then
        echo "${1} aborted$"
        exit -1
    fi
}


function clean
{
    if [ -e ${1} ]; then
        LOG "${FUNCNAME} ${1}"
        rm -rf ${1}
    fi
}

function clean_all
{
    LOG "#### ${FUNCNAME} ###"
    clean "./debian"
    clean "./debs"
}

export DEBEMAIL DEBFULLNAME
JOBS=$(grep "^processor" /proc/cpuinfo | wc -l)

# Get the list of variable to substitute
VARS=$(cd debian.in; ( grep -Roh '\#<[^>]\+>\#'; \ls -1 ) | sort -u | \sed 's/\#<\([^>]\+\)>\#.*/\1/')
# Create the list of substitution
VAR_SUBS="$(for var in ${VARS}; do eval "val=\$${var}"; echo -n "s%\#<${var}>\#%${val}%g;"; done)"

which dh_make > /dev/null
if [ ${?} != 0 ]; then
    ERROR "dh_make is not installed;"
    ERROR "Do: 'sudo apt-get install dh-make'"
    ASSERT_OK ${LINENO}
fi

clean_all

dh_make --native --library -y -p ${PKG_NAME}_${PKG_VERS} --copyright=blank
ASSERT_OK ${LINENO}

cd debian
rm -f copyright README* ${PKG_NAME}.cron.d.ex ${PKG_NAME}.default.ex ${PKG_NAME}.doc-base.EX
rm -f init.d.ex manpage* menu.ex watch.ex *.dirs
rm docs
rm -f ${PKG_NAME}*-dev*
rm -f ${PKG_NAME}*.install
cd ${ROOT_DIR}

LOG "Customize the package template"
# Customize the package template a little bit...
# - copy other files from debian.in/ to debian/
#   applying variable subtitution to file name.
#   The copies of files starting with a shebang are made executable.
# - Subtitute variables in all files
for file in debian.in/*; do
    target_file=$(basename "${file}" | \sed "${VAR_SUBS}")
    cp -p ${file} debian/${target_file}
    head -1 debian/${target_file} | \grep -q "^#!" && chmod +x debian/${target_file}
done

#Finaly substite a few variables (in the form of #<varname>#)
for file in debian/*; do
    [ -f ${file} ] && sed -i "${VAR_SUBS}" ${file}
done

LOG "Build Debian package"
dpkg-buildpackage -rfakeroot -b -us -uc ${DEBBUILDOPTS} -j${JOBS};
ASSERT_OK ${LINENO}

LOG "Move packages in ${OUT_DEBS_DIR}"
mkdir -p ${OUT_DEBS_DIR}
ASSERT_OK ${LINENO}
find ../ -maxdepth 1 -regextype posix-extended -regex ".*${PKG_NAME}.*\.(changes|deb|dsc|tar\.gz)" -exec mv {} ${OUT_DEBS_DIR} \;
ASSERT_OK ${LINENO}

exit 0
