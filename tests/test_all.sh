#!/bin/sh -e

epm update

epm --auto install erc

epm --auto remove erc

epm --auto autoremove

epm --auto upgrade

epm --auto downgrade-release
