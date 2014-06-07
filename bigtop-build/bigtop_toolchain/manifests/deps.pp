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
class bigtop_toolchain::deps {

  include bigtop_toolchain::packages
  # include bigtop_toolchain::jdk

  case $operatingsystem{
    Ubuntu: { $scala_file = 'scala-2.10.3.deb' }
    default: { $scala_file = 'scala-2.10.3.rpm'}
  }

  exec {"/usr/bin/wget http://www.scala-lang.org/files/archive/$scala_file":
    cwd     => "/usr/src",
    require => Package[$packages::pkgs],
    unless  => "/usr/bin/test -f /usr/src/$scala_file",
  }

  exec {"/usr/bin/wget http://mirrors.ibiblio.org/apache//ant/binaries/apache-ant-1.9.4-bin.tar.gz":
    cwd     => "/usr/src",
    require => Package[$packages::pkgs],
    unless  => "/usr/bin/test -f /usr/src/apache-ant-1.9.4-bin.tar.gz",
  }

  exec {"/usr/bin/wget http://archive.apache.org/dist/forrest/0.9/apache-forrest-0.9.tar.gz":
    cwd     => "/usr/src",
    require => Package[$packages::pkgs],
    unless  => "/usr/bin/test -f /usr/src/apache-forrest-0.9.tar.gz",
  }

  exec {"/usr/bin/wget ftp://mirror.reverse.net/pub/apache/maven/maven-3/3.0.5/binaries/apache-maven-3.0.5-bin.tar.gz":
    cwd     => "/usr/src",
    require => Package[$packages::pkgs],
    unless  => "/usr/bin/test -f /usr/src/apache-maven-3.0.5-bin.tar.gz",
  }

  exec {"/usr/bin/wget http://services.gradle.org/distributions/gradle-1.10-bin.zip":
    cwd     => "/usr/src",
    require => Package[$packages::pkgs],
    unless  => "/usr/bin/test -f /usr/src/gradle-1.10-bin.zip",
  }
}
