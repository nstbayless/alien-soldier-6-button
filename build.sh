#!/bin/bash
set -e
chmod a+x ./build.sh
chmod a-w ./base.md
m68k-linux-gnu-as -o hack.o hack.s
m68k-linux-gnu-ld hack.o -o hack.elf
m68k-linux-gnu-objcopy -O binary hack.elf hack.bin

cp ./base.md hack.md
chmod a+w ./hack.md

symbols=$(m68k-linux-gnu-nm ./hack.o | sort)
PREV_SRC_ADDR=""
PREV_SRC_LABEL=""
mode=1
while IFS= read -r line; do
    # Process each line as needed
    read -r address t name <<< "$line"

    if [[ "$name" == PATCH_BEGIN_* ]]
    then
        if [ $mode -ne 1 ]
        then
            echo "ERROR: unexpected $name"
            exit 1
        fi
        mode=0
        PREV_SRC_ADDR="$address"
        PREV_SRC_LABEL="$name"
    elif [[ "$name" == PATCH_END_* ]]
    then
        if [ $mode -ne 0 ]
        then
            exit 1
        else
            mode=1
            if [[ "${PREV_SRC_LABEL#PATCH_BEGIN_}" != "${name#PATCH_END_}" ]]
            then
                echo "mismatch: $address / $PREV_SRC_ADDR"
                exit 1
            fi
            
            count=$(( 0x$address - 0x$PREV_SRC_ADDR ))
            srcdec=$(( 0x$PREV_SRC_ADDR ))
            echo "copying ${name#PATCH_END_} -- range $PREV_SRC_ADDR..$address ($srcdec : $count bytes)"
            dd if="./hack.bin" of="./hack.md" bs=1 skip=$srcdec seek=$srcdec count=$count conv=notrunc
            
            PREV_SRC_ADDR="$address"
            PREV_SRC_LABEL="$name"
        fi
    fi
done <<< "$symbols"

python3 ./sega_genesis_checksum_utility.py ./hack.md

./flips/flips-linux -c ./base.md ./hack.md ./hack.ips
