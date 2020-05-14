# nginx-ssl-replace

在根目录下创建你的 HOST 为名的目录。即 `ssh user@host` 中的 host 的部分.

然后在该目录， 创建一个 `meta.data` 的文件。 参考 `www.company.com` 目录的文件内容。 该目录的内容， 都是相对于远程服务器而言的。

然后将 ssl 相关的文件放在这个目录里。其中

`*.crt, *.pem` 后缀的文件， 会同步到 `CRT_NAME` 配置属性的远程文件
`*.key` 后缀的文件， 会同步到 `CRT_KEY` 配置属性的远程文件

# 同步并切换

`./sync-ssl.sh www.company.com`

