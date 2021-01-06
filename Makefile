PROJX_NAM=project-x
PROJX_DIR=./$(PROJX_NAM)
PROJX_ZIP_URL=https://sourceforge.net/projects/project-x/files/project-x/ProjectX_0.91.0.00/ProjectX_0.91.0.zip
PROJX_ZIP=./$(PROJX_NAM).zip
PROJX_JAR=$(PROJX_DIR)/ProjectX.jar

JAVA=java
JAVA_OPTS=-Djava.awt.headless=true
PROJX=$(JAVA) $(JAVA_OPTS) -jar $(PROJX_JAR)

IN_DIR=in
OUT_DIR=out

VID_EXT=VID
AUD_EXT=AUD

define convert_with_ext
	for FILE in $(IN_DIR)/*.$(1); do \
		$(JAVA) $(JAVA_OPTS) -jar $(PROJX_JAR) -out $(OUT_DIR) $$FILE; \
    done
endef

$(PROJX_ZIP):
	wget -O $(PROJX_ZIP) $(PROJX_ZIP_URL)

$(PROJX_DIR): $(PROJX_ZIP)
	mkdir -p $(PROJX_DIR)
	bsdtar --strip-components=1 -C $(PROJX_DIR) -xvf $(PROJX_ZIP)

$(PROJX_JAR): $(PROJX_DIR)
	cd $(PROJX_DIR); sh ./build.sh

install: $(PROJX_JAR)

convert: clean
	mkdir -p $(OUT_DIR)
	$(call convert_with_ext,$(VID_EXT))
	$(call convert_with_ext,$(AUD_EXT))

clean:
	rm -rf $(OUT_DIR)/*

all: convert

.PHONY: install convert clean all
