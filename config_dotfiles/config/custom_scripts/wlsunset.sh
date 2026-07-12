#!/usr/bin/env bash
if pgrep -x wlsunset >/dev/null; then pkill -x wlsunset; else wlsunset -T 4001 >/dev/null 2>&1 & fi
