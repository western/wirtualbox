#!/bin/bash

# check system libs for required

if ! whoami | grep -q root; then
    echo 'root required. exit.'
    exit 1
fi

if cat /etc/*release* | grep -q 'VERSION="9 (stretch)"'; then
    echo "Debian 9 found"
else
    echo "Debian 9 not found"
    exit 2
fi

