#!/bin/bash
set-xdg-firefox-default () {
	handlr set application/x-extension-htm firefox-default.desktop
	handlr set application/x-extension-html firefox-default.desktop
	handlr set application/x-extension-shtml firefox-default.desktop
	handlr set application/x-extension-xht firefox-default.desktop
	handlr set application/x-extension-xhtml firefox-default.desktop
	handlr set text/html firefox-default.desktop
	handlr set video/mp4 firefox-default.desktop
	handlr set x-scheme-handler/about firefox-default.desktop
	handlr set x-scheme-handler/chrome firefox-default.desktop
	handlr set x-scheme-handler/discord-4557121697957+ firefox-default.desktop
	handlr set x-scheme-handler/etcher balena-etcher.desktop
	handlr set x-scheme-handler/http firefox-default.desktop
	handlr set x-scheme-handler/https firefox-default.desktop
}

set-xdg-firefox-default
