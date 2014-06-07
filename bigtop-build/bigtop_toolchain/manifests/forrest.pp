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

class bigtop_toolchain::forrest {

  include bigtop_toolchain::deps

  exec{'/bin/tar xvzf /usr/src/apache-forrest-0.9.tar.gz':
    cwd         => '/usr/local',
    require     => Exec["/usr/bin/wget http://archive.apache.org/dist/forrest/0.9/apache-forrest-0.9.tar.gz"],
    refreshonly => true,
    subscribe   => Exec["/usr/bin/wget http://archive.apache.org/dist/forrest/0.9/apache-forrest-0.9.tar.gz"],
  }

  file { '/usr/local/apache-forrest':
    ensure  => link,
    target  => '/usr/local/apache-forrest-0.9',
    require => Exec['/bin/tar xvzf /usr/src/apache-forrest-0.9.tar.gz'],
  }
}
