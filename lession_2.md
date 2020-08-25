## 上期工作
1. 配置一套可持续运行的稳定环境 配置文件 config
2. 配置标签的启动流程
3. 创建存储 和 日志
4. 配置 prometheus 监控： http://192.168.199.123:9090/targets 
5. 项目部署简介： https://www.cnblogs.com/chenqionghe/p/10494868.html

## 课程 2
1. 启动服务  
```
# 启动 pd  
nohup ~/tidb/pd/bin/pd-server -config ~/tidb/config/pd_config.toml &  
tail -f ~/tidb/logs/pd/log.log  
# tikv  
nohup ~/tidb/tikv/target/release/tikv-server --config ~/tidb/config/tikv_config_20161.toml &  
tail -f ~/tidb/logs/tikv/20161.log  
nohup ~/tidb/tikv/target/release/tikv-server --config ~/tidb/config/tikv_config_20162.toml &  
tail -f ~/tidb/logs/tikv/20162.log  
nohup ~/tidb/tikv/target/release/tikv-server --config ~/tidb/config/tikv_config_20163.toml &  
tail -f ~/tidb/logs/tikv/20163.log  
 # tidb  
nohup ~/tidb/tidb/bin/tidb-server --config ~/tidb/config/tidb_config.toml &  
tail -f ~/tidb/logs/tidb/tidb.log  
```
2. tidb status and mertics report   
http://192.168.199.123:10080/  

3. TiDB Dashboard  
http://192.168.199.123:2379/dashboard/#/overview  
![image](https://github.com/dsseter/learn_tidb/raw/master/images/dashboard.png)
4. 创建数据库  
```
$ create database benchmark;
$ Query OK, 0 rows affected (0.17 sec)
```