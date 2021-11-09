```
mkdir /docker/xmrig
wget -P /docker/xmrig/ https://github.com/snowdream/docker-xmr/blob/master/config.json
```

编辑配置文件 /docker/xmrig/config.json，修改以下内容

```bash
"url": "mine.c3pool.com:13333",
"user": "钱包地址",
"pass": "矿机名:邮箱",
```

例如：

```bash
            "url": "mine.c3pool.com:13333",
            "user": "48EbfP8rGZEUfWt6oui1P6dFHtkhkk91iCYGNHNX1mH88rkd7SMromV76EsTRSEtHC1J2BrkXbw9h5hAqhBkDiLWVaL3mjK",
            "pass": "rig01:rig01@gmail.com",
```

运行docker

`docker run --restart=always --network host -d -v /docker/xmrig/config.json:/etc/xmrig/config.json -e CPU_USAGE=50 --name xmr snowdream/xmr`

注释：第四步 “ CPU_USAGE=50” 为CPU占用调整
