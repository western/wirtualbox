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
zypper in -y perl-HTML-Template perl-Template-Toolkit perl-Crypt-CBC perl-Crypt-Blowfish perl-JSON-XS perl-DBD-Pg perl-DBD-mysql

cpan HTTP::Entity::Parser
cpan Cookie::Baker

