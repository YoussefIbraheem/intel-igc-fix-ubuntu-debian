#!/bin/sh
# systemd sleep hook to reload igc driver after resume

case "$1" in
  post)
    systemctl restart fix-igc-resume.service
    ;;
esac
