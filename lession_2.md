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
5. 安装 sysbench 
```
curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | sudo bash
sudo apt -y install sysbench
```
6. 创建数据库 & 准备
```
mysql> create database benchmark;
Query OK, 0 rows affected (0.17 sec)

mysql> create database sbtest;
Query OK, 0 rows affected (0.16 sec)

mysql> set global tidb_disable_txn_auto_retry = off;
Query OK, 0 rows affected (0.05 sec)

mysql> set global tidb_txn_mode ="optimistic";
Query OK, 0 rows affected (0.02 sec)
```
```
// sysbench 配置 
mysql-user=root
mysql-port=4000
mysql-host=127.0.0.1
mysql-db=sbtest
threads=10
verbosity=5
db-driver=mysql
report-interval=10
```
7. 准备数据
```
 sysbench --config-file=/home/dsseter/tidb/config/sysbench_config.conf oltp_point_select --threads=20 --tables=32 --table-size=10000 prepare
 sysbench 1.0.20 (using bundled LuaJIT 2.1.0-beta2)

Initializing worker threads...

Creating table 'sbtest10'...
Creating table 'sbtest9'...
Creating table 'sbtest1'...
Creating table 'sbtest20'...
Creating table 'sbtest2'...
Creating table 'sbtest13'...
Creating table 'sbtest17'...
Creating table 'sbtest5'...
Creating table 'sbtest18'...
Creating table 'sbtest3'...
Creating table 'sbtest12'...
Creating table 'sbtest6'...
Creating table 'sbtest16'...
Creating table 'sbtest7'...
Creating table 'sbtest19'...
Creating table 'sbtest11'...
Creating table 'sbtest8'...
Creating table 'sbtest15'...
Creating table 'sbtest14'...
Creating table 'sbtest4'...
Inserting 10000 records into 'sbtest10'
Inserting 10000 records into 'sbtest16'
Creating a secondary index on 'sbtest10'...
Creating a secondary index on 'sbtest16'...
```
```
// 准备好的数据
mysql> select * from sbtest1 limit 10;
+--------+--------+-------------------------------------------------------------------------------------------------------------------------+-------------------------------------------------------------+
| id     | k      | c                                                                                                                       | pad                                                         |
+--------+--------+-------------------------------------------------------------------------------------------------------------------------+-------------------------------------------------------------+
| 410871 | 410385 | 84280795968-80942340894-28441323423-66752125475-93420982443-06966332892-45001864538-41710134382-32911234714-40521461997 | 27688336338-01334003912-18967036152-13311693631-95836411165 |
| 410872 | 453704 | 72286193508-35706766202-73918116535-53876520700-44235964795-86102980535-88450716621-38770803116-65136542452-10264052354 | 96808357022-72438510892-22930127844-17533405812-03999453957 |
| 410873 | 444129 | 25649444090-23592562990-67288102624-83291578367-01795384297-51826437483-80786325738-59456367690-90332187283-45075688053 | 95511599329-75800140038-09814341730-49444255027-03770814939 |
| 410874 | 502809 | 27067948361-40432608690-72262774881-52658242560-88282414834-83127339666-16310936240-13028548852-47933343293-83034484300 | 16558698441-46938141286-37975410123-66158312999-94636291624 |
| 410875 | 504271 | 26413603757-41658891042-26070777944-26831582019-48063260868-43590915889-77106592499-51586246763-97582556493-27327505069 | 29872624053-86518667603-07565241323-75463756282-40602135877 |
| 410876 | 504758 | 55962479525-55366526422-84673559369-07580944106-19944947447-96542897831-45452187958-10445230250-28550664628-01250908423 | 90435266621-57564950985-78728447563-26053956195-78234629602 |
| 410877 | 500865 | 68583932702-43207100060-93843063832-42675508484-30794912829-54879879661-79647863294-04192535360-88978024097-55638958012 | 95378553578-55969689808-34059648333-94823383530-61973178632 |
| 410878 | 504984 | 59238380458-60345446542-49781514301-84662389258-59633054126-20967321981-02506433691-14937080642-08196180953-43161022352 | 97958147732-46071052218-07000923932-37265103504-30757725531 |
| 410879 | 500405 | 61407796996-75327026779-83837973343-86028281863-74803489749-47383166462-81681457975-94515993912-38802067664-77912595693 | 94753380060-68088116172-08091856291-15306101423-56837780738 |
| 410880 | 499727 | 62623243021-07902658557-45314957556-86851313634-56818330722-40556888524-12430854188-82821123033-48905532837-08693182083 | 80471347486-36960994303-65133435103-25782663960-58389101568 |
+--------+--------+-------------------------------------------------------------------------------------------------------------------------+-------------------------------------------------------------+
10 rows in set (0.01 sec)
```

8. 执行 sysbench select
```
// 单线程
 sysbench --config-file=/home/dsseter/tidb/config/sysbench_config.conf oltp_point_select  --tables=32 --table-size=10000 run
SQL statistics:
    queries performed:
        read:                            220244
        write:                           0
        other:                           0
        total:                           220244
    transactions:                        220244 (22014.02 per sec.)
    queries:                             220244 (22014.02 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          10.0027s
    total number of events:              220244

Latency (ms):
         min:                                    0.20
         avg:                                    0.45
         max:                                   15.37
         95th percentile:                        1.06
         sum:                                99798.46

Threads fairness:
    events (avg/stddev):           22024.4000/67.24
    execution time (avg/stddev):   9.9798/0.00
```
```
// 12 线程
sysbench --config-file=/home/dsseter/tidb/config/sysbench_config.conf oltp_point_select  --threads=12 --tables=32 --table-size=10000 run
SQL statistics:
    queries performed:
        read:                            256686
        write:                           0
        other:                           0
        total:                           256686
    transactions:                        256686 (25656.10 per sec.)
    queries:                             256686 (25656.10 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          10.0027s
    total number of events:              256686

Latency (ms):
         min:                                    0.20
         avg:                                    0.47
         max:                                   68.25
         95th percentile:                        1.10
         sum:                               119776.82

Threads fairness:
    events (avg/stddev):           21390.5000/99.74
    execution time (avg/stddev):   9.9814/0.00
```

9. 执行 sysbench select
```
// 12 线程
sysbench --config-file=/home/dsseter/tidb/config/sysbench_config.conf oltp_update_index  --threads=12 --tables=32 --table-size=10000 run


SQL statistics:
    queries performed:
        read:                            0
        write:                           770
        other:                           0
        total:                           770
    transactions:                        770    (75.70 per sec.)
    queries:                             770    (75.70 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          10.1676s
    total number of events:              770

Latency (ms):
         min:                                  101.81
         avg:                                  156.93
         max:                                  303.94
         95th percentile:                      211.60
         sum:                               120835.84

Threads fairness:
    events (avg/stddev):           64.1667/1.14
    execution time (avg/stddev):   10.0697/0.05
```

10. go-ycsb 安装，编译
```
git clone git@github.com:pingcap/go-ycsb.git
make
```
11. go-ycsb 准备数据
```
// load
 ~/tidb/bin/go-ycsb/bin/go-ycsb load mysql -P /home/dsseter/tidb/bin/go-ycsb/workloads/workloada -p recordcount=100000 -p mysql.host=127.0.0.1 -p mysql.port=4000 --threads=16
 ~/tidb/bin/go-ycsb/bin/go-ycsb load mysql -P /home/dsseter/tidb/bin/go-ycsb/workloads/workloada -p recordcount=100000 -p mysql.host=127.0.0.1 -p mysql.port=4000 --threads=16
***************** properties *****************
"recordcount"="100000"
"workload"="core"
"mysql.port"="4000"
"readallfields"="true"
"updateproportion"="0.5"
"requestdistribution"="uniform"
"mysql.host"="127.0.0.1"
"dotransactions"="false"
"scanproportion"="0"
"threadcount"="16"
"readproportion"="0.5"
"insertproportion"="0"
"operationcount"="1000"
**********************************************


// run
 ~/tidb/bin/go-ycsb/bin/go-ycsb load mysql -P /home/dsseter/tidb/bin/go-ycsb/workloads/workloada -p operationcount=100000 -p mysql.host=127.0.0.1 -p mysql.port=4000 --threads=16
// 负载类型
workloada ~ workloadf
```

12. go-tpc  安装，编译
```
git@github.com:pingcap/go-tpc.git
 make build
```
13. go-tpc 准备数据，压测
```
//load 
~/tidb/bin/go-tpc/bin/go-tpc tpcc -H 127.0.0.1 -P 4000 -D tpcc --warehouses 20 prepare

// run 
~/tidb/bin/go-tpc/bin/go-tpc tpcc -H 127.0.0.1 -P 4000 -D tpcc --warehouses 20 run
```



ps: 
```
drop table 时异常
[2020/08/25 17:52:09.765 +00:00] [INFO] [lock_resolver.go:602] ["resolveLock rollback"] [lock="key: {tableID=55, handle=258121}, primary: {tableID=55, indexID=1, indexValues={158407, 742759, }}, txnStartTS: 419005138124668930, lockForUpdateTS:0, ttl: 53110, type: Del"]
[2020/08/25 17:52:09.809 +00:00] [WARN] [2pc.go:1006] ["schemaLeaseChecker is not set for this transaction, schema check skipped"] [connID=0] [startTS=419005184002490369] [commitTS=419005184028704769]
[2020/08/25 17:52:09.828 +00:00] [INFO] [lock_resolver.go:602] ["resolveLock rollback"] [lock="key: {tableID=55, handle=1944}, primary: {tableID=55, indexID=1, indexValues={158407, 742759, }}, txnStartTS: 419005138124668930, lockForUpdateTS:0, ttl: 53110, type: Del"]
[2020/08/25 17:52:09.843 +00:00] [INFO] [lock_resolver.go:602] ["resolveLock rollback"] [lock="key: {tableID=55, handle=258122}, primary: {tableID=55, indexID=1, indexValues={158407, 742759, }}, txnStartTS: 419005138124668930, lockForUpdateTS:0, ttl: 53110, type: Del"]
[2020/08/25 17:52:09.871 +00:00] [WARN] [2pc.go:1006] ["schemaLeaseChecker is not set for this transaction, schema check skipped"] [connID=0] [startTS=419005184015597569] [commitTS=419005184041811969]
```

```
    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
  11365 dsseter   25   5 3068368 207700  54992 S 126.2   0.6   9:18.31 tidb-server
  11148 dsseter   25   5 2524940 567320  27844 S  28.8   1.7   2:52.91 tikv-server
  10677 dsseter   25   5   11.8g 122332  54064 S   9.9   0.4   1:48.10 pd-server
  15585 dsseter   20   0 2733704  30788  22140 S   8.9   0.1   0:06.76 go-ycsb
  10713 dsseter   25   5 2572540 577804  28632 S   7.0   1.8   2:40.91 tikv-server
  10931 dsseter   25   5 2517260 558332  27748 S   6.6   1.7   2:12.75 tikv-server
  ```