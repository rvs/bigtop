# $NetBSD$
#
BASH?=/bin/bash

DISTNAME=       zookeeper-3.4.5	
CATEGORIES=	bigtop
MASTER_SITES=	http://archive.apache.org/dist/zookeeper/zookeeper-3.4.5/

MAINTAINER=	dev@bigtop.apache.org
HOMEPAGE=	http://zookeeper.apache.org/
COMMENT=	
LICENSE=	apache-2.0

PKG_DESTDIR_SUPPORT=	user-destdir

# DEPENDS+=	hadoop-[0-9]*:../../bigtop/bigtop

USE_LANGUAGES=	# none
USE_TOOLS+=	pax
# NO_BUILD=	yes

PKG_SYSCONFSUBDIR=	zookeeper

REPLACE_BASH+=		bin/*.sh

ZOOKEEPER_USERS+=	zookeeper:zookeeper
PKG_GECOS.zookeeper=	Zookeeper user
PKG_HOME.zookeeper=	${VARBASE}/db/zookeeper
PKG_SHELL.zookeeper=	${BASH}

OWN_DIRS_PERMS+=	${VARBASE}/log/zookeeper zookeeper zookeeper 750
OWN_DIRS_PERMS+=	${VARBASE}/db/zookeeper  zookeeper zookeeper 750
OWN_DIRS_PERMS+=        ${VARBASE}/run/zookeeper  zookeeper zookeeper 750

CONF_FILES+=		share/examples/zookeeper/configuration.xsl ${PKG_SYSCONFDIR}/configuration.xsl \
                        share/examples/zookeeper/log4j.properties  ${PKG_SYSCONFDIR}/log4j.properties  \
                        share/examples/zookeeper/zoo.cfg           ${PKG_SYSCONFDIR}/zoo.cfg           \
                        share/examples/zookeeper/zoo_sample.cfg    ${PKG_SYSCONFDIR}/zoo_sample.cfg

# INSTALLATION_DIRS+=	bin sbin 


# SUBST_CLASSES+=		conf
# SUBST_STAGE.conf=	pre-install
# SUBST_MESSAGE.conf=	Fixing default paths
# SUBST_FILES.conf=	bin/zoo
# SUBST_VARS.conf=	PKG_JAVA_HOME PKG_SYSCONFDIR PREFIX

do-build:
	cd ${WRKSRC} ; ${BASH} ${FILESDIR}/do-component-build -Divy.home=${HOME}/.ivy2
	${CP} ${FILESDIR}/* ${WRKSRC}

do-install:
	cd ${WRKSRC} ; ${BASH} -x ${FILESDIR}/install_zookeeper.sh --build-dir=${WRKSRC} --prefix=${DESTDIR}${PREFIX}
	mkdir -p ${DESTDIR}${PREFIX}/usr/share/examples/rc.d
	cp ${FILESDIR}/zookeeper-server.sh ${DESTDIR}${PREFIX}/usr/share/examples/rc.d/zookeeper
	mkdir -p ${DESTDIR}${PREFIX}/usr/share/smf/zookeeper
	cp ${FILESDIR}/manifest.xml ${DESTDIR}${PREFIX}/usr/share/smf/zookeeper
	mkdir -p ${DESTDIR}${PREFIX}/usr/share/examples/zookeeper
	mv ${DESTDIR}${PREFIX}/etc/zookeeper/*/* ${DESTDIR}${PREFIX}/usr/share/examples/zookeeper
	cd ${DESTDIR}${PREFIX} ; for i in `ls -d * | grep -v 'usr$$'` ; do rm -rf $$i ; done
	mv ${DESTDIR}${PREFIX}/usr/* ${DESTDIR}${PREFIX}
	rmdir ${DESTDIR}${PREFIX}/usr
	rm -f ${DESTDIR}${PREFIX}/lib/zookeeper/conf
	ln -s /opt/local/etc/zookeeper ${DESTDIR}${PREFIX}/lib/zookeeper/conf
	sed -i -e 's#nohup#exec nohup#' ${DESTDIR}${PREFIX}/lib/zookeeper/bin/zkServer.sh
	

.include "../../mk/bsd.pkg.mk"
