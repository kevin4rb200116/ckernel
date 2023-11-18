# Proyecto de Kernel de Sistema Operativo

Este es un proyecto de kernel de sistema operativo creado como hobby. El kernel está programado en Net Wide Assembler (NASM) y en C para la arquitectura x86. Utiliza el sistema de construcción Meson y Ninja para facilitar el proceso de desarrollo. Para las pruebas, se utiliza GRUB como cargador de arranque y QEMU como máquina virtual. El entorno de desarrollo y prueba debe ser Linux.

## Requisitos

Asegúrate de tener los siguientes programas instalados en tu sistema:

- NASM
- Tar
- dd
- mke2fs
- grub-file
- i686-linux-gnu-ld
- i686-linux-gnu-ar
- i686-linux-gnu-gcc
- qemu-system-i386
- qemu-system-x86_64

## Pasos de Construcción

En la terminal, ejecuta el siguiente comando para configurar el proyecto:

```bash
$ meson setup --buildtype debug debug
```

Esto detectará si los programas necesarios están disponibles en el sistema.

Una vez configurado el proyecto, puedes construirlo y probarlo con el siguiente comando:

```bash
$ ninja -C debug test
```

Este comando generará automáticamente el archivo debug/kernel.elf y la imagen de sistema arrancable debug/system.hdd. Puedes probar la imagen en QEMU, VirtualBox o incluso en una computadora física (aunque esto último no es recomendable).

Adicionalmente, puedes especificar opciones como ARCH, ARCH_ABI, BOOTDIR, CCFLAGS y SYSROOT. Por ejemplo:

```bash
$ meson setup -DARCH_ABI=x64 --buildtype debug debug
```
