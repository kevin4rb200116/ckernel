
if ARCH_ABI == 'x64'
  KERNEL_ARCH_CC_FLAGS=['-m64','-march=x86-64']
  KERNEL_ARCH_AS_FLAGS=['-felf64']
  KERNEL_ARCH_LD_FLAGS=['-Wl,-melf_x86_64']
  KERNEL_ARCH_CPP_FLAGS=['-D__x86_64__']
else
  KERNEL_ARCH_CC_FLAGS=['-m32','-march=i686']
  KERNEL_ARCH_AS_FLAGS=['-felf32']
  KERNEL_ARCH_LD_FLAGS=['-Wl,-melf_i386']
  KERNEL_ARCH_CPP_FLAGS=['-D__i386__']
endif

KERNEL_ARCH_LIBS=[]

CC_ARCH_KOBJ = [
  CC,
  KERNEL_CC_FLAGS,
  KERNEL_ARCH_CC_FLAGS,
  KERNEL_CPP_FLAGS,
  KERNEL_ARCH_CPP_FLAGS,
  '-c','-o','@OUTPUT@','@INPUT@']

AS_ARCH_KOBJ = [
  AS,
  KERNEL_AS_FLAGS,
  KERNEL_ARCH_AS_FLAGS,
  '-o','@OUTPUT@','@INPUT@']

ARCH_KOBJS = [
  custom_target(
    'header.asm.o',
    input:'header.asm',
    output:'header.asm.o',
    command:AS_ARCH_KOBJ),
  custom_target(
    'boot.asm.o',
    input:ARCH_ABI+'/boot.asm',
    output:'boot.asm.o',
    command:AS_ARCH_KOBJ),
  custom_target(
    'puts.asm.o',
    input:'puts.asm',
    output:'puts.asm.o',
    command:AS_ARCH_KOBJ),
  custom_target(
    'tty.c.o',
    input:'tty.c',
    output:'tty.c.o',
    command:CC_ARCH_KOBJ)]

crti = custom_target(
  'crti.asm.o',
  input:ARCH_ABI+'/crti.asm',
  output:'crti.asm.o',
  command:AS_ARCH_KOBJ)

crtn = custom_target(
  'crtn.asm.o',
  input:ARCH_ABI+'/crtn.asm',
  output:'crtn.asm.o',
  command:AS_ARCH_KOBJ)

LD_SCRIPT = custom_target(
  'kernel.lds',
  input:ARCH_ABI+'/kernel.lds',
  output:'kernel.lds',
  command:['cp','@INPUT@','@OUTPUT@'])