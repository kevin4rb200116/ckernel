#include "tty.h"
#include "io.h"

enum TTYConstants {
  TTY_SCREEN_WIDTH = 80,
  TTY_SCREEN_HEIGHT = 25,
  TTY_DEFAULT_COLOR = 0x7,
  TTY_MEMORY_ADDRESS = 0xB8000,
};

struct {
  char* buffer;
  int xpos;
  int ypos;
} tty = {
  .buffer=(char*) TTY_MEMORY_ADDRESS,
  .xpos=0,
  .ypos=0
};

inline void putchar(
    int x,
    int y,
    char c) {
  tty.buffer[2 * (y * TTY_SCREEN_WIDTH + x)] = c;
}

inline void putcolor(
    int x,
    int y,
    char color) {
  tty.buffer[2 * (y * TTY_SCREEN_WIDTH + x) + 1] = color;
}

inline char getchar(
    int x, 
    int y) {
  return tty.buffer[2 * (y * TTY_SCREEN_WIDTH + x)];
}

inline char getcolor(
    int x, 
    int y) {
  return tty.buffer[2 * (y * TTY_SCREEN_WIDTH + x) + 1];
}

inline void setcursor(
    int x,
    int y) {
  int pos = y * TTY_SCREEN_WIDTH + x;

  outb(0x3D4, 0x0F);
  outb(0x3D5, (char)(pos & 0xFF));
  outb(0x3D4, 0x0E);
  outb(0x3D5, (char)((pos >> 8) & 0xFF));
}

void clrscr() {
  for (int y=0; y<TTY_SCREEN_HEIGHT; y++) {
    for (int x=0; x<TTY_SCREEN_WIDTH; x++) {
      putchar(x,y,'\0');
      putcolor(x,y,TTY_DEFAULT_COLOR);
    }
  }

  tty.xpos=0;
  tty.ypos=0;

  setcursor(tty.xpos,tty.ypos);
}

void scrollback(int lines) {
  for (int y = lines; y < TTY_SCREEN_HEIGHT; y++) {
    for (int x = 0; x < TTY_SCREEN_WIDTH; x++) {
      putchar(x, y - lines, getchar(x, y));
      putcolor(x, y - lines, getcolor(x, y));
    }
  }

  for (
    int y=TTY_SCREEN_HEIGHT-lines;
      y < TTY_SCREEN_HEIGHT; y++) {
    for (int x = 0; x < TTY_SCREEN_WIDTH; x++) {
      putchar(x, y, '\0');
      putcolor(x, y, TTY_DEFAULT_COLOR);
    }
  }

  tty.ypos -= lines;
}

void putc(char c) {
  switch (c) {
    case '\n':
      tty.xpos = 0;
      tty.ypos++;
      break;

    case '\t':
      for (int i = 0; i < 4 - (tty.xpos % 4); i++)
        putc(' ');
      break;

    case '\r':
      tty.xpos = 0;
      break;

    default:
      putchar(tty.xpos, tty.ypos, c);
      tty.xpos++;
      break;
  }

  if (tty.xpos >= TTY_SCREEN_WIDTH) {
      tty.ypos++;
      tty.xpos = 0;
  }

  if (tty.ypos >= TTY_SCREEN_HEIGHT)
      scrollback(1);

  setcursor(tty.xpos, tty.ypos);
}

void puts(const char* str) {
  while(*str) {
    putc(*str);
    str++;
  }

  setcursor(tty.xpos, tty.ypos);
}
