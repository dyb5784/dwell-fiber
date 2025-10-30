#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <fcntl.h>

int main(int argc, char **argv) {
    long iters = 100000;
    if (argc > 1) iters = atol(argv[1]);
    struct timespec t1, t2;
    int fd = open("/dev/null", O_WRONLY);
    if (fd < 0) { perror("open"); return 2; }
    clock_gettime(CLOCK_MONOTONIC, &t1);
    for (long i = 0; i < iters; ++i) {
        write(fd, "x", 1);
    }
    clock_gettime(CLOCK_MONOTONIC, &t2);
    close(fd);
    double secs = (t2.tv_sec - t1.tv_sec) + (t2.tv_nsec - t1.tv_nsec) / 1e9;
    printf("iters=%ld time=%f sec total, avg ns/op=%f\n", iters, secs, (secs * 1e9) / iters);
    return 0;
}
