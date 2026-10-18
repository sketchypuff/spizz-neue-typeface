# Every file inside a .glyphspackage, so editing one glyph triggers a rebuild
SOURCES := $(wildcard sources/*.glyphs) $(shell find sources -path '*.glyphspackage/*' -type f ! -name UIState.plist)
VENV    := venv
BIN     := $(VENV)/bin
# gftools calls fontmake etc. by name, so the venv must be on PATH
export PATH := $(CURDIR)/$(BIN):$(PATH)
PYTHON  ?= $(shell command -v python3.12 || command -v python3.11 || command -v python3.10)

.PHONY: help build test proof clean venv-clean

help:
	@echo "make build   Build variable, static and web fonts into fonts/"
	@echo "make test    Run Fontbakery and write a report to out/fontbakery/"
	@echo "make proof   Serve the proof page at http://localhost:8000/proof/"
	@echo "make clean   Remove build output"

$(BIN)/activate: requirements.txt
	@test -n "$(PYTHON)" || (echo "Needs Python 3.10+ (try: brew install python@3.12)"; exit 1)
	$(PYTHON) -m venv $(VENV)
	$(BIN)/pip install -U pip
	$(BIN)/pip install -r requirements.txt
	touch $@

build: $(BIN)/activate build.stamp

build.stamp: sources/config.yaml $(SOURCES)
	@test -n "$(SOURCES)" || (echo "No .glyphs source found in sources/"; exit 1)
	rm -rf fonts
	cd sources && ../$(BIN)/gftools builder config.yaml
	touch $@

test: build
	mkdir -p out/fontbakery
	$(BIN)/fontbakery check-universal -l WARN --succinct \
		--html out/fontbakery/report.html \
		$(wildcard fonts/variable/*.ttf fonts/ttf/*.ttf)

proof: build
	@echo "Open http://localhost:8000/proof/"
	python3 -m http.server 8000

clean:
	rm -rf fonts out build.stamp sources/instance_ufo sources/instance_ufos sources/master_ufo sources/build.ninja sources/.ninja_log

venv-clean:
	rm -rf $(VENV)
