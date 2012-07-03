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
     --build-dir=DIR             path to pig dist.dir
     --prefix=PREFIX             path to install into

  Optional options:
     --doc-dir=DIR               path to install docs into [/usr/share/doc/pig]
     --lib-dir=DIR               path to install pig home [/usr/lib/pig]
     --installed-lib-dir=DIR     path where lib-dir will end up on target system
     --bin-dir=DIR               path to install bins [/usr/bin]
     --examples-dir=DIR          path to install examples [doc-dir/examples]
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
  -l 'examples-dir:' \
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
        --examples-dir)
        EXAMPLES_DIR=$2 ; shift 2
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

MAN_DIR=$PREFIX/usr/share/man/man1
DOC_DIR=${DOC_DIR:-$PREFIX/usr/share/doc/pig}
LIB_DIR=${LIB_DIR:-$PREFIX/usr/lib/pig}
INSTALLED_LIB_DIR=${INSTALLED_LIB_DIR:-/usr/lib/pig}
EXAMPLES_DIR=${EXAMPLES_DIR:-$DOC_DIR/examples}
BIN_DIR=${BIN_DIR:-$PREFIX/usr/bin}
CONF_DIR=/etc/pig
CONF_DIST_DIR=/etc/pig/conf.dist

# First we'll move everything into lib
install -d -m 0755 $LIB_DIR
(cd $BUILD_DIR/tar/pig* && tar -cf - .) | (cd $LIB_DIR && tar -xf -)

# Salavage a few files from the contrib &co
find $LIB_DIR/contrib -name \*.jar -exec cp {} $LIB_DIR \;
cp $BUILD_DIR/pig-*-smoketests.jar $LIB_DIR/

# Remove directories that are going elsewhere
for dir in shims conf src lib-src docs tutorial test build.xml contrib ivy pig-*.stage.jar ivy.xml build.properties
do
   rm -rf $LIB_DIR/$dir
done

# Remove a fat JAR that contains system Hadoop dependencies
for jar in $LIB_DIR/pig*.jar ; do
  if jar tvf $jar | fgrep -q ' org/apache/hadoop/hdfs' ; then
    rm -f $jar
  fi
done

# Copy in the configuration files
install -d -m 0755 $PREFIX/$CONF_DIST_DIR
cp *.properties $PREFIX/$CONF_DIST_DIR
ln -s /etc/pig/conf $LIB_DIR/conf

# Copy in the /usr/bin/pig wrapper
install -d -m 0755 $BIN_DIR
cat > $BIN_DIR/pig <<EOF
#!/bin/sh

# Autodetect JAVA_HOME if not defined
if [ -e /usr/libexec/bigtop-detect-javahome ]; then
  . /usr/libexec/bigtop-detect-javahome
elif [ -e /usr/lib/bigtop-utils/bigtop-detect-javahome ]; then
  . /usr/lib/bigtop-utils/bigtop-detect-javahome
fi

# FIXME: a workaround for PIG-2786
# HBase integration support
HBASE_BINARY=\`PATH=\${HBASE_HOME}:\$PATH which hbase\`
if [ -n "\$HBASE_BINARY" ] ; then
  export PIG_CLASSPATH=\$PIG_CLASSPATH:\`\$HBASE_BINARY classpath\`
fi

exec $INSTALLED_LIB_DIR/bin/pig "\$@"
EOF
chmod 755 $BIN_DIR/pig

install -d -m 0755 $MAN_DIR
gzip -c pig.1 > $MAN_DIR/pig.1.gz

# Copy in the docs
install -d -m 0755 $DOC_DIR
(cd $BUILD_DIR/tar/pig*/docs && tar -cf - .)|(cd $DOC_DIR && tar -xf -)
mv $LIB_DIR/license $DOC_DIR

install -d -m 0755 $EXAMPLES_DIR
(cd $LIB_DIR ; ln -s pig*withouthadoop.jar pig.jar)
(cd $BUILD_DIR/tar/pig*/tutorial && tar -cf - .)|(cd $EXAMPLES_DIR && tar -xf -)
sed -i -e "s|../pig.jar|/usr/lib/pig/pig.jar|" $EXAMPLES_DIR/build.xml

# It's somewhat silly that the hadoop jars are included in the pig lib
# dir, since we depend on hadoop in our packages. We can rm them
rm -f $LIB_DIR/lib/hadoop*jar

# Pig log directory
install -d -m 1777 $PREFIX/var/log/pig
