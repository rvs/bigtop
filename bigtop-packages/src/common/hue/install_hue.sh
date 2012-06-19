#!/bin/sh

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

usage() {
  echo "
usage: $0 <options>
  Required not-so-options:
     --build-dir=DIR             path to Hue dist.dir
     --prefix=PREFIX             path to install into

  Optional options:
     --doc-dir=DIR               path to install docs into [/usr/share/doc/hue]
     --lib-dir=DIR               path to install Hue home [/usr/lib/hue]
     --installed-lib-dir=DIR     path where lib-dir will end up on target system
     --bin-dir=DIR               path to install bins [/usr/bin]
     ... [ see source for more similar options ]
  "
  exit 1
}

OPTS=$(getopt \
  -n $0 \
  -o '' \
  -l 'prefix:' \
  -l 'doc-dir:' \
  -l 'lib-dir:' \
  -l 'installed-lib-dir:' \
  -l 'bin-dir:' \
  -l 'build-dir:' -- "$@")

if [ $? != 0 ] ; then
    usage
fi

eval set -- "$OPTS"
while true ; do
    case "$1" in
        --prefix)
        PREFIX=$2 ; shift 2
        ;;
        --build-dir)
        BUILD_DIR=$2 ; shift 2
        ;;
        --doc-dir)
        DOC_DIR=$2 ; shift 2
        ;;
        --lib-dir)
        LIB_DIR=$2 ; shift 2
        ;;
        --installed-lib-dir)
        INSTALLED_LIB_DIR=$2 ; shift 2
        ;;
        --bin-dir)
        BIN_DIR=$2 ; shift 2
        ;;
        --)
        shift ; break
        ;;
        *)
        echo "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
done

for var in PREFIX BUILD_DIR ; do
  if [ -z "$(eval "echo \$$var")" ]; then
    echo Missing param: $var
    usage
  fi
done

PREFIX=`echo $PREFIX | sed -e 's#/*$##'`
BUILD_DIR=`echo $BUILD_DIR | sed -e 's#/*$##'`

CONF_DIR=${CONF_DIR:-/etc/hue}
LIB_DIR=${LIB_DIR:-/usr/lib/hue}
HADOOP_DIR=${HADOOP_DIR:-/usr/lib/hadoop/lib}

BUNDLED_BUILD_DIR=$PREFIX/$LIB_DIR/build

# Install all the files 
(cd $BUILD_DIR ; PREFIX=`dirname $PREFIX/$LIB_DIR` make install)

# Install conf files
install -d -m 0755 $PREFIX/$CONF_DIR
mv -f $PREFIX/$LIB_DIR/desktop/conf $PREFIX/${CONF_DIR}/conf.empty
ln -fs $CONF_DIR/conf $PREFIX/$LIB_DIR/desktop/conf

# Install plugins
install -d -m 0755 $PREFIX/$HADOOP_DIR
ln -fs $LIB_DIR/desktop/libs/hadoop/java-lib/*plugin*jar $PREFIX/$HADOOP_DIR

# Hue Shell specific
install -d -m 0755 $PREFIX/$LIB_DIR/apps/shell/src/shell/build/
cp -f $BUILD_DIR/apps/shell/src/shell/build/setuid $PREFIX/$LIB_DIR/apps/shell/src/shell/build

# Remove Hue database
rm -f $PREFIX/$LIB_DIR/desktop/desktop.db

# Preparing filtering command
SED_FILT="-e s|$PREFIX|| -e s|$BUILD_DIR|$LIB_DIR|"

# Fix broken symlinks
for sm in $BUNDLED_BUILD_DIR/env/lib*; do
  if [ -h ${sm} ] ; then
    SM_ORIG_DEST_FILE=`ls -l "${sm}" | sed -e 's/.*-> //' `
    SM_DEST_FILE=`echo $SM_ORIG_DEST_FILE | sed $SED_FILT`

    rm ${sm}
    ln -s ${SM_DEST_FILE} ${sm}
  fi
done

# Fix broken python scripts
HUE_BIN_SCRIPTS=$BUNDLED_BUILD_DIR/env/bin/*
HUE_EGG_SCRIPTS=$BUNDLED_BUILD_DIR/env/lib*/python*/site-packages/*/EGG-INFO/scripts/*
for file in $HUE_BIN_SCRIPTS $HUE_EGG_SCRIPTS;
do
  if [ -f ${file} ]
  then
    sed -i $SED_FILT ${file}
  fi
done

# Make binary scripts executables
chmod 755 $BUNDLED_BUILD_DIR/env/bin/*

# Remove bogus files
rm -fv `find $PREFIX -iname "build_log.txt"`

ALL_PTH_BORKED=`find $PREFIX -iname "*.pth"`
ALL_REG_BORKED=`find $PREFIX -iname "app.reg"`
ALL_PYTHON_BORKED=`find $PREFIX -iname "*.egg-link"`
for file in $ALL_PTH_BORKED $ALL_REG_BORKED $ALL_PYTHON_BORKED;
do
  sed -i $SED_FILT ${file}
done
