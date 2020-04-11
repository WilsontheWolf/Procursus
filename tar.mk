ifneq ($(CHECKRA1N_MEMO),1)
$(error Use the main Makefile)
endif

TAR_VERSION := 1.32
DEB_TAR_V   ?= $(TAR_VERSION)

# `gl_cv_func_ftello_works=yes` workaround for gnulib issue on macOS Catalina, presumably also
# iOS 13, borrowed from Homebrew formula for coreutils
# TODO: Remove when GNU fixes this issue

ifneq ($(wildcard $(BUILD_WORK)/tar/.build_complete),)
tar:
	@echo "Using previously built tar."
else
tar: setup
	cd $(BUILD_WORK)/tar && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--disable-nls \
		gl_cv_func_ftello_works=yes
	+$(MAKE) -C $(BUILD_WORK)/tar
	+$(MAKE) -C $(BUILD_WORK)/tar install \
		DESTDIR=$(BUILD_STAGE)/tar
	touch $(BUILD_WORK)/tar/.build_complete
endif

tar-package: tar-stage
	# tar.mk Package Structure
	rm -rf $(BUILD_DIST)/tar
	mkdir -p $(BUILD_DIST)/tar/bin
	
	# tar.mk Prep tar
	$(FAKEROOT) cp -a $(BUILD_STAGE)/tar/usr $(BUILD_DIST)/tar
	ln -s /usr/bin/tar $(BUILD_DIST)/tar/bin/tar
	
	# tar.mk Sign
	$(call SIGN,tar,general.xml)
	
	# tar.mk Make .debs
	$(call PACK,tar,DEB_TAR_V)
	
	# tar.mk Build cleanup
	rm -rf $(BUILD_DIST)/tar

.PHONY: tar tar-package
