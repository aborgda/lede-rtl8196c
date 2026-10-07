#!/usr/bin/env python3
import struct
import sys

FLASH_SIZE = 0x02000000
KERNEL_BURN = 0x00031000
ROOTFS_HDR = 0x001fdc12
KERNEL_START = 0x81000000
ROOTFS_START = 0x000f0000
ROOTFS_BURN = 0x00210000

def checksum_payload(data):
    if len(data) & 1:
        data += b"\xff"
    total = 0
    for off in range(0, len(data), 2):
        total = (total + struct.unpack(">H", data[off:off + 2])[0]) & 0xffff
    data += struct.pack(">H", (-total) & 0xffff)
    return data

def block(sig, start, burn, data):
    payload = checksum_payload(data)
    return struct.pack(">4sIII", sig, start, burn, len(payload)) + payload

def main():
    if len(sys.argv) != 4:
        raise SystemExit("usage: sk337-pack.py <kernel> <rootfs> <output>")
    kernel_path, rootfs_path, output_path = sys.argv[1:]
    kernel = open(kernel_path, "rb").read()
    rootfs = open(rootfs_path, "rb").read()
    kernel_block = block(b"cr6c", KERNEL_START, KERNEL_BURN, kernel)
    rootfs_block = block(b"r6cr", ROOTFS_START, ROOTFS_BURN, rootfs)
    if KERNEL_BURN + len(kernel_block) > ROOTFS_HDR:
        raise SystemExit("SK337 kernel overlaps rootfs header")
    if ROOTFS_HDR + len(rootfs_block) > FLASH_SIZE:
        raise SystemExit("SK337 rootfs does not fit in 32MiB flash")
    image = bytearray(b"\xff" * FLASH_SIZE)
    image[KERNEL_BURN:KERNEL_BURN + len(kernel_block)] = kernel_block
    image[ROOTFS_HDR:ROOTFS_HDR + len(rootfs_block)] = rootfs_block
    with open(output_path, "wb") as f:
        f.write(image)

if __name__ == "__main__":
    main()
