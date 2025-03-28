#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
    // 获取环境变量的值
    const char *env_var = getenv("BANFIC_PATH");
    if (env_var == NULL) {
        fprintf(stderr, "Environment variable PATH is not set.\n");
        return 1;
    }

    printf("The value of PATH is: %s\n", env_var);

    // 创建一个缓冲区来存储完整的命令字符串
    char command[1024];
    snprintf(command, sizeof(command), "echo $BANFIC_PATH");

    // 调用 system() 函数执行命令
    int result = system(command);

    // 检查命令是否成功执行
    if (result == -1) {
        perror("system");
        return 1;
    }

    return 0;
}