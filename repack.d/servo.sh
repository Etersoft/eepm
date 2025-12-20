#!/bin/sh -x
# It will run with two args: buildroot spec
BUILDROOT="$1"
SPEC="$2"

. $(dirname $0)/common.sh

move_to_opt /servo

install_file $PRODUCTDIR/resources/servo_64.png /usr/share/icons/hicolor/64x64/apps/$PRODUCT.png
install_file $PRODUCTDIR/resources/servo_1024.png /usr/share/icons/hicolor/1024x1024/apps/$PRODUCT.png
install_file $PRODUCTDIR/resources/servo.svg /usr/share/icons/hicolor/scalable/apps/$PRODUCT.svg

install_file /opt/servo/resources/org.servo.Servo.desktop /usr/share/applications/org.servo.Servo.desktop

fix_desktop_file SERVO_SRC_PATH/target/release/servo

add_bin_link_command

