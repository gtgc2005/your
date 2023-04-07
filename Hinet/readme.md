- 自动切换IP脚本
 1. 安装依赖nmap nscd curl：apt install -y nmap nscd curl or yum install -y nmap nscd curl
 2. 下载并修改  chmod +x
 3. nano 按照內文指示修改
 4. 加入crontab运行监测时间，不要低于30分钟。  
crontab -e  
*/30 * * * * /root/pqsapi.sh
