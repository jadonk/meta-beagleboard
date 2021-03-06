DESCRIPTION = "BeagleBone 101"

LICENSE = "MIT & LGPLv3 & others"
LIC_FILES_CHKSUM = "file://LICENSE;md5=f02920251cbdc9b014dc1cbdb2bb95c4"

PV = "1.0"

SRCREV = "16af4be3a79a94ef26ea6fa30eb041038b778511"
SRC_URI = "git://github.com/beagleboard/bone101.git"

S = "${WORKDIR}/git"

inherit allarch

do_install() {
	install -d ${D}${datadir}/${PN}
	cp -a ${S}/* ${D}${datadir}/${PN}
}

FILES_${PN} += "${datadir}/${PN}"
