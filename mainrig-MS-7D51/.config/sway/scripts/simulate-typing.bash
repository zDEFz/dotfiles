#!/bin/bash

clipboard="$(wl-paste)"
echo "type $clipboard" | dotool
