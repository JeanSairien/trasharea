/*
 * Small C program to read tar header. 
 * Copyright (c) 2013, Niamkik
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *  
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * The views and conclusions contained in the software and documentation are
 * those of the authors and should not be interpreted as representing official
 * policies, either expressed or implied, of the FreeBSD Project.
 *
 * Some information about tar on:
 * -> https://www.gnu.org/software/tar/manual/html_node/Standard.html .
 * 
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

/*
 * Main function 
 */
int
main (int argc, char **argv) 
{
  int ret, c;
  void *ptr;
  FILE *file;

  char name[101];               /*   0 */
  char mode[9];                 /* 100 */
  char uid[9];                  /* 108 */
  char gid[8];                  /* 116 */
  char size[13];                /* 124 */
  char mtime[13];               /* 136 */
  char chksum[9];               /* 148 */
  char typeflag;                /* 156 */
  char linkname[101];           /* 157 */
  char magic[7];                /* 257 */
  char version[3];              /* 263 */
  char uname[33];               /* 265 */
  char gname[33];               /* 297 */
  char devmajor[9];             /* 329 */
  char devminor[9];             /* 337 */
  char prefix[156];             /* 345 */

  /* Return error if no target tar file */
  if ( argc > 1 )
    file = fopen(argv[1], "r");
  else {
    printf("Give me an argument. \n");
    exit(1);
  }

  /* Let's gow, parse the header.*/
  int i=0;
  while ( i<100 ) {
    c=getc(file);
    name[i]=c;
    i++;
  }
  name[100]='\0';

  i=0;
  while ( i<8 ) {
    c=getc(file);
    mode[i]=c;
    i++;
  }
  mode[8]='\0'; 

  i=0;
  while (i<8) {
    c=getc(file);
    uid[i]=c;
    i++;
  }
  uid[8]='\0';

  i=0;
  while (i<8) {
    c=getc(file);
    gid[i]=c;
    i++;
  }
  gid[8]='\0';

  i=0;
  while (i<12) {
    c=getc(file);
    size[i]=c;
    i++;
  }
  size[12]='\0';

  i=0;
  while (i<12) {
    c=getc(file);
    mtime[i]=c;
    i++;
  }
  mtime[12]='\0';

  i=0;
  while (i<8) {
    c=getc(file);
    chksum[i]=c;
    i++;
  }
  chksum[8]='\0';

  c=getc(file);
  typeflag=c;
  
  i=0;
  while (i<100) {
    c=getc(file);
    linkname[i]=c;
    i++;
  }
  linkname[100]='\0';

  i=0;
  while (i<6) {
    c=getc(file);
    magic[i]=c;
    i++;
  }
  magic[6]='\0';

  i=0;
  while (i<2) {
    c=getc(file);
    version[i]=c;
    i++;
  }
  version[2]='\0';

  i=0;
  while (i<32) {
    c=getc(file);
    uname[i]=c;
    i++;
  }
  uname[32]='\0';

  i=0;
  while (i<32) {
    c=getc(file);
    gname[i]=c;
    i++;
  }
  gname[32]='\0';

  i=0;
  while (i<8) {
    c=getc(file);
    devmajor[i]=c;
    i++;
  }
  devmajor[8]='\0';

  i=0;
  while (i<8) {
    c=getc(file);
    devminor[i]=c;
    i++;
  }
  devminor[8]='\0';

  i=0;
  while (i<155) {
    c=getc(file);
    prefix[i]=c;
    i++;
  }
  prefix[155]='\0';

  ret = fclose(file);
  if ( ret < 0 ) {
    printf("error: file cannot close.\n");
    exit(1);
  }

  /* Print information get with the header */
  printf("name:     %s\n", name);
  printf("mode:     %s\n", mode);
  printf("uid:      %s\n", uid);
  printf("gid:      %s\n", gid);
  printf("size:     %s\n", size);
  printf("mtime:    %s\n", mtime);
  printf("typeflag: %d\n", typeflag);
  printf("linkname: %s\n", linkname);
  printf("magic:    %s\n", magic);
  printf("version:  %s\n", version);
  printf("uname:    %s\n", uname);
  printf("gname:    %s\n", gname);
  printf("devmajor: %s\n", devmajor);
  printf("devminor: %s\n", devminor);
  printf("prefix:   ");
  for ( i=1 ; i<=155 ; i++ ){
    printf("%x", prefix[i]);
    if ( (i%40)==0 )
      printf("\n          ");
  }
  printf("\n");  
}
