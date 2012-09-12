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
#

failIfNotOK() {
  if [ $? != 0 ]; then
    exit $?
  fi
}

usage() {
  echo "
usage: $0 <options>
  Required not-so-options:
     --extra-dir=DIR    path to Bigtop distribution files
     --build-dir=DIR    path to Bigtop distribution files
     --server-dir=DIR   path to server package root
     --client-dir=DIR   path to the client package root
     --initd-dir=DIR    path to the server init.d directory

  Optional options:
     --docs-dir=DIR     path to the documentation root
  "
  exit 1
}

OPTS=$(getopt \
  -n $0 \
  -o '' \
  -l 'extra-dir:' \
  -l 'build-dir:' \
  -l 'server-dir:' \
  -l 'client-dir:' \
  -l 'docs-dir:' \
  -l 'initd-dir:' \
  -l 'conf-dir:' \
  -- "$@")

if [ $? != 0 ] ; then
    usage
fi

eval set -- "$OPTS"
while true ; do
    case "$1" in
        --extra-dir)
        EXTRA_DIR=$2 ; shift 2
        ;;
        --build-dir)
        BUILD_DIR=$2 ; shift 2
        ;;
        --server-dir)
        SERVER_PREFIX=$2 ; shift 2
        ;;
        --client-dir)
        CLIENT_PREFIX=$2 ; shift 2
        ;;
        --docs-dir)
        DOC_DIR=$2 ; shift 2
        ;;
        --initd-dir)
        INITD_DIR=$2 ; shift 2
        ;;
        --conf-dir)
        CONF_DIR=$2 ; shift 2
        ;;
        --)
        shift; break
        ;;
        *)
        echo "Unknown option: $1"
        usage
        ;;
    esac
done

for var in BUILD_DIR SERVER_PREFIX CLIENT_PREFIX; do
  if [ -z "$(eval "echo \$$var")" ]; then
    echo Missing param: $var
    usage
  fi
done

if [ ! -d "${BUILD_DIR}" ]; then
  echo "Build directory does not exist: ${BUILD_DIR}"
  exit 1
fi

if [ -d "${SERVER_PREFIX}" ]; then
  echo "Server directory already exists, delete first: ${SERVER_PREFIX}"
  exit 1
fi

if [ -d "${CLIENT_PREFIX}" ]; then
  echo "Client directory already exists, delete first: ${CLIENT_PREFIX}"
  exit 1
fi

if [ -d "${DOC_DIR}" ]; then
  echo "Docs directory already exists, delete first: ${DOC_DIR}"
  exit 1
fi

## Install client image first
CLIENT_LIB_DIR=${CLIENT_PREFIX}/usr/lib/oozie
MAN_DIR=${CLIENT_PREFIX}/usr/share/man/man1
DOC_DIR=${DOC_DIR:-$CLIENT_PREFIX/usr/share/doc/oozie}
BIN_DIR=${CLIENT_PREFIX}/usr/bin

install -d -m 0755 ${CLIENT_LIB_DIR}
failIfNotOK
install -d -m 0755 ${CLIENT_LIB_DIR}/bin
failIfNotOK
cp -R ${BUILD_DIR}/bin/oozie ${CLIENT_LIB_DIR}/bin
failIfNotOK
cp -R ${BUILD_DIR}/lib ${CLIENT_LIB_DIR}
failIfNotOK
install -d -m 0755 ${DOC_DIR}
failIfNotOK
cp -R ${BUILD_DIR}/LICENSE.txt ${DOC_DIR}
failIfNotOK
cp -R ${BUILD_DIR}/NOTICE.txt ${DOC_DIR}
failIfNotOK
cp -R ${BUILD_DIR}/oozie-examples.tar.gz ${DOC_DIR}
failIfNotOK
cp -R ${BUILD_DIR}/README.txt ${DOC_DIR}
failIfNotOK
cp -R ${BUILD_DIR}/release-log.txt ${DOC_DIR}
failIfNotOK
[ -f ${BUILD_DIR}/PATCH.txt ] && cp ${BUILD_DIR}/PATCH.txt ${DOC_DIR}
# failIfNotOK
cp -R ${BUILD_DIR}/docs/* ${DOC_DIR}
failIfNotOK
install -d -m 0755 ${MAN_DIR}
failIfNotOK
gzip -c ${EXTRA_DIR}/oozie.1 > ${MAN_DIR}/oozie.1.gz
failIfNotOK

# Create the /usr/bin/oozie wrapper
install -d -m 0755 $BIN_DIR
failIfNotOK
cat > ${BIN_DIR}/oozie <<EOF
#!/bin/sh
#
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

# Autodetect JAVA_HOME if not defined
if [ -e /usr/libexec/bigtop-detect-javahome ]; then
  . /usr/libexec/bigtop-detect-javahome
elif [ -e /usr/lib/bigtop-utils/bigtop-detect-javahome ]; then
  . /usr/lib/bigtop-utils/bigtop-detect-javahome
fi

exec /usr/lib/oozie/bin/oozie "\$@"
EOF
failIfNotOK
chmod 755 ${BIN_DIR}/oozie
failIfNotOK


## Install server image
SERVER_LIB_DIR=${SERVER_PREFIX}/usr/lib/oozie
CONF_DIR=${CONF_DIR:-"${SERVER_PREFIX}/etc/oozie/conf.dist"}
DATA_DIR=${SERVER_PREFIX}/var/lib/oozie

install -d -m 0755 ${SERVER_LIB_DIR}
failIfNotOK
install -d -m 0755 ${SERVER_LIB_DIR}/bin
failIfNotOK
install -d -m 0755 ${DATA_DIR}
failIfNotOK
for file in ooziedb.sh oozied.sh oozie-sys.sh ; do
  cp ${BUILD_DIR}/bin/$file ${SERVER_LIB_DIR}/bin
  failIfNotOK
done
cp -R ${BUILD_DIR}/libtools ${SERVER_LIB_DIR}
failIfNotOK

install -d -m 0755 ${CONF_DIR}
failIfNotOK
cp ${BUILD_DIR}/conf/* ${CONF_DIR}
sed -i -e '/oozie.service.HadoopAccessorService.hadoop.configurations/,/<\/property>/s#<value>\*=hadoop-conf</value>#<value>*=/etc/hadoop/conf</value>#g' \
          ${CONF_DIR}/oozie-site.xml
failIfNotOK
cp ${EXTRA_DIR}/oozie-env.sh ${CONF_DIR}
failIfNotOK
install -d -m 0755 ${CONF_DIR}/action-conf
failIfNotOK
cp ${EXTRA_DIR}/hive.xml ${CONF_DIR}/action-conf
failIfNotOK
if [ "${INITD_DIR}" != "" ]; then
  install -d -m 0755 ${INITD_DIR}
  failIfNotOK
  cp -R ${EXTRA_DIR}/oozie.init ${INITD_DIR}/oozie
  failIfNotOK
  chmod 755 ${INITD_DIR}/oozie
 failIfNotOK
fi
cp -R ${BUILD_DIR}/oozie-sharelib*.tar.gz ${SERVER_LIB_DIR}/oozie-sharelib.tar.gz
failIfNotOK
cp -R ${BUILD_DIR}/oozie-server/webapps ${SERVER_LIB_DIR}/webapps
failIfNotOK
ln -s -f /etc/oozie/conf/oozie-env.sh ${SERVER_LIB_DIR}/bin
failIfNotOK

# Unpack oozie.war some place reasonable
WEBAPP_DIR=${SERVER_LIB_DIR}/webapps/oozie
mkdir ${WEBAPP_DIR}
failIfNotOK
unzip -d ${WEBAPP_DIR} ${BUILD_DIR}/oozie.war
failIfNotOK
mv -f ${WEBAPP_DIR}/WEB-INF/lib ${SERVER_LIB_DIR}/libserver
failIfNotOK
touch ${SERVER_LIB_DIR}/webapps/oozie.war
failIfNotOK

# Create an exploded-war oozie deployment in /var/lib/oozie
install -d -m 0755 ${SERVER_LIB_DIR}/oozie-server
failIfNotOK
cp -R ${BUILD_DIR}/oozie-server/conf ${SERVER_LIB_DIR}/oozie-server/conf
failIfNotOK
cp ${EXTRA_DIR}/context.xml ${SERVER_LIB_DIR}/oozie-server/conf/
failIfNotOK
cp ${EXTRA_DIR}/catalina.properties ${SERVER_LIB_DIR}/oozie-server/conf/
failIfNotOK
ln -s ../webapps ${SERVER_LIB_DIR}/oozie-server/webapps
failIfNotOK

# Provide a convenience symlink to be more consistent with tarball deployment
ln -s ${DATA_DIR#${SERVER_PREFIX}} ${SERVER_LIB_DIR}/libext
