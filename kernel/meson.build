KERNEL_CC_FLAGS = [CC_FLAGS]
KERNEL_AS_FLAGS = AS_FLAGS
KERNEL_LD_FLAGS = [LD_FLAGS]
KERNEL_CPP_FLAGS = [] #[
  # '-D__is_kernel',
  # '-I'+'@SOURCE_ROOT@/kernel/include',
  # '-isystem='+INCLUDEDIR,
  # '-I'+INCLUDEDIR]

LIBS = []
headers = []

subdir(ARCHDIR)

KERNEL_CC_FLAGS += KERNEL_ARCH_CC_FLAGS
KERNEL_AS_FLAGS += KERNEL_ARCH_AS_FLAGS
KERNEL_LD_FLAGS += KERNEL_ARCH_LD_FLAGS
KERNEL_CPP_FLAGS += KERNEL_ARCH_CPP_FLAGS
LIBS += KERNEL_ARCH_LIBS

CC_KOBJ = [
  CC,
  KERNEL_CC_FLAGS,
  KERNEL_CPP_FLAGS,
  '-c','-o','@OUTPUT@','@INPUT@']

AS_KOBJ = [
  AS,
  KERNEL_AS_FLAGS,
  '-o','@OUTPUT@','@INPUT@']

KOBJS = ARCH_KOBJS+[
  custom_target(
    'main.c.o',
    input:'kernel/main.c',
    output:'main.c.o',
    command:CC_KOBJ),
  custom_target(
    'stdio.c.o',
    input:'kernel/stdio.c',
    output:'stdio.c.o',
    command:CC_KOBJ),]

LINK_LIST = [KERNEL_LD_FLAGS,crti,KOBJS,LIBS,crtn]
LD_KERNEL = [CC,'-Wl,-z,max-page-size=0x1000','-T'+LD_SCRIPT.full_path(),KERNEL_CC_FLAGS,'-o','@OUTPUT@',LINK_LIST]
