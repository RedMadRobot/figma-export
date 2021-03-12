prefix ?= /usr/local
bindir = $(prefix)/bin

build:
	swift package clean
	swift build -c release --disable-sandbox

install: build
	install ".build/release/figma-export" "$(bindir)"

uninstall:
	rm -rf "$(bindir)/figma-export"

clean:
	rm -rf .build

.PHONY: build install uninstall clean