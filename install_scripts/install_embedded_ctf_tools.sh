#!/bin/bash

## Tested on Ubuntu 18.04 LTS

install_qemu_arm() {
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
}

install_qemu_mips() {

    sudo apt install qemu-system-mipsel qemu-system-mips -y
    sudo apt install gcc-mipsel-linux-gnu gcc-mips-linux-gnu -y

    cat > hello.c << EOF
#include <stdio.h>
int main(void) { return printf("Hello MIPS!\n"); }
EOF

    # Cross compile code with mips toolchain
    mips-linux-gnu-gcc -static -o hello hello.c

    # Check file type of binary
    file hello

    # Test MIPS binary
    ./hello
}

install_embedded_ctf_tools() {
    sudo apt install gdb-multiarch
    install_qemu_arm
    install_qemu_mips
}

install_embedded_ctf_tools
