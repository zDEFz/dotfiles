#!/bin/bash

# --- Core Nginx Services ---
# menu: Open URL | Open local Nginx Mainrig
open_url_nginx_mainrig()         { _open_local_service ""; }

# menu: Open URL | Open local food Mainrig
open_url_nginx_food_mainrig()     { _open_local_service "food/"; }

# menu: Open URL | Open local Ventoy_Web Mainrig
open_url_nginx_ventoy_web()      { _open_local_service "ventoy_web/"; }

# menu: Open URL | Open local Nginx Backups
open_url_nginx_backups()         { _open_local_service "backups/"; }

# menu: Open URL | Open local Nginx Cronlogs
open_url_nginx_cronlogs()        { _open_local_service "cronlogs/"; }

# menu: Open URL | Open local Nginx Videov
open_url_nginx_video()		   { _open_local_service "video/"; }

# menu: Open URL | Open local Linux Kernel Development URL 
open_url_nginx_lkd()            { _open_local_service "linux_kernel/"; }

# menu: Open URL | Open local Explainshell
open_url_nginx_explainshell()    { _open_local_service "explainshell/"; }

# menu: Open URL | Open local Gitea 
open_url_nginx_gitea()          { _open_local_service "gitea/"; }

# menu: Open URL | Open Proxmox VE Web UI pve
open_url_proxmox()              { _firefox_open_url "https://proxmox-7e49:8006/"; }

# --- Kiwix Documentation ---
# menu: Open URL | Open local ArchWiki
open_url_kiwix_archwiki()        { _open_local_service "kiwix/viewer#archlinux_en_all_maxi_2025-09/Main_page"; }

# menu: Open URL | Open local Wikipedia
open_url_kiwix_wikipedia()       { _open_local_service "kiwix/viewer#wikipedia_en_all_maxi_2025-08"; }

# menu: Open URL | Open local Japanese QA
open_url_kiwix_japanese_qa()     { _open_local_service "kiwix/viewer#japanese.stackexchange.com_mul_all_2025-12"; }

# --- Local Web Services (Now HTTPS) ---
# menu: Open URL | Open local Cyberchef
open_url_svc_cyberchef()         { _open_local_service "cyberchef/"; }

# menu: Open URL | Open local Audio Search
open_url_svc_audio_search()      { _open_local_service "audio/search_all/"; }

# menu: Open URL | Open local Shenzhen Solitaire
open_url_svc_solitaire()         { _open_local_service "shenzhen_solitaire/"; }

# --- External & Hardware ---
# menu: Open URL | Open local Fritzbox
open_url_ext_fritzbox()          { _firefox_open_url "http://fritz.box"; }

# menu: Open URL | Open local IPMI NAS
open_url_ext_ipmi_nas()          { _firefox_open_url "https://nas.ipmi/"; }

# menu: Open URL | Open local PiKVM
open_url_ext_pikvm()            { _chromium_open_url "https://pikvm/kvm"; }

# menu: Open URL | Open local Nginx Eaton UPS
open_url_eaton_ups()             { _firefox_open_url "https://eaton-5px-2200i/home"; }

# menu: Open URL | Open gitea.tail.ws Gitea 
open_url_nginx_gitea_tail_ws()   { _firefox_open_url "gitea.tail.ws/"; }


# Only run dispatcher if executed directly, not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
