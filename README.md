# Linux 平台自动构建说明

因为 Linux 发行版众多，手工逐个测试相当麻烦，所以我们使用 Docker 验证各发行版的编译情况。

这个仓库包含：
- 若干发行版配置好环境的 Dockerfile ，用于构建编译镜像
- 编译 dandelion-dev 的脚本
- 一键执行脚本

构建前应确保本机已经安装了 Python 3 和 Docker ，最好能够以非 root 身份执行 Docker 命令。首次构建前，请先克隆 dandelion-dev 仓库，之后执行 `build_all.py` 即可构建。

```shell
$ git clone https://github.com/XJTU-Graphics/dandelion-dev
$ python build_all.py
```

构建完毕后，所有的输出都会被存放在 *logs* 目录下，日志文件命名规则为 *[distro name]-[config].log* ，例如 *ubuntu-22.04-debug.log* 就表示 Ubuntu 22.04 下 Debug 模式编译的输出。
