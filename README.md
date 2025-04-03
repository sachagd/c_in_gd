Dependencies :
  - ocamllex and menhir
  - yojson (opam install yojson)
  - dune
  - gcc
  - spwn

This project is still in development !

To use the project, first build it using : dune build 

Then, write some code in main.c and compile it using the following command : 

gcc -fno-stack-protector -fno-asynchronous-unwind-tables -fomit-frame-pointer -fcf-protection=none -m32 -S main.c

Then use this command : dune exec bin/main.exe

And finally use this command : spwn build main.spwn --allow readfile
