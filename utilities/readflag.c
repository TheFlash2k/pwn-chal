// gcc -o readflag readflag.c -static

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char* argv[], char* envp[]) {

    char* uid_str = getenv("UID_READFLAG");
    char* gid_str = getenv("GID_READFLAG");
    char* flag_file = getenv("FLAG_FILE");

    int uid = (uid_str == NULL) ? 0 : atoi(uid_str);
    int gid = (gid_str == NULL) ? 0 : atoi(gid_str);

    setresuid(uid, uid, uid);
    setregid(gid, gid);

    FILE* f = fopen(flag_file, "r");
    if (f == NULL) {
        fprintf(stderr, "[ERROR] - Please contact an administrator. %s failed at trying to open the flag file: %s.", argv[0], flag_file);
	    fprintf(stderr, "[ERROR] - uid: %d, gid: %d\n", uid, gid);
        return 1;
    }
    char flag[100];
    if (fgets(flag, sizeof(flag), f) == NULL) {
        fprintf(stderr, "[ERROR] - Please contact an administrator. %s failed at trying to read the flag file: %s.", argv[0], flag_file);
	    fprintf(stderr, "[ERROR] - uid: %d, gid: %d\n", uid, gid);
        fclose(f);
        return 1;
    }
    fclose(f);
    printf("%s\n", flag);
}
