#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <math.h>

void randomIp (void);

int 
main (void) 
{
  printf ("test\n");
  randomIp();
}

void
test ( int target, int *ipv4 ) 
{
  int mask[4] = { 0xff, 0xff00, 0xff0000, 0xff000000 };
  int i;

  if ( target > 0xffffffff )
    printf("error\n");

  else {
    for ( i=0 ; i<=3 ; i++ ) {
      if ( i<3 )
	ipv4[i] = ( (target & mask[i]) >> i*8 );
      else if ( i == 3 ) 
	ipv4[i] = ((target & mask[i]) >> i*8) & mask[0];
    }
  }
}

double 
mult ( int base, int exp ) {
  int i;
  int buf = 1;
  for ( i=1 ; i<exp ; i++)
    buf = buf*base;
  return buf;
}

void
randomIp (void)
{
  int ipv4[4];
  int mask = 0xffffffff;
  int i;
  unsigned int exp;

  for ( i=32 ; i>=0 ; i-- ) {
    test(mask<<i, ipv4);
    exp = (int) pow(2, 3)-2;
    printf("mask - %x - /%d - %d.%d.%d.%d - %d\n", 
	   mask<<i, -(i-32), 
	   ipv4[3], ipv4[2], ipv4[1], ipv4[0],
	   (int) mult(2, i)-2);
  }
}
