# efm32gg linux toolchain
This docker image is a manual build of the OSELAS Toolchain 2012-12 and ptxdist-2013.07.1 for tdt4258 since the linux project files is quite old.

To use this simply run in your project directory
```bash
docker run -it --privileged -v $(pwd):/work -v /dev/bus/usb:/dev/bus/usb stemnic/efm32gg-linux-toolchain:latest
```
