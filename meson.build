project('hello_kernel',
  version : '0.1',
  default_options: [
    'prefix=/usr',
    'libdir=/usr/lib',
    'includedir=/usr/include'])

ARCH = get_option('ARCH')
ARCH_ABI = get_option('ARCH_ABI')

AS = find_program('nasm')

TAR = find_program('tar')
DD = find_program('dd')
MKFS = find_program('mke2fs','/sbin/mke2fs','/usr/sbin/mke2fs')
GRUB_FILE = find_program('grub-file')

if ARCH == 'x86'
  if ARCH_ABI == 'x64'
    LD = find_program('x86_64-linux-gnu-ld')
    AR = find_program('x86_64-linux-gnu-ar')
    CC = find_program('x86_64-linux-gnu-gcc')

    QEMU = find_program('qemu-system-x86_64')
  else
    LD = find_program('i686-linux-gnu-ld')
    AR = find_program('i686-linux-gnu-ar')
    CC = find_program('i686-linux-gnu-gcc')

    QEMU = find_program('qemu-system-i386')
  endif
endif

SYSROOT = '@PRIVATE_DIR@'+get_option('SYSROOT')
PREFIX = SYSROOT+'/'+get_option('prefix')
LIBDIR = SYSROOT+'/'+get_option('libdir')
INCLUDEDIR = SYSROOT+'/usr/include'
BOOTDIR = SYSROOT+'/'+get_option('BOOTDIR')
ARCHDIR = 'arch/'+ARCH

CC_FLAGS = get_option('CCFLAGS')+[
  '-nostdlib',
  '-nostdinc',
  '-nostartfiles',
  '-static',
  '-mtune=generic',
  '-mcmodel=kernel',
  '-fno-pic',
  '-ffreestanding',
  '-fno-exceptions',
  '-fno-builtin',
  '-fno-stack-protector',
  '-mno-red-zone',
  '-mno-sse',
  '-mno-sse2',
  '-mno-sse3',
  '-mno-3dnow',
  '-mno-mmx',
  '-Wall',
  '-Wextra',
  '-Wno-unused-parameter']
AS_FLAGS = ['-Ox','-g']
LD_FLAGS = [
  '-z', 'max-page-size=0x1000']

subdir('kernel')

kernel = custom_target(
  'kernel.elf',
  depends: [KOBJS,LD_SCRIPT],
  output: 'kernel.elf',
  command: LD_KERNEL)

system_image = custom_target(
  'system.hdd',
  input: [
    'grub.tar.bz2',
    kernel,
    'grub.cfg'
  ],
  output: 'system.hdd',
  command: [
    'mkdir','-p','@PRIVATE_DIR@','&&',
    TAR,'-m','-C','@PRIVATE_DIR@','-xf','@INPUT0@','&&',
    'mkdir', '-p', SYSROOT, '&&',
    'cp','-r','@PRIVATE_DIR@/root_tree/boot',SYSROOT,'&&',
    'cp','@INPUT1@',SYSROOT+'/boot/kernel','&&',
    'cp','@INPUT2@',SYSROOT+'/boot/grub','&&',
    DD,'status=none','bs=1','count=0','seek=16MiB','if=/dev/null','of=@PRIVATE_DIR@/boot.mbr','&&',
    'mv', '@PRIVATE_DIR@/boot.mbr', '@OUTPUT@', '&&',
    MKFS, '-q', '-F',
      '-T', 'ext4',
      '-E', 'offset=1048576',
      '-L', 'system',
      '-d', SYSROOT,
      '@OUTPUT@', '15360', '&&',
    'touch', '@OUTPUT@'
  ])

test(
  'multiboot2 header',
  GRUB_FILE,
  args: ['--is-x86-multiboot2',kernel.full_path()],
  depends: kernel)

test(
  'system image',
  QEMU,
  args: ['-m','64','-machine','q35','-smp','2',
    '-drive','file='+system_image.full_path()+',format=raw'],
  depends: system_image)