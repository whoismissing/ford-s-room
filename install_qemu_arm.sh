#!/bin/bash
## Tested on Debian stretch
## Reference: https://gist.github.com/Liryna/10710751

sudo apt-get install qemu binfmt-support qemu-system-arm qemu-user-static -y
sudo apt-get install gcc-arm-linux-gnueabihf libc6-dev-armhf-cross -y

cat > hello.c << EOF
#include <stdio.h>
int main(void) { return printf("Hello ARM!\n"); }
EOF

# Compile code with arm toolchain
arm-linux-gnueabihf-gcc -static  -o hello hello.c

# Check file type of binary
file hello

# Test ARM binary
./hello
