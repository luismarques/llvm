# RUN: llvm-mc %s -triple riscv64 -mattr=+c -riscv-no-aliases -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK-ASM,CHECK-ASM-AND-OBJ %s

# CHECK-ASM-AND-OBJ: c.slli  zero, 63
# CHECK-ASM: encoding: [0x7e,0x10]
c.slli x0, 63
