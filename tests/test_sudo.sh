#!/bin/bash

dorun()
{
    eval "$@"
}

sudorun()
{
    sudo "$@"
}

#run "EDITOR=vim crontab -e"
sudorun EDITOR=vim crontab -e
