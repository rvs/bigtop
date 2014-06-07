#!/bin/sh -
#======================================================================================================================
# vim: softtabstop=4 shiftwidth=4 expandtab fenc=utf-8 spell spelllang=en cc=120
#======================================================================================================================
#
#          FILE: bootstrap-salt.sh
#
#   DESCRIPTION: Bootstrap salt installation for various systems/distributions
#
#          BUGS: https://github.com/saltstack/salt-bootstrap/issues
#
#     COPYRIGHT: (c) 2012-2014 by the SaltStack Team, see AUTHORS.rst for more
#                details.
#
#       LICENSE: Apache 2.0
#  ORGANIZATION: SaltStack (saltstack.org)
#       CREATED: 10/15/2012 09:49:37 PM WEST
#======================================================================================================================
set -o nounset                              # Treat unset variables as an error

# Bootstrap script truth values
BS_TRUE=1
BS_FALSE=0

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  echoerr
#   DESCRIPTION:  Echo errors to stderr.
#----------------------------------------------------------------------------------------------------------------------
echoerror() {
    printf "* ERROR: %s\n" "$@" 1>&2;
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  echoinfo
#   DESCRIPTION:  Echo information to stdout.
#----------------------------------------------------------------------------------------------------------------------
echoinfo() {
    printf "*  INFO: %s\n" "$@";
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  echowarn
#   DESCRIPTION:  Echo warning informations to stdout.
#----------------------------------------------------------------------------------------------------------------------
echowarn() {
    printf "*  WARN: %s\n" "$@";
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  echodebug
#   DESCRIPTION:  Echo debug information to stdout.
#----------------------------------------------------------------------------------------------------------------------
echodebug() {
    if [ $_ECHO_DEBUG -eq $BS_TRUE ]; then
        printf "* DEBUG: %s\n" "$@";
    fi
}

_ECHO_DEBUG=${BS_ECHO_DEBUG:-$BS_FALSE}
_WGET_ARGS=${BS_WGET_ARGS:-}
_CURL_ARGS=${BS_CURL_ARGS:-}
_FETCH_ARGS=${BS_FETCH_ARGS:-}
# __SIMPLIFY_VERSION is mostly used in Solaris based distributions
__SIMPLIFY_VERSION=$BS_TRUE

# whoami alternative for SunOS
if [ -f /usr/xpg4/bin/id ]; then
    whoami='/usr/xpg4/bin/id -un'
else
    whoami='whoami'
fi

# Root permissions are required to run this script
if [ "$(${whoami})" != "root" ]; then
    echoerror "Salt requires root privileges to install. Please re-run this script as root."
    exit 1
fi

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#         NAME:  __fetch_url
#  DESCRIPTION:  Retrieves a URL and writes it to a given path
#----------------------------------------------------------------------------------------------------------------------
__fetch_url() {
    curl $_CURL_ARGS -s -o "$1" "$2" >/dev/null 2>&1 ||
        wget $_WGET_ARGS -q -O "$1" "$2" >/dev/null 2>&1 ||
            fetch $_FETCH_ARGS -q -o "$1" "$2" >/dev/null 2>&1 ||
                fetch -q -o "$1" "$2" >/dev/null 2>&1           # Pre FreeBSD 10

}


#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __gather_hardware_info
#   DESCRIPTION:  Discover hardware information
#----------------------------------------------------------------------------------------------------------------------
__gather_hardware_info() {
    if [ -f /proc/cpuinfo ]; then
        CPU_VENDOR_ID=$(awk '/vendor_id|Processor/ {sub(/-.*$/,"",$3); print $3; exit}' /proc/cpuinfo )
    elif [ -f /usr/bin/kstat ]; then
        # SmartOS.
        # Solaris!?
        # This has only been tested for a GenuineIntel CPU
        CPU_VENDOR_ID=$(/usr/bin/kstat -p cpu_info:0:cpu_info0:vendor_id | awk '{print $2}')
    else
        CPU_VENDOR_ID=$( sysctl -n hw.model )
    fi
    CPU_VENDOR_ID_L=$( echo $CPU_VENDOR_ID | tr '[:upper:]' '[:lower:]' )
    CPU_ARCH=$(uname -m 2>/dev/null || uname -p 2>/dev/null || echo "unknown")
    CPU_ARCH_L=$( echo $CPU_ARCH | tr '[:upper:]' '[:lower:]' )

}
__gather_hardware_info


#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __gather_os_info
#   DESCRIPTION:  Discover operating system information
#----------------------------------------------------------------------------------------------------------------------
__gather_os_info() {
    OS_NAME=$(uname -s 2>/dev/null)
    OS_NAME_L=$( echo $OS_NAME | tr '[:upper:]' '[:lower:]' )
    OS_VERSION=$(uname -r)
    OS_VERSION_L=$( echo $OS_VERSION | tr '[:upper:]' '[:lower:]' )
}
__gather_os_info


#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __parse_version_string
#   DESCRIPTION:  Parse version strings ignoring the revision.
#                 MAJOR.MINOR.REVISION becomes MAJOR.MINOR
#----------------------------------------------------------------------------------------------------------------------
__parse_version_string() {
    VERSION_STRING="$1"
    PARSED_VERSION=$(
        echo $VERSION_STRING |
        sed -e 's/^/#/' \
            -e 's/^#[^0-9]*\([0-9][0-9]*\.[0-9][0-9]*\)\(\.[0-9][0-9]*\).*$/\1/' \
            -e 's/^#[^0-9]*\([0-9][0-9]*\.[0-9][0-9]*\).*$/\1/' \
            -e 's/^#[^0-9]*\([0-9][0-9]*\).*$/\1/' \
            -e 's/^#.*$//'
    )
    echo $PARSED_VERSION
}


#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __unquote_string
#   DESCRIPTION:  Strip single or double quotes from the provided string.
#----------------------------------------------------------------------------------------------------------------------
__unquote_string() {
    echo "${@}" | sed "s/^\([\"']\)\(.*\)\1\$/\2/g"
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __camelcase_split
#   DESCRIPTION:  Convert CamelCased strings to Camel_Cased
#----------------------------------------------------------------------------------------------------------------------
__camelcase_split() {
    echo "${@}" | sed -r 's/([^A-Z-])([A-Z])/\1 \2/g'
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __strip_duplicates
#   DESCRIPTION:  Strip duplicate strings
#----------------------------------------------------------------------------------------------------------------------
__strip_duplicates() {
    echo "${@}" | tr -s '[:space:]' '\n' | awk '!x[$0]++'
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __sort_release_files
#   DESCRIPTION:  Custom sort function. Alphabetical or numerical sort is not
#                 enough.
#----------------------------------------------------------------------------------------------------------------------
__sort_release_files() {
    KNOWN_RELEASE_FILES=$(echo "(arch|centos|debian|ubuntu|fedora|redhat|suse|\
        mandrake|mandriva|gentoo|slackware|turbolinux|unitedlinux|lsb|system|\
        oracle|os)(-|_)(release|version)" | sed -r 's:[[:space:]]::g')
    primary_release_files=""
    secondary_release_files=""
    # Sort know VS un-known files first
    for release_file in $(echo "${@}" | sed -r 's:[[:space:]]:\n:g' | sort --unique --ignore-case); do
        match=$(echo $release_file | egrep -i ${KNOWN_RELEASE_FILES})
        if [ "x${match}" != "x" ]; then
            primary_release_files="${primary_release_files} ${release_file}"
        else
            secondary_release_files="${secondary_release_files} ${release_file}"
        fi
    done

    # Now let's sort by know files importance, max important goes last in the max_prio list
    max_prio="redhat-release centos-release"
    for entry in $max_prio; do
        if [ "x$(echo ${primary_release_files} | grep $entry)" != "x" ]; then
            primary_release_files=$(echo ${primary_release_files} | sed -e "s:\(.*\)\($entry\)\(.*\):\2 \1 \3:g")
        fi
    done
    # Now, least important goes last in the min_prio list
    min_prio="lsb-release"
    for entry in $min_prio; do
        if [ "x$(echo ${primary_release_files} | grep $entry)" != "x" ]; then
            primary_release_files=$(echo ${primary_release_files} | sed -e "s:\(.*\)\($entry\)\(.*\):\1 \3 \2:g")
        fi
    done

    # Echo the results collapsing multiple white-space into a single white-space
    echo "${primary_release_files} ${secondary_release_files}" | sed -r 's:[[:space:]]:\n:g'
}


#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __gather_linux_system_info
#   DESCRIPTION:  Discover Linux system information
#----------------------------------------------------------------------------------------------------------------------
__gather_linux_system_info() {
    DISTRO_NAME=""
    DISTRO_VERSION=""

    # Let's test if the lsb_release binary is available
    rv=$(lsb_release >/dev/null 2>&1)
    if [ $? -eq 0 ]; then
        DISTRO_NAME=$(lsb_release -si)
        if [ "${DISTRO_NAME}" = "Scientific" ]; then
            DISTRO_NAME="Scientific Linux"
        elif [ "x$(echo "$DISTRO_NAME" | grep RedHat)" != "x" ]; then
            # Let's convert CamelCase to Camel Case
            DISTRO_NAME=$(__camelcase_split "$DISTRO_NAME")
        elif [ "${DISTRO_NAME}" = "openSUSE project" ]; then
            # lsb_release -si returns "openSUSE project" on openSUSE 12.3
            DISTRO_NAME="opensuse"
        elif [ "${DISTRO_NAME}" = "SUSE LINUX" ]; then
            # lsb_release -si returns "SUSE LINUX" on SLES 11 SP3
            DISTRO_NAME="suse"
        elif [ "${DISTRO_NAME}" = "EnterpriseEnterpriseServer" ]; then
            # This the Oracle Linux Enterprise ID before ORACLE LINUX 5 UPDATE 3
            DISTRO_NAME="Oracle Linux"
        fi
        rv=$(lsb_release -sr)
        [ "${rv}x" != "x" ] && DISTRO_VERSION=$(__parse_version_string "$rv")
    elif [ -f /etc/lsb-release ]; then
        # We don't have the lsb_release binary, though, we do have the file it parses
        DISTRO_NAME=$(grep DISTRIB_ID /etc/lsb-release | sed -e 's/.*=//')
        rv=$(grep DISTRIB_RELEASE /etc/lsb-release | sed -e 's/.*=//')
        [ "${rv}x" != "x" ] && DISTRO_VERSION=$(__parse_version_string "$rv")
    fi

    if [ "x$DISTRO_NAME" != "x" ] && [ "x$DISTRO_VERSION" != "x" ]; then
        # We already have the distribution name and version
        return
    fi

    for rsource in $(__sort_release_files $(
            cd /etc && /bin/ls *[_-]release *[_-]version 2>/dev/null | env -i sort | \
            sed -e '/^redhat-release$/d' -e '/^lsb-release$/d'; \
            echo redhat-release lsb-release
            )); do

        [ -L "/etc/${rsource}" ] && continue        # Don't follow symlinks
        [ ! -f "/etc/${rsource}" ] && continue      # Does not exist

        n=$(echo ${rsource} | sed -e 's/[_-]release$//' -e 's/[_-]version$//')
        rv=$( (grep VERSION /etc/${rsource}; cat /etc/${rsource}) | grep '[0-9]' | sed -e 'q' )
        [ "${rv}x" = "x" ] && continue  # There's no version information. Continue to next rsource
        v=$(__parse_version_string "$rv")
        case $(echo ${n} | tr '[:upper:]' '[:lower:]') in
            redhat             )
                if [ ".$(egrep 'CentOS' /etc/${rsource})" != . ]; then
                    n="CentOS"
                elif [ ".$(egrep 'Scientific' /etc/${rsource})" != . ]; then
                    n="Scientific Linux"
                elif [ ".$(egrep 'Red Hat Enterprise Linux' /etc/${rsource})" != . ]; then
                    n="<R>ed <H>at <E>nterprise <L>inux"
                else
                    n="<R>ed <H>at <L>inux"
                fi
                ;;
            arch               ) n="Arch Linux"     ;;
            centos             ) n="CentOS"         ;;
            debian             ) n="Debian"         ;;
            ubuntu             ) n="Ubuntu"         ;;
            fedora             ) n="Fedora"         ;;
            suse               ) n="SUSE"           ;;
            mandrake*|mandriva ) n="Mandriva"       ;;
            gentoo             ) n="Gentoo"         ;;
            slackware          ) n="Slackware"      ;;
            turbolinux         ) n="TurboLinux"     ;;
            unitedlinux        ) n="UnitedLinux"    ;;
            oracle             ) n="Oracle Linux"   ;;
            system             )
                while read -r line; do
                    [ "${n}x" != "systemx" ] && break
                    case "$line" in
                        *Amazon*Linux*AMI*)
                            n="Amazon Linux AMI"
                            break
                    esac
                done < /etc/${rsource}
                ;;
            os                 )
                nn="$(__unquote_string $(grep '^ID=' /etc/os-release | sed -e 's/^ID=\(.*\)$/\1/g'))"
                rv="$(__unquote_string $(grep '^VERSION_ID=' /etc/os-release | sed -e 's/^VERSION_ID=\(.*\)$/\1/g'))"
                [ "${rv}x" != "x" ] && v=$(__parse_version_string "$rv") || v=""
                case $(echo ${nn} | tr '[:upper:]' '[:lower:]') in
                    arch        )
                        n="Arch Linux"
                        v=""  # Arch Linux does not provide a version.
                        ;;
                    debian      )
                        n="Debian"
                        if [ "${v}x" = "x" ]; then
                            if [ "$(cat /etc/debian_version)" = "wheezy/sid" ]; then
                                # I've found an EC2 wheezy image which did not tell its version
                                v=$(__parse_version_string "7.0")
                            elif [ "$(cat /etc/debian_version)" = "jessie/sid" ]; then
                                # Let's start detecting the upcoming Debian 8 (Jessie)
                                v=$(__parse_version_string "8.0")
                            fi
                        else
                            echowarn "Unable to parse the Debian Version"
                        fi
                        ;;
                    *           )
                        n=${nn}
                        ;;
                esac
                ;;
            *                  ) n="${n}"           ;
        esac
        DISTRO_NAME=$n
        DISTRO_VERSION=$v
        break
    done
}


#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __gather_sunos_system_info
#   DESCRIPTION:  Discover SunOS system info
#----------------------------------------------------------------------------------------------------------------------
__gather_sunos_system_info() {
    if [ -f /sbin/uname ]; then
        DISTRO_VERSION=$(/sbin/uname -X | awk '/[kK][eE][rR][nN][eE][lL][iI][dD]/ { print $3}')
    fi

    DISTRO_NAME=""
    if [ -f /etc/release ]; then
        while read -r line; do
            [ "${DISTRO_NAME}x" != "x" ] && break
            case "$line" in
                *OpenIndiana*oi_[0-9]*)
                    DISTRO_NAME="OpenIndiana"
                    DISTRO_VERSION=$(echo "$line" | sed -nr "s/OpenIndiana(.*)oi_([[:digit:]]+)(.*)/\2/p")
                    break
                    ;;
                *OpenSolaris*snv_[0-9]*)
                    DISTRO_NAME="OpenSolaris"
                    DISTRO_VERSION=$(echo "$line" | sed -nr "s/OpenSolaris(.*)snv_([[:digit:]]+)(.*)/\2/p")
                    break
                    ;;
                *Oracle*Solaris*[0-9]*)
                    DISTRO_NAME="Oracle Solaris"
                    DISTRO_VERSION=$(echo "$line" | sed -nr "s/(Oracle Solaris) ([[:digit:]]+)(.*)/\2/p")
                    break
                    ;;
                *Solaris*)
                    DISTRO_NAME="Solaris"
                    # Let's make sure we not actually on a Joyent's SmartOS VM since some releases
                    # don't have SmartOS in `/etc/release`, only `Solaris`
                    uname -v | grep joyent >/dev/null 2>&1
                    if [ $? -eq 0 ]; then
                        DISTRO_NAME="SmartOS"
                    fi
                    break
                    ;;
                *NexentaCore*)
                    DISTRO_NAME="Nexenta Core"
                    break
                    ;;
                *SmartOS*)
                    DISTRO_NAME="SmartOS"
                    break
                    ;;
                *OmniOS*)
                    DISTRO_NAME="OmniOS"
                    DISTRO_VERSION=$(echo "$line" | awk '{print $3}')
                    __SIMPLIFY_VERSION=$BS_FALSE
                    break
                    ;;
            esac
        done < /etc/release
    fi

    if [ "${DISTRO_NAME}x" = "x" ]; then
        DISTRO_NAME="Solaris"
        DISTRO_VERSION=$(
            echo "${OS_VERSION}" |
            sed -e 's;^4\.;1.;' \
                -e 's;^5\.\([0-6]\)[^0-9]*$;2.\1;' \
                -e 's;^5\.\([0-9][0-9]*\).*;\1;'
        )
    fi

    if [ "${DISTRO_NAME}" = "SmartOS" ]; then
        VIRTUAL_TYPE="smartmachine"
        if [ "$(zonename)" = "global" ]; then
            VIRTUAL_TYPE="global"
        fi
    fi
}


#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __gather_bsd_system_info
#   DESCRIPTION:  Discover OpenBSD, NetBSD and FreeBSD systems information
#----------------------------------------------------------------------------------------------------------------------
__gather_bsd_system_info() {
    DISTRO_NAME=${OS_NAME}
    DISTRO_VERSION=$(echo "${OS_VERSION}" | sed -e 's;[()];;' -e 's/-.*$//')
}


#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __gather_system_info
#   DESCRIPTION:  Discover which system and distribution we are running.
#----------------------------------------------------------------------------------------------------------------------
__gather_system_info() {
    case ${OS_NAME_L} in
        linux )
            __gather_linux_system_info
            ;;
        sunos )
            __gather_sunos_system_info
            ;;
        openbsd|freebsd|netbsd )
            __gather_bsd_system_info
            ;;
        * )
            echoerror "${OS_NAME} not supported.";
            exit 1
            ;;
    esac

}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __ubuntu_derivatives_translation
#   DESCRIPTION:  Map Ubuntu derivatives to their Ubuntu base versions.
#                 If distro has a known Ubuntu base version, use those install
#                 functions by pretending to be Ubuntu (i.e. change global vars)
#----------------------------------------------------------------------------------------------------------------------
__ubuntu_derivatives_translation() {
    UBUNTU_DERIVATIVES="(trisquel|linuxmint|linaro|elementary_os)"
    # Mappings
    trisquel_6_ubuntu_base="12.04"
    linuxmint_13_ubuntu_base="12.04"
    linuxmint_14_ubuntu_base="12.10"
    #linuxmint_15_ubuntu_base="13.04"
    # Bug preventing add-apt-repository from working on Mint 15:
    # https://bugs.launchpad.net/linuxmint/+bug/1198751

    linuxmint_16_ubuntu_base="13.10"
    linaro_12_ubuntu_base="12.04"
    elementary_os_02_ubuntu_base="12.04"

    # Translate Ubuntu derivatives to their base Ubuntu version
    match=$(echo $DISTRO_NAME_L | egrep ${UBUNTU_DERIVATIVES})

    if [ "x${match}" != "x" ]; then
        case $match in
            "elementary_os")
                _major="$(echo $DISTRO_VERSION | sed 's/\.//g')"
                ;;
            *)
                _major="$(echo $DISTRO_VERSION | sed 's/^\([0-9]*\).*/\1/g')"
                ;;
        esac

        _ubuntu_version="$(eval echo \$${1}_${_major}_ubuntu_base)"

        if [ "x$_ubuntu_version" != "x" ]; then
            echodebug "Detected Ubuntu $_ubuntu_version derivative"
            DISTRO_NAME_L="ubuntu"
            DISTRO_VERSION="$_ubuntu_version"
        fi
    fi
}

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __debian_derivatives_translation
#   DESCRIPTION:  Map Debian derivatives to their Debian base versions.
#                 If distro has a known Debian base version, use those install
#                 functions by pretending to be Debian (i.e. change global vars)
#----------------------------------------------------------------------------------------------------------------------
__debian_derivatives_translation() {

    # If the file does not exist, return
    [ ! -f /etc/os-release ] && return

    DEBIAN_DERIVATIVES="(kali)"
    # Mappings
    kali_1_debian_base="7.0"

    # Detect derivates, Kali *only* for now
    rv=$(grep ^ID= /etc/os-release | sed -e 's/.*=//')

    # Translate Debian derivatives to their base Debian version
    match=$(echo $rv | egrep ${DEBIAN_DERIVATIVES})

    if [ "x${match}" != "x" ]; then
        case $match in
            kali)
                _major="$(echo $DISTRO_VERSION | sed 's/^\([0-9]*\).*/\1/g')"
                _debian_derivative="kali"
                ;;
        esac

        _debian_version="$(eval echo \$${_debian_derivative}_${_major}_debian_base)"

        if [ "x$_debian_version" != "x" ]; then
            echodebug "Detected Debian $_debian_version derivative"
            DISTRO_NAME_L="debian"
            DISTRO_VERSION="$_debian_version"
        fi
    fi
}

__gather_system_info

echo
echoinfo "System Information:"
echoinfo "  CPU:          ${CPU_VENDOR_ID}"
echoinfo "  CPU Arch:     ${CPU_ARCH}"
echoinfo "  OS Name:      ${OS_NAME}"
echoinfo "  OS Version:   ${OS_VERSION}"
echoinfo "  Distribution: ${DISTRO_NAME} ${DISTRO_VERSION}"
echo

# Simplify distro name naming on functions
DISTRO_NAME_L=$(echo $DISTRO_NAME | tr '[:upper:]' '[:lower:]' | sed 's/[^a-zA-Z0-9_ ]//g' | sed -re 's/([[:space:]])+/_/g')

# For Ubuntu derivatives, pretend to be their Ubuntu base version
__ubuntu_derivatives_translation

# For Debian derivates, pretend to be their Debian base version
__debian_derivatives_translation

# Simplify version naming on functions
if [ "x${DISTRO_VERSION}" = "x" ] || [ $__SIMPLIFY_VERSION -eq $BS_FALSE ]; then
    DISTRO_MAJOR_VERSION=""
    DISTRO_MINOR_VERSION=""
    PREFIXED_DISTRO_MAJOR_VERSION=""
    PREFIXED_DISTRO_MINOR_VERSION=""
else
    DISTRO_MAJOR_VERSION="$(echo $DISTRO_VERSION | sed 's/^\([0-9]*\).*/\1/g')"
    DISTRO_MINOR_VERSION="$(echo $DISTRO_VERSION | sed 's/^\([0-9]*\).\([0-9]*\).*/\2/g')"
    PREFIXED_DISTRO_MAJOR_VERSION="_${DISTRO_MAJOR_VERSION}"
    if [ "${PREFIXED_DISTRO_MAJOR_VERSION}" = "_" ]; then
        PREFIXED_DISTRO_MAJOR_VERSION=""
    fi
    PREFIXED_DISTRO_MINOR_VERSION="_${DISTRO_MINOR_VERSION}"
    if [ "${PREFIXED_DISTRO_MINOR_VERSION}" = "_" ]; then
        PREFIXED_DISTRO_MINOR_VERSION=""
    fi
fi

#---  FUNCTION  -------------------------------------------------------------------------------------------------------
#          NAME:  __function_defined
#   DESCRIPTION:  Checks if a function is defined within this scripts scope
#    PARAMETERS:  function name
#       RETURNS:  0 or 1 as in defined or not defined
#----------------------------------------------------------------------------------------------------------------------
__function_defined() {
    FUNC_NAME=$1
    if [ "$(command -v $FUNC_NAME)x" != "x" ]; then
        echoinfo "Found function $FUNC_NAME"
        return 0
    fi
    echodebug "$FUNC_NAME not found...."
    return 1
}

install_puppet_ubuntu() {
    local PUPPETLABS_APT_PKG_ubuntu_10_04=http://apt.puppetlabs.com/puppetlabs-release-lucid.deb
    local PUPPETLABS_APT_PKG_ubuntu_10_10=http://apt.puppetlabs.com/puppetlabs-release-lucid.deb
    local PUPPETLABS_APT_PKG_ubuntu_11_04=http://apt.puppetlabs.com/puppetlabs-release-lucid.deb
    local PUPPETLABS_APT_PKG_ubuntu_11_10=http://apt.puppetlabs.com/puppetlabs-release-lucid.deb
    local PUPPETLABS_APT_PKG_ubuntu_12_04=http://apt.puppetlabs.com/puppetlabs-release-precise.deb
    local PUPPETLABS_APT_PKG_ubuntu_12_10=http://apt.puppetlabs.com/puppetlabs-release-quantal.deb
    local PUPPETLABS_APT_PKG_ubuntu_13_04=http://apt.puppetlabs.com/puppetlabs-release-quantal.deb
    local PUPPETLABS_APT_PKG_ubuntu_13_10=http://apt.puppetlabs.com/puppetlabs-release-saucy.deb
    local PUPPETLABS_APT_PKG_ubuntu_14_04=http://apt.puppetlabs.com/puppetlabs-release-trusty.deb
    local URL=`eval echo '$PUPPETLABS_APT_PKG_'${DISTRO_NAME_L}${PREFIXED_DISTRO_MAJOR_VERSION}${PREFIXED_DISTRO_MINOR_VERSION}`

    apt-get install -y wget
    __fetch_url $URL /tmp/puppet.deb
    dpkg -i /tmp/puppet.deb
    rm /tmp/puppet.deb 
}

INST_FUNC_NAMES=""
INST_FUNC_NAMES="$INST_FUNC_NAMES install_puppet_${DISTRO_NAME_L}${PREFIXED_DISTRO_MAJOR_VERSION}${PREFIXED_DISTRO_MINOR_VERSION}"
INST_FUNC_NAMES="$INST_FUNC_NAMES install_puppet_${DISTRO_NAME_L}${PREFIXED_DISTRO_MAJOR_VERSION}"
INST_FUNC_NAMES="$INST_FUNC_NAMES install_puppet_${DISTRO_NAME_L}"

INSTALL_FUNC="null"
for INST_FUNC_NAME in $(__strip_duplicates $INST_FUNC_NAMES); do
    echo "Trying $INST_FUNC_NAME"
    if __function_defined $INST_FUNC_NAME; then
        INSTALL_FUNC=$INST_FUNC_NAME
        break
    fi
done
echo "INSTALL_FUNC=${INSTALL_FUNC}"
