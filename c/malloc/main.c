/* 
 * main.c
 *
 *
 *
 *
 */

void print_string (char **);

int
main (int argc, char **argv) {
  
}

void
print_string (char **str) {
  int i;

  for ( i=0 ; i<=strlen(str) ; ++i ) {
    printf("%c", str[i]);
  }
}
