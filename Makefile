INSTALL_TOP=/
INSTALL_TOP_SHARE=$(INSTALL_TOP)/share/lua/5.1
INSTALL_TOP_BIN=$(INSTALL_TOP)/bin
INSTALL_EXEC=cp -a

all: install

install:
	$(INSTALL_EXEC) unit.lua $(INSTALL_TOP_BIN)
	$(INSTALL_EXEC) unittest $(INSTALL_TOP_SHARE) 
	

clean:
