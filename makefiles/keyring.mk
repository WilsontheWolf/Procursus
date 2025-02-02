ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

STRAPPROJECTS    += keyring
KEYRING_VERSION  := 2020.05.09
DEB_KEYRING_V    ?= $(KEYRING_VERSION)-2

ifneq ($(wildcard $(BUILD_STAGE)/keyring/.build_complete),)
keyring:
	@echo "Using previously built keyring."
else
keyring: setup
	mkdir -p $(BUILD_STAGE)/keyring/$(MEMO_PREFIX)/etc/apt/trusted.gpg.d
	cp -a $(BUILD_MISC)/keyrings/procursus/memo.gpg $(BUILD_STAGE)/keyring/$(MEMO_PREFIX)/etc/apt/trusted.gpg.d
	$(call AFTER_BUILD)
endif

keyring-package: keyring-stage
	# keyring.mk Package Structure
	rm -rf $(BUILD_DIST)/keyring

	# keyring.mk Prep keyring
	cp -a $(BUILD_STAGE)/keyring $(BUILD_DIST)

	# keyring.mk Make .debs
	$(call PACK,keyring,DEB_KEYRING_V)

	# keyring.mk Build cleanup
	rm -rf $(BUILD_DIST)/keyring

.PHONY: keyring keyring-package
