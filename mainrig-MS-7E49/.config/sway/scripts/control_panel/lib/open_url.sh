#!/bin/bash

# menu: Open URL | 0 Open nginx mainrig URL in Default Browser
open_url_nginx_mainrig() {
    _firefox_open_url "http://mainrig-MS-7E49/"
}

# menu: Open URL | Open nginx mainrig cronlog URL in Default Browser
open_url_nginx_mainrig_cronlog() {
    _firefox_open_url "http://mainrig-MS-7E49/cronlogs"
}

# menu: Open URL | Open nginx cockpit URL in Default Browser
open_url_nginx_cockpit() {
	_firefox_open_url "https://mainrig-ms-7e49:9090/"
}

# menu: Open URL | Open Portainer mainrig URL in Default Browser
open_url_portainer_mainrig() {
	_firefox_open_url "http://mainrig-MS-7E49:9000/"
}

# menu: Open URL | Open Explainshell mainrig URL in Default Browser
open_url_explainshell_mainrig() {
	_firefox_open_url "http://mainrig-MS-7E49/explainshell/"
}

# menu: Open URL | Open fritzbox URL in Default Browser
open_url_fritzbox() { 
    _firefox_open_url "http://fritz.box" 
}

# menu: Open URL | Open hostname URL in Default Browser
open_url_hostname() { 
    _firefox_open_url "http://$(hostname)/" 
}

# menu: Open URL | Open Cyberchef URL in Default Browser
open_url_cyberchef() {
    _firefox_open_url "http://$(hostname)/cyberchef/"
}

# menu: Open URL | Open audio search URL in Default Browser
open_url_audio_search() { 
    _firefox_open_url "http://$(hostname)/audio/search_all" 
}

# menu: Open URL | Open video URL in Default Browser
open_url_video_search() { 
    _firefox_open_url "http://$(hostname)/video/" 
}

# menu: Open URL | Open solitaire URL in Default Browser
open_url_solitaire() { 
    _firefox_open_url "http://$(hostname)/shenzhen_solitaire/" 
}

# menu: Open URL | Open kvm URL in Default Browser
open_url_kvm() { 
    _firefox_open_url "https://kvm" 
}


"$@"
