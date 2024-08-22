#!/bin/bash
qemu-system-x86_64                  \
	-m 8G                           \
	-cpu qemu64,+ssse3,+sse4.1,+sse4.2,+x2apic                   \
	--enable-kvm                    \
	-net user,hostfwd=tcp::2222-:22 \
	-net nic                        \
	-hda "/path/to/your/iso "
