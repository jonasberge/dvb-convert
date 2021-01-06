PROJX_NAM=project-x
PROJX_DIR=$(PROJX_NAM)
PROJX_ZIP_URL=https://sourceforge.net/projects/project-x/files/project-x/ProjectX_0.91.0.00/ProjectX_0.91.0.zip
PROJX_ZIP=$(PROJX_NAM).zip
PROJX_JAR=$(PROJX_DIR)/ProjectX.jar

$(PROJX_ZIP):
	wget -O $(PROJX_ZIP) $(PROJX_ZIP_URL)

$(PROJX_DIR): $(PROJX_ZIP)
	mkdir -p $(PROJX_DIR)
	bsdtar --strip-components=1 -C $(PROJX_DIR) -xvf $(PROJX_ZIP)

$(PROJX_JAR): $(PROJX_DIR)
	cd $(PROJX_DIR); sh ./build.sh

install: $(PROJX_JAR)
	rm -f $(PROJX_ZIP)

clean:
	rm -rf $(PROJX_DIR)

.PHONY: install
