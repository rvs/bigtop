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

BIGTOP_VERSION=0.4.0-incubating

# Hadoop 0.20.0-based hadoop package
HADOOP_NAME=hadoop
HADOOP_RELNOTES_NAME=Apache Hadoop
HADOOP_BASE_VERSION=2.0.0-alpha
HADOOP_PKG_VERSION=2.0.0
HADOOP_RELEASE_VERSION=1
HADOOP_TARBALL_DST=$(HADOOP_NAME)-$(HADOOP_BASE_VERSION).tar.gz
#HADOOP_DOWNLOAD_PATH=/hadoop/common/$(HADOOP_NAME)-$(HADOOP_BASE_VERSION)
#HADOOP_SITE=$(APACHE_MIRROR)$(HADOOP_DOWNLOAD_PATH)
#HADOOP_ARCHIVE=$(APACHE_ARCHIVE)$(HADOOP_DOWNLOAD_PATH)
HADOOP_TARBALL_SRC=hadoop-2.0.0-alpha-src.tar.gz 
HADOOP_SITE=http://people.apache.org/~acmurthy/hadoop-2.0.0-alpha-rc1/
HADOOP_ARCHIVE=$(HADOOP_SITE)
$(eval $(call PACKAGE,hadoop,HADOOP))

# ZooKeeper
ZOOKEEPER_NAME=zookeeper
ZOOKEEPER_RELNOTES_NAME=Apache Zookeeper
ZOOKEEPER_PKG_NAME=zookeeper
ZOOKEEPER_BASE_VERSION=3.4.3
ZOOKEEPER_PKG_VERSION=3.4.3
ZOOKEEPER_RELEASE_VERSION=1
ZOOKEEPER_TARBALL_DST=zookeeper-$(ZOOKEEPER_BASE_VERSION).tar.gz
ZOOKEEPER_TARBALL_SRC=$(ZOOKEEPER_TARBALL_DST)
ZOOKEEPER_DOWNLOAD_PATH=/zookeeper/zookeeper-$(ZOOKEEPER_BASE_VERSION)
ZOOKEEPER_SITE=$(APACHE_MIRROR)$(ZOOKEEPER_DOWNLOAD_PATH)
ZOOKEEPER_ARCHIVE=$(APACHE_ARCHIVE)$(ZOOKEEPER_DOWNLOAD_PATH)
$(eval $(call PACKAGE,zookeeper,ZOOKEEPER))

# HBase
HBASE_NAME=hbase
HBASE_RELNOTES_NAME=Apache HBase
HBASE_PKG_NAME=hbase
HBASE_BASE_VERSION=0.94.0
HBASE_PKG_VERSION=$(HBASE_BASE_VERSION)
HBASE_RELEASE_VERSION=1
HBASE_TARBALL_DST=hbase-$(HBASE_BASE_VERSION).tar.gz
HBASE_TARBALL_SRC=$(HBASE_TARBALL_DST)
HBASE_DOWNLOAD_PATH=/hbase/hbase-$(HBASE_BASE_VERSION)
HBASE_SITE=$(APACHE_MIRROR)$(HBASE_DOWNLOAD_PATH)
HBASE_ARCHIVE=$(APACHE_ARCHIVE)$(HBASE_DOWNLOAD_PATH)
$(eval $(call PACKAGE,hbase,HBASE))

# Pig
PIG_BASE_VERSION=0.10.0
PIG_PKG_VERSION=$(PIG_BASE_VERSION)
PIG_RELEASE_VERSION=1
PIG_NAME=pig
PIG_RELNOTES_NAME=Apache Pig
PIG_PKG_NAME=pig
PIG_TARBALL_DST=pig-$(PIG_BASE_VERSION).tar.gz
PIG_TARBALL_SRC=$(PIG_TARBALL_DST)
PIG_DOWNLOAD_PATH=/pig/pig-$(PIG_BASE_VERSION)
PIG_SITE=$(APACHE_MIRROR)$(PIG_DOWNLOAD_PATH)
PIG_ARCHIVE=$(APACHE_ARCHIVE)$(PIG_DOWNLOAD_PATH)
$(eval $(call PACKAGE,pig,PIG))

# Hive
HIVE_NAME=hive
HIVE_RELNOTES_NAME=Apache Hive
HIVE_PKG_NAME=hive
HIVE_BASE_VERSION=0.9.0
HIVE_PKG_VERSION=$(HIVE_BASE_VERSION)
HIVE_RELEASE_VERSION=1
HIVE_TARBALL_DST=hive-$(HIVE_BASE_VERSION).tar.gz
HIVE_TARBALL_SRC=$(HIVE_TARBALL_DST)
HIVE_DOWNLOAD_PATH=/hive/hive-$(HIVE_BASE_VERSION)
HIVE_SITE=$(APACHE_MIRROR)$(HIVE_DOWNLOAD_PATH)
HIVE_ARCHIVE=$(APACHE_ARCHIVE)$(HIVE_DOWNLOAD_PATH)
$(eval $(call PACKAGE,hive,HIVE))

# Sqoop
SQOOP_NAME=sqoop
SQOOP_RELNOTES_NAME=Sqoop
SQOOP_PKG_NAME=sqoop
SQOOP_BASE_VERSION=1.4.1-incubating
SQOOP_PKG_VERSION=1.4.1
SQOOP_RELEASE_VERSION=1
SQOOP_TARBALL_DST=$(SQOOP_NAME)-$(SQOOP_BASE_VERSION).tar.gz
SQOOP_TARBALL_SRC=$(SQOOP_NAME)-$(SQOOP_BASE_VERSION)-src.tar.gz
SQOOP_DOWNLOAD_PATH=/sqoop/$(SQOOP_BASE_VERSION)
SQOOP_SITE=$(APACHE_MIRROR)$(SQOOP_DOWNLOAD_PATH)
SQOOP_ARCHIVE=$(APACHE_ARCHIVE)$(SQOOP_DOWNLOAD_PATH)
$(eval $(call PACKAGE,sqoop,SQOOP))

# Oozie
OOZIE_NAME=oozie
OOZIE_RELNOTES_NAME=Apache Oozie
OOZIE_PKG_NAME=oozie
OOZIE_BASE_VERSION=3.2.0-incubating
OOZIE_PKG_VERSION=3.2.0
OOZIE_RELEASE_VERSION=1
OOZIE_TARBALL_DST=oozie-$(OOZIE_BASE_VERSION).tar.gz
OOZIE_TARBALL_SRC=$(OOZIE_TARBALL_DST)
OOZIE_DOWNLOAD_PATH=/incubator/$(OOZIE_NAME)/$(OOZIE_NAME)-$(OOZIE_BASE_VERSION)
OOZIE_SITE=$(APACHE_MIRROR)$(OOZIE_DOWNLOAD_PATH)
OOZIE_ARCHIVE=$(APACHE_ARCHIVE)$(OOZIE_DOWNLOAD_PATH)
$(eval $(call PACKAGE,oozie,OOZIE))

# Whirr
WHIRR_NAME=whirr
WHIRR_RELNOTES_NAME=Apache Whirr
WHIRR_PKG_NAME=whirr
WHIRR_BASE_VERSION=0.7.1
WHIRR_PKG_VERSION=0.7.1
WHIRR_RELEASE_VERSION=1
WHIRR_TARBALL_DST=whirr-$(WHIRR_BASE_VERSION).tar.gz
WHIRR_TARBALL_SRC=$(WHIRR_TARBALL_DST)
WHIRR_DOWNLOAD_PATH=/whirr/whirr-$(WHIRR_BASE_VERSION)
WHIRR_SITE=$(APACHE_MIRROR)$(WHIRR_DOWNLOAD_PATH)
WHIRR_ARCHIVE=$(APACHE_ARCHIVE)$(WHIRR_DOWNLOAD_PATH)
$(eval $(call PACKAGE,whirr,WHIRR))

# Mahout
MAHOUT_NAME=mahout
MAHOUT_RELNOTES_NAME=Apache Mahout
MAHOUT_PKG_NAME=mahout
MAHOUT_BASE_VERSION=0.7
MAHOUT_PKG_VERSION=0.7
MAHOUT_RELEASE_VERSION=1
MAHOUT_TARBALL_DST=mahout-distribution-$(MAHOUT_BASE_VERSION)-src.tar.gz
#MAHOUT_TARBALL_SRC=$(MAHOUT_TARBALL_DST)
#MAHOUT_DOWNLOAD_PATH=/mahout/$(MAHOUT_BASE_VERSION)
#MAHOUT_SITE=$(APACHE_MIRROR)$(MAHOUT_DOWNLOAD_PATH)
#MAHOUT_ARCHIVE=$(APACHE_ARCHIVE)$(MAHOUT_DOWNLOAD_PATH)
MAHOUT_TARBALL_SRC=05ce70d
MAHOUT_SITE=https://github.com/apache/mahout/tarball
MAHOUT_ARCHIVE=$(MAHOUT_SITE)
$(eval $(call PACKAGE,mahout,MAHOUT))

# Flume
FLUME_NAME=flume
FLUME_RELNOTES_NAME=Flume
FLUME_PKG_NAME=flume
FLUME_BASE_VERSION=1.1.0-incubating
FLUME_PKG_VERSION=1.1.0
FLUME_RELEASE_VERSION=1
FLUME_TARBALL_DST=apache-$(FLUME_NAME)-$(FLUME_BASE_VERSION).tar.gz
FLUME_TARBALL_SRC=apache-$(FLUME_NAME)-$(FLUME_BASE_VERSION).tar.gz
FLUME_DOWNLOAD_PATH=/incubator/flume/$(FLUME_PKG_NAME)-$(FLUME_BASE_VERSION)
FLUME_SITE=$(APACHE_MIRROR)$(FLUME_DOWNLOAD_PATH)
FLUME_ARCHIVE=$(APACHE_ARCHIVE)$(FLUME_DOWNLOAD_PATH)
$(eval $(call PACKAGE,flume,FLUME))

# Giraph
GIRAPH_NAME=giraph
GIRAPH_RELNOTES_NAME=Giraph
GIRAPH_PKG_NAME=giraph
GIRAPH_BASE_VERSION=0.2-SNAPSHOT
GIRAPH_PKG_VERSION=0.2
GIRAPH_RELEASE_VERSION=1
GIRAPH_TARBALL_DST=$(GIRAPH_NAME)-$(GIRAPH_BASE_VERSION).tar.gz
#GIRAPH_TARBALL_SRC=$(GIRAPH_NAME)-$(GIRAPH_BASE_VERSION)-src.tar.gz
#GIRAPH_DOWNLOAD_PATH=/incubator/giraph/$(GIRAPH_PKG_NAME)-$(GIRAPH_BASE_VERSION)
#GIRAPH_SITE=$(APACHE_MIRROR)$(GIRAPH_DOWNLOAD_PATH)
#GIRAPH_ARCHIVE=$(APACHE_ARCHIVE)$(GIRAPH_DOWNLOAD_PATH)
GIRAPH_TARBALL_SRC=79962a3
GIRAPH_SITE=https://github.com/apache/giraph/tarball
GIRAPH_ARCHIVE=$(GIRAPH_SITE)

$(eval $(call PACKAGE,giraph,GIRAPH))

# Bigtop-utils
BIGTOP_UTILS_NAME=bigtop-utils
BIGTOP_UTILS__RELNOTES_NAME=Bigtop-utils
BIGTOP_UTILS_PKG_NAME=bigtop-utils
BIGTOP_UTILS_BASE_VERSION=$(subst -,.,$(BIGTOP_VERSION))
BIGTOP_UTILS_PKG_VERSION=$(BIGTOP_UTILS_BASE_VERSION)
BIGTOP_UTILS_RELEASE_VERSION=1
$(eval $(call PACKAGE,bigtop-utils,BIGTOP_UTILS))

# Bigtop-jsvc
BIGTOP_JSVC_NAME=bigtop-jsvc
BIGTOP_JSVC_RELNOTES_NAME=Apache Commons Daemon (jsvc)
BIGTOP_JSVC_PKG_NAME=bigtop-jsvc
BIGTOP_JSVC_BASE_VERSION=1.0.10
BIGTOP_JSVC_PKG_VERSION=1.0.10
BIGTOP_JSVC_RELEASE_VERSION=1
BIGTOP_JSVC_TARBALL_SRC=commons-daemon-$(BIGTOP_JSVC_BASE_VERSION)-native-src.tar.gz
BIGTOP_JSVC_TARBALL_DST=commons-daemon-$(BIGTOP_JSVC_BASE_VERSION).tar.gz
BIGTOP_JSVC_SITE=$(APACHE_MIRROR)/commons/daemon/source/
$(eval $(call PACKAGE,bigtop-jsvc,BIGTOP_JSVC))

# Bigtop-tomcat
BIGTOP_TOMCAT_NAME=bigtop-tomcat
BIGTOP_TOMCAT_RELNOTES_NAME=Apache Tomcat
BIGTOP_TOMCAT_PKG_NAME=bigtop-tomcat
BIGTOP_TOMCAT_BASE_VERSION=6.0.35
BIGTOP_TOMCAT_PKG_VERSION=$(BIGTOP_TOMCAT_BASE_VERSION)
BIGTOP_TOMCAT_RELEASE_VERSION=1
BIGTOP_TOMCAT_TARBALL_SRC=apache-tomcat-$(BIGTOP_TOMCAT_BASE_VERSION)-src.tar.gz
BIGTOP_TOMCAT_TARBALL_DST=apache-tomcat-$(BIGTOP_TOMCAT_BASE_VERSION).tar.gz
BIGTOP_TOMCAT_SITE=$(APACHE_MIRROR)/tomcat/tomcat-6/v$(BIGTOP_TOMCAT_BASE_VERSION)/src/
$(eval $(call PACKAGE,bigtop-tomcat,BIGTOP_TOMCAT))
