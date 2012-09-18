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

%define crunch_name crunch
%define lib_crunch /usr/lib/crunch

%if  %{?suse_version:1}0
%define doc_crunch %{_docdir}/crunch-doc
%else
%define doc_crunch %{_docdir}/crunch-doc-%{crunch_version}
%endif

# disable repacking jars
%define __os_install_post %{nil}

Name: crunch
Version: %{crunch_version}
Release: %{crunch_release}
Summary: Simple and Efficient MapReduce Pipelines.
URL: http://incubator.apache.org/crunch/
Group: Development/Libraries
BuildArch: noarch
Buildroot: %(mktemp -ud %{_tmppath}/%{crunch_name}-%{version}-%{release}-XXXXXX)
License: ASL 2.0 
Source0: apache-%{crunch_name}-%{crunch_base_version}.tar.gz
Source1: do-component-build 
Source2: install_%{crunch_name}.sh


%description 
Apache Crunch (incubating) is a Java library for writing, testing, and running
MapReduce pipelines, based on Google's FlumeJava. Its goal is to make 
pipelines that are composed of many user-defined functions simple to write, 
easy to test, and efficient to run.

%package doc
Summary: Apache Crunch (incubating) documentation
Group: Documentation
%description doc
Apache Crunch (incubating) documentation

%prep
# %setup -n %{crunch_name}-%{crunch_base_version}
%setup -n rvs-crunch-4666bd8

%build
bash $RPM_SOURCE_DIR/do-component-build

%install
%__rm -rf $RPM_BUILD_ROOT
sh $RPM_SOURCE_DIR/install_crunch.sh \
          --build-dir=${PWD}         \
          --doc-dir=%{doc_crunch}    \
          --prefix=$RPM_BUILD_ROOT

#######################
#### FILES SECTION ####
#######################
%files 
%defattr(-,root,root,755)
%{lib_crunch}

%files doc
%defattr(-,root,root,755)
%{doc_crunch}
