#!/bin/bash

# Abort script if any command returns error
set -e

BUILD_DIR="build"
IMAGE_NAME="tinyos-image"
MACHINE_NAME="raspberrypi0-2w"
TARGET_VERSION="scarthgap"
DEVICE="/dev/sdb"

declare -a machines=("raspberrypi0-2w" "raspberrypi3-aplus" "raspberrypi4" "raspberrypi5")
declare -a recipes=("tinyos-image" "tinyos-debug-image" "package-index")

install() {
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install -y language-pack-en
    sudo apt-get install -y gawk wget git diffstat unzip texinfo gcc build-essential \
        chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils \
        iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev \
        xterm python3-subunit mesa-common-dev zstd liblz4-tool file
}

init() {
  git clone git://git.yoctoproject.org/poky poky -b $TARGET_VERSION
  git clone git://git.openembedded.org/meta-openembedded poky/meta-openembedded -b $TARGET_VERSION
  git clone https://github.com/tiny-osx/meta-tinyos-distro.git meta-tinyos-distro -b $TARGET_VERSION
  git clone https://github.com/tiny-osx/meta-dotnet.git meta-dotnet -b $TARGET_VERSION
  git clone https://github.com/tiny-osx/meta-raspberry.git meta-raspberry -b $TARGET_VERSION
  
  _source
  
  bitbake-layers add-layer ../poky/meta-openembedded/meta-oe/
  bitbake-layers add-layer ../meta-tinyos-distro/
  bitbake-layers add-layer ../meta-raspberry/
  bitbake-layers add-layer ../meta-dotnet/
}

bake() {
  _source
  MACHINE=$MACHINE_NAME bitbake $IMAGE_NAME
}

bakeall() {
  _source

  for machine in ${machines[*]}; do
    for recipe in ${recipes[*]}; do
      MACHINE="$machine" bitbake "$recipe" $1
    done
  done
}

cleanall() {
  _source

  for machine in ${machines[*]}; do
    for recipe in ${recipes[*]}; do
      MACHINE="$machine" bitbake "$recipe" -c clean
    done
  done
}

busybox() {
  _source
  bitbake -c menuconfig busybox
}

_function_yesno () {
    while :
    do
        echo "$* (Yes/No)?"
        read -r yn
        case $yn in
            yes|Yes|YES)
                return 0
                ;;
            no|No|NO)
                return 1
                ;;
            *)
                echo Please answer Yes or No.
                ;;
        esac
    done
}

_umount_part () {
    cnt_dev=1
    for p in $(mount|grep $DEVICE|cut -d' ' -f3); do
        part[$cnt_dev]=$p
        cnt_dev=$((cnt_dev + 1))
    done

    for (( i=1; i<${#part[@]}+1; i++ )); do
        path2part=${part[$i]}
        # unset or empty string
        if [ -z "$1" ]; then
            echo "$path2part"
        else
            sudo umount "$path2part"
        fi
    done
}

flash() {
 
  echo
  echo "Block device:"
  lsblk -p "$DEVICE"
  echo

  sudo chmod 666 $DEVICE

  if mount | grep -c "$DEVICE" &>/dev/null; then
    echo
    echo "Error! Unable write to mounted device: $DEVICE"
    echo "You should unmount the device before writing!"
    echo
    echo "Mounted parts of '$DEVICE':"
    _umount_part
    echo
    if _function_yesno "Would you like unmout them"; then
        echo 'Unmout ...'
        _umount_part "umount"
    else
        exit 0
    fi
  fi

  _source

  # bitbake rpiboot-native -c addto_recipe_sysroot

  # # Here's the easiest solution to unlock access to usb hardware
  # sudo chmod -R 777 /dev/bus/usb/
  # oe-run-native \
  #   rpiboot-native rpiboot

  # sudo chmod 666 $DEVICE

  bitbake bmaptool-native -c addto_recipe_sysroot

  oe-run-native \
    bmaptool-native bmaptool copy \
    ./tmp/deploy/images/$MACHINE_NAME/$IMAGE_NAME-$MACHINE_NAME.rootfs.wic.gz \
    $DEVICE

  # sudo udisksctl power-off -b $DEVICE
}

update() {
  git fetch --all
}

package() {
  _source
  bitbake package-index
  bitbake -g $IMAGE_NAME 
  cat pn-buildlist | grep -v native | sort
}

clean() {
  _source
  bitbake $IMAGE_NAME -c cleanall
}

qemu() {
  _source
  bitbake package-index
  runqemu $IMAGE_NAME nographic
}

_source() {
  source ./poky/oe-init-build-env $BUILD_DIR
}

if [[ $# -eq 0 ]] ; then
  bake
fi

case $1 in
  install)
    shift
    install "$@"
    ;;
  init)
    shift
    init "$@"
    ;;
  bake)
    shift
    bake "$@"
    ;;
  busybox)
    shift
    busybox "$@"
    ;;
  flash)
    shift
    flash "$@"
    ;;
  clean)
    shift
    clean "$@"
    ;;
  qemu)
    shift
    qemu "$@"
    ;;
  update)
    shift
    update "$@"
    ;;
  package)
    shift
    package "$@"
    ;;
  cleanall)
    shift
    cleanall "$@"
    ;;
  bakeall)
    shift
    bakeall "$@"
    ;;
esac
