qemu-system-x86_64 \
    -m 2048 -smp 4 -cpu host -machine type=q35,accel=hvf     \
    -drive file=/path/to/your/iso                         \
    -netdev user,id=net0,hostfwd=tcp::22222-:22         \
    -device virtio-net-pci,netdev=net0