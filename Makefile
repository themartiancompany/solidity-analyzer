# SPDX-License-Identifier: GPL-3.0-or-later

#    ----------------------------------------------------------------------
#    Copyright © 2024, 2025  Pellegrino Prevete
#
#    All rights reserved
#    ----------------------------------------------------------------------
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

PREFIX ?= /usr/local
_PROJECT=solidity-analyzer
_NAMESPACE=themartiancompany
DOC_DIR=$(DESTDIR)$(PREFIX)/share/doc/$(_PROJECT)
USR_DIR=$(DESTDIR)$(PREFIX)
BIN_DIR=$(DESTDIR)$(PREFIX)/bin
LIB_DIR=$(DESTDIR)$(PREFIX)/lib/$(_PROJECT)
MAN_DIR?=$(DESTDIR)$(PREFIX)/share/man
NODE_DIR=$(PREFIX)/lib/node_modules/$(_PROJECT)
BUILD_NPM_DIR=build

_INSTALL_FILE=\
  install \
    -vDm644
_INSTALL_EXE=\
  install \
    -vDm755
_INSTALL_DIR=\
  install \
    -vdm755

DOC_FILES=\
  $(wildcard \
      *.rst) \
  $(wildcard \
      *.md)
SCRIPT_FILES=\
  $(wildcard \
      $(_PROJECT)/*)
NPM_FILES=\
  "index.js" \
  "index.d.ts" \
  "Cargo.toml" \
  "Cargo.lock" \
  "build.rs" \
  "src" \
  "README.md" \
  "package.json" \
  "yarn.lock"

all: build-man build-npm

install: install-scripts install-doc install-examples install-man

install-scripts:

	$(_INSTALL_EXE) \
	  "$(_PROJECT)" \
	  "$(LIB_DIR)/$(_PROJECT)"
	$(_INSTALL_EXE) \
	  "lib$(_PROJECT)" \
	  "$(LIB_DIR)/lib$(_PROJECT)"
	ln \
	  -s \
	  "$(PREFIX)/lib/$(_PROJECT)/$(_PROJECT)" \
	  "$(BIN_DIR)/$(_PROJECT)"

build-npm:

	mkdir \
	  -p \
	  "build"
	cp \
	  -r \
	  $(NPM_FILES) \
	  "build"; \
	cd \
	  "build"; \
	_version="$$( \
	  cat \
	    "package.json" | \
	    jq \
	      --raw-output \
	      ".version")"; \
	npm \
	  install; \
	npm \
	  run \
	    build; \
	npm \
	  pack; \
	mv \
	  "$(_NAMESPACE)-$(_PROJECT)-$${_version}.tgz" \
	  ".."

install-npm:

	_npm_opts=( \
	  -g \
	  --prefix \
	    "$(USR_DIR)" \
	); \
	_version="$$( \
	  npm \
	    view \
	      "$$(pwd)" \
	      "version")"; \
	npm \
	  install \
	    "$${_npm_opts[@]}" \
	    "$(_NAMESPACE)-$(_PROJECT)-$${_version}.tgz"; \
	$(_INSTALL_DIR) \
	  "$(DESTDIR)$(PREFIX)/lib"; \
	ln \
	  -s \
	  "$(NODE_DIR)" \
	  "$(LIB_DIR)" || \
	true

publish-npm:

	cd \
	  "build"; \
	npm \
	  publish \
	  --access \
	    "public"

.PHONY: build-man build-npm install install-doc install-man install-npm install-scripts
