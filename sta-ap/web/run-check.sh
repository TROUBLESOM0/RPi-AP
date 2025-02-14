#!/bin/bash
#
# run-check.sh v.1
# requires root:www-data u+rw,g+rx,o+r
#
#
dir=/usr/local/etc/lilypin/sta-ap
#
sudo bash $dir/check-net.sh
