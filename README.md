# TinyOS Build System

TinyOS is a open-source [Microsoft .NET](https://dotnet.microsoft.com/) platform based on OpenEmbedded and optimized for IoT devices. 

NOTE: THESE IMAGES ARE BETA AND AT THIS POINT DO NOT INCLUDED ANY SECURITY HARDENING. USE AT YOUR OWN RISK.

The following boards are known to build and work, but are not undergoing QA:

| Board                   | MACHINE                       | Notes |
| ----------------------- | ----------------------------- | ----- |
| [Raspberry Pi 0-2W](https://www.raspberrypi.com/products/raspberry-pi-zero-2-w) | `raspberrypi0-2w` | |
| [Raspberry Pi 3 Model A+](https://www.raspberrypi.com/products/raspberry-pi-3-model-a-plus) | `raspberrypi3-aplus` | OTG via type-A socket only an A-A USB or A-C cable is required. |
| [Raspberry Pi 4 Model B](https://www.raspberrypi.com/products/raspberry-pi-4-model-b) | `raspberrypi4` | |
| [Raspberry Pi 4 Compute Module](https://www.raspberrypi.com/products/compute-module-4) | `raspberrypi4` | |
| [Raspberry Pi 5](https://www.raspberrypi.com/products/raspberry-pi-5) | `raspberrypi5` | |

Note: OTG is not supported on Pi B, B+, 2, 3, 3A+, and 3B+

## Clone the Repository

If you haven't set a global git name and email yet, adapt the following git config commands to your information. (This is required to clone some git repositories when building.)

```bash
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

Clone the main repository using the following command:

```bash
git clone https://github.com/tiny-osx/tinyos-rpi.git
```

Before you continue to Build, make sure you're in the tinyos directory:
```bash
cd tinyos-rpi
./run-build.sh install
./run-build.sh init
```

Build TinyOS
```bash
./run-build.sh
```

# Give a Star! :star:

If you like or are using this project to start your solution, please give it a star. Thanks!

# Contributions

Contributions to this project are always welcome. Please consider forking this project on GitHub and sending a pull request to get your improvements added to the original project.

# Licenses

A TinyOS image is made of many components and it’s hard to describe the full details of all the licenses that are in use in the system. However, when building the system from sources with OpenEmbedded, one can find the exhaustive set of licenses used by each package in the `build/tmp/deploy/licenses` directory.
