- 自动切换IP脚本
 1. 安装依赖nmap nscd curl```apt install -y nmap nscd curl or yum install -y nmap nscd curl```
 2. 下载并修改  ```wget -O ip-gfw.sh https://raw.githubusercontent.com/gtgc2005/your/main/Hinet/ip-gfw.sh && chmod +x ip-gfw.sh```
 3. nano 按照內文指示修改
 4. 加入crontab运行监测时间，不要低于30分钟。  
```crontab -e```  
```*/30 * * * * /root/pqsapi.sh```


- 自动监测Netflix解锁并切换IP脚本

1. 下载脚本```wget -O ip-netflix.sh https://raw.githubusercontent.com/gtgc2005/your/main/Hinet/ip-netflix.sh && chmod +x ip-netflix.sh```

2. 修改ip-netflix.sh```nano ip-netflix.sh```  

3. 根据提示修改以下内容，其中TG机器人可以不填，但换IP后就不会提醒了  

&ensp;&ensp; NAME=自己定义，例如Hinet,注意保留引号``` NAME="Hinet"```  
&ensp;&ensp; API=你更换IP的链接，每家不一样，自己替换，注意保留引号``` API="htts://"```  
&ensp;&ensp; TG_BOT_TOKEN=自行前往@Botfather获取,默认null ```TG_BOT_TOKEN=null```  
&ensp;&ensp; TG_CHATID=与机器人@userinfobot 对话,默认null ```TG_CHATID=null``` 

4. 运行脚本一次

&ensp; ```./ip-netflix.sh```

5. 设为定时任务 输入 crontab -e 然后会弹出 nano 编辑界面，在文件里面添加一行：  

&ensp; ```*/10 * * * * /root/ip-netflix.sh >/dev/null 2>&1```
