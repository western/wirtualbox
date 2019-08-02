#!/bin/bash

# check system libs for required

if ! whoami | grep -q root; then
    echo 'root required. exit.'
    exit 1
fi

if cat /etc/*release* | grep -q 'openSUSE Leap 15.1'; then
    echo 'openSUSE Leap 15.1 found'
else
    echo 'openSUSE Leap 15.1 required! exit.'
    exit 2
fi


zypper in -y uwsgi-psgi uwsgi

cpan HTTP::Entity::Parser
