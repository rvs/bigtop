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

class solr {
  define server($port = "1978", $port_admin = "1979", $zk = "localhost:2181", $root_url = "hdfs://localhost:8020/solr", $kerberos_realm = "") {
    package { "solr-server":
      ensure => latest,
    }

    file {
      "/etc/default/solr":
        content => template("solr/solr"),
        require => [Package["solr-server"]],
    }

    exec { "solr init":
      command => "/bin/bash -c '/usr/bin/solrctl init && /etc/init.d/solr-server init'",
      returns => [0, 1],
      require => [ Package["solr-server"], File["/etc/default/solr"] ],
      logoutput => true,
    }

    service { "solr-server":
      ensure => running,
      require => [ Package["solr-server"], File["/etc/default/solr"], Exec["solr init"] ],
      subscribe => [Package["solr-server"], File["/etc/default/solr"] ],
      hasrestart => true,
      hasstatus => true,
    } 

    if ($kerberos_realm) {
      file {
        "/etc/solr/conf/jaas.conf":
          content => template("solr/jaas.conf"),
          require => [Package["solr-server"]],
      }
    }
  }
}
