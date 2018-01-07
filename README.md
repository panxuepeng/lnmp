
目前仅用于安装 LNMP 开发环境。

## 配置

- _options.conf 设置安装目录等
- _version.conf 设置软件版本号


## 安装过程

### 1.系统初始化

以阿里云服务器为例，执行 `bash os_init/init_aliyun.sh`, 安装常用依赖包，设置必要的服务和时区。

### 2.如果是PHP Web 服务器

安装常用的PHP依赖包，执行 `bash install_php_require.sh`

### 3.安装Nginx, PHP 等

将 script 目录下的脚本软连或复制到 script.run 目录下，执行 `bash install.sh`



