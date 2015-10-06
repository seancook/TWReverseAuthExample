PROJECT := ReverseAuth
WORKSPACE := $(PROJECT)Example.xcworkspace
SCHEME := $(PROJECT)

default: check-xctool
	xctool -workspace $(WORKSPACE) -scheme $(SCHEME)

check-xctool:
	@which xctool > /dev/null

clean: check-xctool
	xctool -workspace $(WORKSPACE) -scheme $(SCHEME) clean

.PHONY: clean default
