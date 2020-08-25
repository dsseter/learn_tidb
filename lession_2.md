## 上期工作
1. 配置一套可持续运行的稳定环境 配置文件 config
2. 配置标签的启动流程
3. 创建存储 和 日志
4. 配置 prometheus 监控： http://192.168.199.123:9090/targets 
5. 项目部署简介： https://www.cnblogs.com/chenqionghe/p/10494868.html

## 课程 2
#### PS: 服务拓扑未使用 TiUP部署，采用的是手动部署方案， 故 DashBoard 的监控数据中没有 QPS等信息。 
机器配置 & 部署  
CPU: Intel(R) Xeon(R) CPU E5-2678 v3 @ 2.50GHz, 24核  
Memory: DDR4 32GB  
磁盘： 512GB nvme SSD   
实例： * 1  
拓扑：PD * 1 & TiKV * 3 & TiDB * 1, 单机部署  

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
INSERT - Takes(s): 749.7, Count: 100000, OPS: 133.4, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 759.7, Count: 100000, OPS: 131.6, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 769.7, Count: 100000, OPS: 129.9, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 779.7, Count: 100000, OPS: 128.3, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 789.7, Count: 100000, OPS: 126.6, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 799.7, Count: 100000, OPS: 125.0, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 809.7, Count: 100000, OPS: 123.5, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 819.7, Count: 100000, OPS: 122.0, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 829.7, Count: 100000, OPS: 120.5, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 839.7, Count: 100000, OPS: 119.1, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 849.7, Count: 100000, OPS: 117.7, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 859.7, Count: 100000, OPS: 116.3, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 869.7, Count: 100000, OPS: 115.0, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 879.7, Count: 100000, OPS: 113.7, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 889.7, Count: 100000, OPS: 112.4, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 899.7, Count: 100000, OPS: 111.1, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 909.7, Count: 100000, OPS: 109.9, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 919.7, Count: 100000, OPS: 108.7, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 929.7, Count: 100000, OPS: 107.6, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 939.7, Count: 100000, OPS: 106.4, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 949.7, Count: 100000, OPS: 105.3, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 959.7, Count: 100000, OPS: 104.2, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 969.7, Count: 100000, OPS: 103.1, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
INSERT - Takes(s): 979.7, Count: 100000, OPS: 102.1, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000
Run finished, takes 16m23.374483022s
INSERT - Takes(s): 983.1, Count: 100000, OPS: 101.7, Avg(us): 108663, Min(us): 38290, Max(us): 859518, 99th(us): 156000, 99.9th(us): 296000, 99.99th(us): 669000

// run workloada 6 线程
~/tidb/bin/go-ycsb/bin/go-ycsb run mysql -P /home/dsseter/tidb/bin/go-ycsb/workloads/workloada -p operationcount=10000 -p mysql.host=127.0.0.1 -p mysql.port=4000 --threads=6
***************** properties *****************
"threadcount"="6"
"operationcount"="10000"
"insertproportion"="0"
"workload"="core"
"scanproportion"="0"
"recordcount"="1000"
"readproportion"="0.5"
"requestdistribution"="uniform"
"mysql.host"="127.0.0.1"
"mysql.port"="4000"
"dotransactions"="true"
"updateproportion"="0.5"
"readallfields"="true"
**********************************************
READ   - Takes(s): 9.9, Count: 470, OPS: 47.3, Avg(us): 2416, Min(us): 723, Max(us): 61782, 99th(us): 19000, 99.9th(us): 62000, 99.99th(us): 62000
UPDATE - Takes(s): 9.8, Count: 440, OPS: 44.8, Avg(us): 132979, Min(us): 68796, Max(us): 394758, 99th(us): 222000, 99.9th(us): 395000, 99.99th(us): 395000
READ   - Takes(s): 19.9, Count: 907, OPS: 45.5, Avg(us): 2188, Min(us): 719, Max(us): 61782, 99th(us): 17000, 99.9th(us): 62000, 99.99th(us): 62000
UPDATE - Takes(s): 19.8, Count: 869, OPS: 43.9, Avg(us): 135219, Min(us): 68796, Max(us): 394758, 99th(us): 262000, 99.9th(us): 395000, 99.99th(us): 395000
READ   - Takes(s): 29.9, Count: 1283, OPS: 42.9, Avg(us): 2110, Min(us): 719, Max(us): 61782, 99th(us): 15000, 99.9th(us): 58000, 99.99th(us): 62000
UPDATE - Takes(s): 29.8, Count: 1266, OPS: 42.5, Avg(us): 138992, Min(us): 68796, Max(us): 394758, 99th(us): 308000, 99.9th(us): 368000, 99.99th(us): 395000
READ   - Takes(s): 39.9, Count: 1779, OPS: 44.5, Avg(us): 2076, Min(us): 719, Max(us): 61782, 99th(us): 9000, 99.9th(us): 58000, 99.99th(us): 62000
UPDATE - Takes(s): 39.8, Count: 1744, OPS: 43.8, Avg(us): 135060, Min(us): 68796, Max(us): 394758, 99th(us): 279000, 99.9th(us): 342000, 99.99th(us): 342000
READ   - Takes(s): 49.9, Count: 2266, OPS: 45.4, Avg(us): 2089, Min(us): 719, Max(us): 61782, 99th(us): 13000, 99.9th(us): 57000, 99.99th(us): 62000
UPDATE - Takes(s): 49.8, Count: 2213, OPS: 44.4, Avg(us): 133202, Min(us): 68796, Max(us): 394758, 99th(us): 285000, 99.9th(us): 387000, 99.99th(us): 395000
READ   - Takes(s): 59.9, Count: 2753, OPS: 45.9, Avg(us): 2077, Min(us): 719, Max(us): 61782, 99th(us): 9000, 99.9th(us): 57000, 99.99th(us): 62000
UPDATE - Takes(s): 59.8, Count: 2660, OPS: 44.5, Avg(us): 133099, Min(us): 68796, Max(us): 399182, 99th(us): 283000, 99.9th(us): 392000, 99.99th(us): 400000
READ   - Takes(s): 69.9, Count: 3196, OPS: 45.7, Avg(us): 2086, Min(us): 719, Max(us): 61782, 99th(us): 11000, 99.9th(us): 34000, 99.99th(us): 62000
UPDATE - Takes(s): 69.8, Count: 3116, OPS: 44.6, Avg(us): 132424, Min(us): 68796, Max(us): 399182, 99th(us): 262000, 99.9th(us): 387000, 99.99th(us): 400000
READ   - Takes(s): 79.9, Count: 3648, OPS: 45.6, Avg(us): 2100, Min(us): 719, Max(us): 61782, 99th(us): 10000, 99.9th(us): 20000, 99.99th(us): 21000
UPDATE - Takes(s): 79.8, Count: 3573, OPS: 44.8, Avg(us): 132126, Min(us): 68796, Max(us): 449939, 99th(us): 257000, 99.9th(us): 395000, 99.99th(us): 450000
READ   - Takes(s): 89.9, Count: 4105, OPS: 45.6, Avg(us): 2095, Min(us): 719, Max(us): 61782, 99th(us): 12000, 99.9th(us): 22000, 99.99th(us): 62000
UPDATE - Takes(s): 89.8, Count: 4013, OPS: 44.7, Avg(us): 132265, Min(us): 68796, Max(us): 449939, 99th(us): 255000, 99.9th(us): 395000, 99.99th(us): 450000
READ   - Takes(s): 99.9, Count: 4570, OPS: 45.7, Avg(us): 2110, Min(us): 719, Max(us): 61782, 99th(us): 13000, 99.9th(us): 34000, 99.99th(us): 62000
UPDATE - Takes(s): 99.8, Count: 4448, OPS: 44.6, Avg(us): 132596, Min(us): 68796, Max(us): 449939, 99th(us): 254000, 99.9th(us): 401000, 99.99th(us): 450000
READ   - Takes(s): 109.9, Count: 4989, OPS: 45.4, Avg(us): 2120, Min(us): 719, Max(us): 61782, 99th(us): 15000, 99.9th(us): 57000, 99.99th(us): 62000
UPDATE - Takes(s): 109.8, Count: 4858, OPS: 44.2, Avg(us): 133195, Min(us): 68796, Max(us): 449939, 99th(us): 271000, 99.9th(us): 401000, 99.99th(us): 450000
Run finished, takes 1m53.828975425s
READ   - Takes(s): 113.8, Count: 5059, OPS: 44.5, Avg(us): 2117, Min(us): 719, Max(us): 61782, 99th(us): 15000, 99.9th(us): 34000, 99.99th(us): 62000
UPDATE - Takes(s): 113.6, Count: 4937, OPS: 43.4, Avg(us): 132911, Min(us): 68796, Max(us): 449939, 99th(us): 270000, 99.9th(us): 401000, 99.99th(us): 450000

// run workloadd 6线程
~/tidb/bin/go-ycsb/bin/go-ycsb run mysql -P /home/dsseter/tidb/bin/go-ycsb/workloads/workloadd -p operationcount=10000 -p mysql.host=127.0.0.1 -p mysql.port=4000 --threads=6
***************** properties *****************
"readallfields"="true"
"readproportion"="0.95"
"mysql.host"="127.0.0.1"
"threadcount"="6"
"operationcount"="10000"
"mysql.port"="4000"
"dotransactions"="true"
"recordcount"="1000"
"updateproportion"="0"
"insertproportion"="0.05"
"requestdistribution"="latest"
"workload"="core"
"scanproportion"="0"
**********************************************
Run finished, takes 3.282844009s
INSERT - Takes(s): 2.6, Count: 527, OPS: 200.0, Avg(us): 1828, Min(us): 1111, Max(us): 15392, 99th(us): 5000, 99.9th(us): 16000, 99.99th(us): 16000
READ   - Takes(s): 2.8, Count: 9469, OPS: 3399.5, Avg(us): 1861, Min(us): 638, Max(us): 758045, 99th(us): 6000, 99.9th(us): 144000, 99.99th(us): 759000

// run workloadf 12线程
 ~/tidb/bin/go-ycsb/bin/go-ycsb run mysql -P /home/dsseter/tidb/bin/go-ycsb/workloads/workloadf -p operationcount=30000 -p mysql.host=127.0.0.1 -p mysql.port=4000 --threads=12
***************** properties *****************
"requestdistribution"="uniform"
"updateproportion"="0"
"mysql.port"="4000"
"readproportion"="0.5"
"insertproportion"="0"
"workload"="core"
"operationcount"="30000"
"threadcount"="12"
"recordcount"="1000"
"readallfields"="true"
"scanproportion"="0"
"dotransactions"="true"
"readmodifywriteproportion"="0.5"
"mysql.host"="127.0.0.1"
**********************************************
READ   - Takes(s): 9.9, Count: 1655, OPS: 166.6, Avg(us): 3225, Min(us): 741, Max(us): 72136, 99th(us): 57000, 99.9th(us): 72000, 99.99th(us): 73000
READ_MODIFY_WRITE - Takes(s): 9.8, Count: 822, OPS: 83.6, Avg(us): 142174, Min(us): 94505, Max(us): 436462, 99th(us): 207000, 99.9th(us): 437000, 99.99th(us): 437000
UPDATE - Takes(s): 9.8, Count: 822, OPS: 83.6, Avg(us): 138819, Min(us): 92853, Max(us): 434647, 99th(us): 204000, 99.9th(us): 435000, 99.99th(us): 435000
READ   - Takes(s): 19.9, Count: 3257, OPS: 163.4, Avg(us): 2906, Min(us): 729, Max(us): 72136, 99th(us): 19000, 99.9th(us): 66000, 99.99th(us): 73000
READ_MODIFY_WRITE - Takes(s): 19.8, Count: 1619, OPS: 81.6, Avg(us): 144974, Min(us): 72087, Max(us): 436462, 99th(us): 296000, 99.9th(us): 402000, 99.99th(us): 437000
UPDATE - Takes(s): 19.8, Count: 1619, OPS: 81.6, Avg(us): 141992, Min(us): 71223, Max(us): 434647, 99th(us): 293000, 99.9th(us): 399000, 99.99th(us): 435000
READ   - Takes(s): 29.9, Count: 4822, OPS: 161.1, Avg(us): 2889, Min(us): 686, Max(us): 72136, 99th(us): 19000, 99.9th(us): 66000, 99.99th(us): 73000
READ_MODIFY_WRITE - Takes(s): 29.8, Count: 2440, OPS: 81.8, Avg(us): 144644, Min(us): 72087, Max(us): 552738, 99th(us): 294000, 99.9th(us): 402000, 99.99th(us): 553000
UPDATE - Takes(s): 29.8, Count: 2440, OPS: 81.8, Avg(us): 141680, Min(us): 71223, Max(us): 551419, 99th(us): 292000, 99.9th(us): 399000, 99.99th(us): 552000
READ   - Takes(s): 39.9, Count: 6534, OPS: 163.6, Avg(us): 2845, Min(us): 686, Max(us): 84471, 99th(us): 20000, 99.9th(us): 66000, 99.99th(us): 85000
READ_MODIFY_WRITE - Takes(s): 39.8, Count: 3311, OPS: 83.1, Avg(us): 141902, Min(us): 72087, Max(us): 552738, 99th(us): 272000, 99.9th(us): 402000, 99.99th(us): 553000
UPDATE - Takes(s): 39.8, Count: 3311, OPS: 83.1, Avg(us): 138989, Min(us): 71223, Max(us): 551419, 99th(us): 271000, 99.9th(us): 399000, 99.99th(us): 552000
READ   - Takes(s): 49.9, Count: 8283, OPS: 165.9, Avg(us): 2811, Min(us): 686, Max(us): 90022, 99th(us): 20000, 99.9th(us): 70000, 99.99th(us): 91000
READ_MODIFY_WRITE - Takes(s): 49.8, Count: 4181, OPS: 83.9, Avg(us): 140508, Min(us): 72087, Max(us): 552738, 99th(us): 258000, 99.9th(us): 401000, 99.99th(us): 553000
UPDATE - Takes(s): 49.8, Count: 4181, OPS: 83.9, Avg(us): 137675, Min(us): 71223, Max(us): 551419, 99th(us): 256000, 99.9th(us): 399000, 99.99th(us): 552000
READ   - Takes(s): 59.9, Count: 10026, OPS: 167.3, Avg(us): 2792, Min(us): 652, Max(us): 90022, 99th(us): 20000, 99.9th(us): 70000, 99.99th(us): 85000
READ_MODIFY_WRITE - Takes(s): 59.8, Count: 5043, OPS: 84.3, Avg(us): 139720, Min(us): 72087, Max(us): 552738, 99th(us): 255000, 99.9th(us): 408000, 99.99th(us): 553000
UPDATE - Takes(s): 59.8, Count: 5043, OPS: 84.3, Avg(us): 136928, Min(us): 71223, Max(us): 551419, 99th(us): 254000, 99.9th(us): 404000, 99.99th(us): 552000
READ   - Takes(s): 69.9, Count: 11710, OPS: 167.4, Avg(us): 2740, Min(us): 652, Max(us): 90022, 99th(us): 19000, 99.9th(us): 70000, 99.99th(us): 85000
READ_MODIFY_WRITE - Takes(s): 69.8, Count: 5883, OPS: 84.2, Avg(us): 139749, Min(us): 72087, Max(us): 552738, 99th(us): 246000, 99.9th(us): 411000, 99.99th(us): 553000
UPDATE - Takes(s): 69.8, Count: 5883, OPS: 84.2, Avg(us): 136997, Min(us): 71223, Max(us): 551419, 99th(us): 243000, 99.9th(us): 409000, 99.99th(us): 552000
READ   - Takes(s): 79.9, Count: 13428, OPS: 168.0, Avg(us): 2703, Min(us): 652, Max(us): 90022, 99th(us): 19000, 99.9th(us): 69000, 99.99th(us): 85000
READ_MODIFY_WRITE - Takes(s): 79.8, Count: 6713, OPS: 84.1, Avg(us): 140118, Min(us): 72087, Max(us): 552738, 99th(us): 246000, 99.9th(us): 448000, 99.99th(us): 553000
UPDATE - Takes(s): 79.8, Count: 6713, OPS: 84.1, Avg(us): 137419, Min(us): 71223, Max(us): 551419, 99th(us): 243000, 99.9th(us): 446000, 99.99th(us): 552000
READ   - Takes(s): 89.9, Count: 15166, OPS: 168.6, Avg(us): 2676, Min(us): 627, Max(us): 90022, 99th(us): 18000, 99.9th(us): 69000, 99.99th(us): 85000
READ_MODIFY_WRITE - Takes(s): 89.8, Count: 7556, OPS: 84.1, Avg(us): 140076, Min(us): 72087, Max(us): 552738, 99th(us): 244000, 99.9th(us): 438000, 99.99th(us): 553000
UPDATE - Takes(s): 89.8, Count: 7556, OPS: 84.1, Avg(us): 137402, Min(us): 71223, Max(us): 551419, 99th(us): 241000, 99.9th(us): 436000, 99.99th(us): 552000
READ   - Takes(s): 99.9, Count: 16731, OPS: 167.4, Avg(us): 2647, Min(us): 627, Max(us): 106940, 99th(us): 18000, 99.9th(us): 70000, 99.99th(us): 85000
READ_MODIFY_WRITE - Takes(s): 99.8, Count: 8357, OPS: 83.7, Avg(us): 140835, Min(us): 72087, Max(us): 552738, 99th(us): 257000, 99.9th(us): 449000, 99.99th(us): 553000
UPDATE - Takes(s): 99.8, Count: 8357, OPS: 83.7, Avg(us): 138186, Min(us): 71223, Max(us): 551419, 99th(us): 256000, 99.9th(us): 447000, 99.99th(us): 552000
READ   - Takes(s): 109.9, Count: 18360, OPS: 167.0, Avg(us): 2651, Min(us): 627, Max(us): 106940, 99th(us): 18000, 99.9th(us): 70000, 99.99th(us): 91000
READ_MODIFY_WRITE - Takes(s): 109.8, Count: 9161, OPS: 83.4, Avg(us): 141341, Min(us): 72087, Max(us): 593731, 99th(us): 259000, 99.9th(us): 586000, 99.99th(us): 594000
UPDATE - Takes(s): 109.8, Count: 9161, OPS: 83.4, Avg(us): 138689, Min(us): 71223, Max(us): 591008, 99th(us): 257000, 99.9th(us): 585000, 99.99th(us): 592000
READ   - Takes(s): 119.9, Count: 20051, OPS: 167.2, Avg(us): 2660, Min(us): 627, Max(us): 106940, 99th(us): 18000, 99.9th(us): 69000, 99.99th(us): 84000
READ_MODIFY_WRITE - Takes(s): 119.8, Count: 10002, OPS: 83.5, Avg(us): 141194, Min(us): 72087, Max(us): 593731, 99th(us): 278000, 99.9th(us): 557000, 99.99th(us): 594000
UPDATE - Takes(s): 119.8, Count: 10002, OPS: 83.5, Avg(us): 138544, Min(us): 71223, Max(us): 591008, 99th(us): 276000, 99.9th(us): 555000, 99.99th(us): 591000
READ   - Takes(s): 129.9, Count: 21630, OPS: 166.5, Avg(us): 2666, Min(us): 627, Max(us): 106940, 99th(us): 18000, 99.9th(us): 72000, 99.99th(us): 102000
READ_MODIFY_WRITE - Takes(s): 129.8, Count: 10743, OPS: 82.7, Avg(us): 142388, Min(us): 72087, Max(us): 593731, 99th(us): 284000, 99.9th(us): 557000, 99.99th(us): 594000
UPDATE - Takes(s): 129.8, Count: 10743, OPS: 82.7, Avg(us): 139708, Min(us): 71223, Max(us): 591008, 99th(us): 282000, 99.9th(us): 555000, 99.99th(us): 591000
READ   - Takes(s): 139.9, Count: 23313, OPS: 166.6, Avg(us): 2656, Min(us): 627, Max(us): 106940, 99th(us): 19000, 99.9th(us): 71000, 99.99th(us): 102000
READ_MODIFY_WRITE - Takes(s): 139.8, Count: 11577, OPS: 82.8, Avg(us): 142312, Min(us): 72087, Max(us): 593731, 99th(us): 284000, 99.9th(us): 557000, 99.99th(us): 594000
UPDATE - Takes(s): 139.8, Count: 11577, OPS: 82.8, Avg(us): 139637, Min(us): 71223, Max(us): 591008, 99th(us): 282000, 99.9th(us): 555000, 99.99th(us): 591000
READ   - Takes(s): 149.9, Count: 24955, OPS: 166.4, Avg(us): 2639, Min(us): 627, Max(us): 106940, 99th(us): 18000, 99.9th(us): 71000, 99.99th(us): 102000
READ_MODIFY_WRITE - Takes(s): 149.8, Count: 12375, OPS: 82.6, Avg(us): 142689, Min(us): 72087, Max(us): 593731, 99th(us): 282000, 99.9th(us): 553000, 99.99th(us): 594000
UPDATE - Takes(s): 149.8, Count: 12375, OPS: 82.6, Avg(us): 140038, Min(us): 71223, Max(us): 591008, 99th(us): 280000, 99.9th(us): 552000, 99.99th(us): 591000
READ   - Takes(s): 159.9, Count: 26459, OPS: 165.4, Avg(us): 2638, Min(us): 627, Max(us): 106940, 99th(us): 19000, 99.9th(us): 71000, 99.99th(us): 102000
READ_MODIFY_WRITE - Takes(s): 159.8, Count: 13148, OPS: 82.3, Avg(us): 143283, Min(us): 72087, Max(us): 593731, 99th(us): 282000, 99.9th(us): 505000, 99.99th(us): 594000
UPDATE - Takes(s): 159.8, Count: 13148, OPS: 82.3, Avg(us): 140628, Min(us): 71223, Max(us): 591008, 99th(us): 279000, 99.9th(us): 503000, 99.99th(us): 591000
READ   - Takes(s): 169.9, Count: 28089, OPS: 165.3, Avg(us): 2643, Min(us): 627, Max(us): 106940, 99th(us): 19000, 99.9th(us): 71000, 99.99th(us): 102000
READ_MODIFY_WRITE - Takes(s): 169.8, Count: 13964, OPS: 82.2, Avg(us): 143322, Min(us): 72087, Max(us): 593731, 99th(us): 281000, 99.9th(us): 505000, 99.99th(us): 594000
UPDATE - Takes(s): 169.8, Count: 13964, OPS: 82.2, Avg(us): 140662, Min(us): 71223, Max(us): 591008, 99th(us): 278000, 99.9th(us): 503000, 99.99th(us): 591000
READ   - Takes(s): 179.9, Count: 29548, OPS: 164.2, Avg(us): 2662, Min(us): 627, Max(us): 106940, 99th(us): 19000, 99.9th(us): 71000, 99.99th(us): 102000
READ_MODIFY_WRITE - Takes(s): 179.8, Count: 14728, OPS: 81.9, Avg(us): 143078, Min(us): 72087, Max(us): 593731, 99th(us): 270000, 99.9th(us): 505000, 99.99th(us): 594000
UPDATE - Takes(s): 179.8, Count: 14728, OPS: 81.9, Avg(us): 140390, Min(us): 71223, Max(us): 591008, 99th(us): 267000, 99.9th(us): 503000, 99.99th(us): 591000
READ   - Takes(s): 189.9, Count: 29990, OPS: 157.9, Avg(us): 2655, Min(us): 627, Max(us): 106940, 99th(us): 19000, 99.9th(us): 71000, 99.99th(us): 102000
READ_MODIFY_WRITE - Takes(s): 189.8, Count: 14954, OPS: 78.8, Avg(us): 143096, Min(us): 72087, Max(us): 593731, 99th(us): 270000, 99.9th(us): 487000, 99.99th(us): 594000
UPDATE - Takes(s): 189.8, Count: 14955, OPS: 78.8, Avg(us): 140413, Min(us): 71223, Max(us): 591008, 99th(us): 271000, 99.9th(us): 503000, 99.99th(us): 591000
Run finished, takes 3m10.418348092s
READ   - Takes(s): 190.4, Count: 30000, OPS: 157.6, Avg(us): 2655, Min(us): 627, Max(us): 106940, 99th(us): 19000, 99.9th(us): 71000, 99.99th(us): 102000
READ_MODIFY_WRITE - Takes(s): 190.3, Count: 14958, OPS: 78.6, Avg(us): 143096, Min(us): 72087, Max(us): 593731, 99th(us): 272000, 99.9th(us): 505000, 99.99th(us): 594000
UPDATE - Takes(s): 190.3, Count: 14958, OPS: 78.6, Avg(us): 140411, Min(us): 71223, Max(us): 591008, 99th(us): 271000, 99.9th(us): 503000, 99.99th(us): 591000

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
creating table warehouse
creating table district
creating table customer
creating table history
creating table new_order
creating table orders
creating table order_line
creating table stock
creating table item
load to item


load to warehouse in warehouse 1
load to stock in warehouse 1
load to district in warehouse 1
load to warehouse in warehouse 2
load to stock in warehouse 2
load to district in warehouse 2
load to warehouse in warehouse 3
load to stock in warehouse 3
load to district in warehouse 3
load to warehouse in warehouse 4
load to stock in warehouse 4
load to district in warehouse 4
load to warehouse in warehouse 5
load to stock in warehouse 5
load to district in warehouse 5
...
begin to check warehouse 19 at condition 3.3.2.9
begin to check warehouse 19 at condition 3.3.2.10
begin to check warehouse 20 at condition 3.3.2.8
begin to check warehouse 20 at condition 3.3.2.9
begin to check warehouse 20 at condition 3.3.2.10
begin to check warehouse 20 at condition 3.3.2.3
begin to check warehouse 20 at condition 3.3.2.4
begin to check warehouse 20 at condition 3.3.2.7
begin to check warehouse 20 at condition 3.3.2.6
begin to check warehouse 20 at condition 3.3.2.11
begin to check warehouse 20 at condition 3.3.2.12
begin to check warehouse 20 at condition 3.3.2.1
begin to check warehouse 20 at condition 3.3.2.2
begin to check warehouse 20 at condition 3.3.2.5
Finished

// run 12线程
~/tidb/bin/go-tpc/bin/go-tpc tpcc -H 127.0.0.1 -P 4000 -D tpcc --warehouses 20 --time 1m  --threads=12 run
[Current] DELIVERY - Takes(s): 5.9, Count: 6, TPM: 60.7, Sum(ms): 13170, Avg(ms): 2195, 90th(ms): 4000, 99th(ms): 4000, 99.9th(ms): 4000
[Current] NEW_ORDER - Takes(s): 9.0, Count: 83, TPM: 556.1, Sum(ms): 54027, Avg(ms): 650, 90th(ms): 1000, 99th(ms): 1500, 99.9th(ms): 1500
[Current] ORDER_STATUS - Takes(s): 9.3, Count: 5, TPM: 32.4, Sum(ms): 435, Avg(ms): 87, 90th(ms): 160, 99th(ms): 160, 99.9th(ms): 160
[Current] PAYMENT - Takes(s): 9.4, Count: 82, TPM: 523.9, Sum(ms): 46625, Avg(ms): 568, 90th(ms): 1000, 99th(ms): 1500, 99.9th(ms): 1500
[Current] STOCK_LEVEL - Takes(s): 9.2, Count: 5, TPM: 32.5, Sum(ms): 515, Avg(ms): 103, 90th(ms): 160, 99th(ms): 160, 99.9th(ms): 160
[Current] DELIVERY - Takes(s): 8.7, Count: 8, TPM: 54.9, Sum(ms): 16562, Avg(ms): 2070, 90th(ms): 4000, 99th(ms): 4000, 99.9th(ms): 4000
[Current] NEW_ORDER - Takes(s): 9.8, Count: 89, TPM: 546.3, Sum(ms): 54793, Avg(ms): 615, 90th(ms): 1000, 99th(ms): 1500, 99.9th(ms): 1500
[Current] ORDER_STATUS - Takes(s): 7.3, Count: 5, TPM: 41.0, Sum(ms): 375, Avg(ms): 75, 90th(ms): 192, 99th(ms): 192, 99.9th(ms): 192
[Current] PAYMENT - Takes(s): 9.9, Count: 84, TPM: 506.7, Sum(ms): 48441, Avg(ms): 576, 90th(ms): 1000, 99th(ms): 1500, 99.9th(ms): 1500
[Current] STOCK_LEVEL - Takes(s): 8.9, Count: 5, TPM: 33.8, Sum(ms): 405, Avg(ms): 81, 90th(ms): 160, 99th(ms): 160, 99.9th(ms): 160
[Current] DELIVERY - Takes(s): 8.8, Count: 12, TPM: 81.7, Sum(ms): 26044, Avg(ms): 2170, 90th(ms): 4000, 99th(ms): 4000, 99.9th(ms): 4000
[Current] NEW_ORDER - Takes(s): 9.8, Count: 69, TPM: 421.2, Sum(ms): 42069, Avg(ms): 609, 90th(ms): 1000, 99th(ms): 1000, 99.9th(ms): 1000
[Current] ORDER_STATUS - Takes(s): 9.5, Count: 6, TPM: 37.8, Sum(ms): 229, Avg(ms): 38, 90th(ms): 64, 99th(ms): 64, 99.9th(ms): 64
[Current] PAYMENT - Takes(s): 9.9, Count: 89, TPM: 537.3, Sum(ms): 50576, Avg(ms): 568, 90th(ms): 1000, 99th(ms): 1500, 99.9th(ms): 1500
[Current] STOCK_LEVEL - Takes(s): 7.6, Count: 5, TPM: 39.4, Sum(ms): 240, Avg(ms): 48, 90th(ms): 64, 99th(ms): 64, 99.9th(ms): 64
[Current] DELIVERY - Takes(s): 8.4, Count: 9, TPM: 64.1, Sum(ms): 22681, Avg(ms): 2520, 90th(ms): 8000, 99th(ms): 8000, 99.9th(ms): 8000
[Current] NEW_ORDER - Takes(s): 9.9, Count: 73, TPM: 442.1, Sum(ms): 46760, Avg(ms): 640, 90th(ms): 1000, 99th(ms): 1500, 99.9th(ms): 1500
[Current] ORDER_STATUS - Takes(s): 7.8, Count: 8, TPM: 61.8, Sum(ms): 217, Avg(ms): 27, 90th(ms): 80, 99th(ms): 80, 99.9th(ms): 80
[Current] PAYMENT - Takes(s): 10.0, Count: 86, TPM: 516.8, Sum(ms): 49798, Avg(ms): 579, 90th(ms): 1000, 99th(ms): 1500, 99.9th(ms): 1500
[Current] STOCK_LEVEL - Takes(s): 9.1, Count: 4, TPM: 26.5, Sum(ms): 234, Avg(ms): 58, 90th(ms): 80, 99th(ms): 80, 99.9th(ms): 80
[Current] DELIVERY - Takes(s): 9.1, Count: 10, TPM: 66.2, Sum(ms): 20644, Avg(ms): 2064, 90th(ms): 4000, 99th(ms): 4000, 99.9th(ms): 4000
[Current] NEW_ORDER - Takes(s): 9.9, Count: 86, TPM: 522.3, Sum(ms): 54423, Avg(ms): 632, 90th(ms): 1000, 99th(ms): 1500, 99.9th(ms): 1500
[Current] ORDER_STATUS - Takes(s): 6.5, Count: 8, TPM: 73.5, Sum(ms): 215, Avg(ms): 26, 90th(ms): 64, 99th(ms): 64, 99.9th(ms): 64
[Current] PAYMENT - Takes(s): 9.9, Count: 76, TPM: 461.6, Sum(ms): 42669, Avg(ms): 561, 90th(ms): 1000, 99th(ms): 2000, 99.9th(ms): 2000
[Current] STOCK_LEVEL - Takes(s): 9.1, Count: 12, TPM: 79.0, Sum(ms): 760, Avg(ms): 63, 90th(ms): 128, 99th(ms): 160, 99.9th(ms): 160
[Current] DELIVERY - Takes(s): 9.8, Count: 9, TPM: 55.1, Sum(ms): 20056, Avg(ms): 2228, 90th(ms): 4000, 99th(ms): 4000, 99.9th(ms): 4000
[Current] NEW_ORDER - Takes(s): 9.8, Count: 93, TPM: 566.6, Sum(ms): 56865, Avg(ms): 611, 90th(ms): 1000, 99th(ms): 1000, 99.9th(ms): 1000
[Current] ORDER_STATUS - Takes(s): 9.3, Count: 7, TPM: 45.2, Sum(ms): 268, Avg(ms): 38, 90th(ms): 80, 99th(ms): 80, 99.9th(ms): 80
[Current] PAYMENT - Takes(s): 10.0, Count: 83, TPM: 499.5, Sum(ms): 44361, Avg(ms): 534, 90th(ms): 1000, 99th(ms): 1500, 99.9th(ms): 1500
[Current] STOCK_LEVEL - Takes(s): 9.9, Count: 9, TPM: 54.4, Sum(ms): 630, Avg(ms): 70, 90th(ms): 160, 99th(ms): 160, 99.9th(ms): 160
Finished
[Summary] DELIVERY - Takes(s): 56.1, Count: 54, TPM: 57.8, Sum(ms): 119157, Avg(ms): 2206, 90th(ms): 4000, 99th(ms): 8000, 99.9th(ms): 8000
[Summary] DELIVERY_ERR - Takes(s): 56.1, Count: 1, TPM: 1.1, Sum(ms): 623, Avg(ms): 623, 90th(ms): 1000, 99th(ms): 1000, 99.9th(ms): 1000
[Summary] NEW_ORDER - Takes(s): 59.1, Count: 494, TPM: 501.6, Sum(ms): 309550, Avg(ms): 626, 90th(ms): 1000, 99th(ms): 1500, 99.9th(ms): 1500
[Summary] NEW_ORDER_ERR - Takes(s): 59.1, Count: 4, TPM: 4.1, Sum(ms): 841, Avg(ms): 210, 90th(ms): 512, 99th(ms): 512, 99.9th(ms): 512
[Summary] ORDER_STATUS - Takes(s): 59.4, Count: 39, TPM: 39.4, Sum(ms): 1739, Avg(ms): 44, 90th(ms): 80, 99th(ms): 192, 99.9th(ms): 192
[Summary] PAYMENT - Takes(s): 59.5, Count: 502, TPM: 506.0, Sum(ms): 283401, Avg(ms): 564, 90th(ms): 1000, 99th(ms): 1500, 99.9th(ms): 2000
[Summary] PAYMENT_ERR - Takes(s): 59.5, Count: 4, TPM: 4.0, Sum(ms): 937, Avg(ms): 234, 90th(ms): 512, 99th(ms): 512, 99.9th(ms): 512
[Summary] STOCK_LEVEL - Takes(s): 59.4, Count: 40, TPM: 40.4, Sum(ms): 2784, Avg(ms): 69, 90th(ms): 160, 99th(ms): 160, 99.9th(ms): 160
tpmC: 501.6


// run 5 线程
~/tidb/bin/go-tpc/bin/go-tpc tpcc -H 127.0.0.1 -P 4000 -D tpcc --warehouses 20 --time 1m  --threads=5 run
[Current] DELIVERY - Takes(s): 1.2, Count: 1, TPM: 49.4, Sum(ms): 2253, Avg(ms): 2253, 90th(ms): 4000, 99th(ms): 4000, 99.9th(ms): 4000
[Current] NEW_ORDER - Takes(s): 9.2, Count: 45, TPM: 294.4, Sum(ms): 26163, Avg(ms): 581, 90th(ms): 1000, 99th(ms): 1000, 99.9th(ms): 1000
[Current] ORDER_STATUS - Takes(s): 7.1, Count: 4, TPM: 34.0, Sum(ms): 445, Avg(ms): 111, 90th(ms): 192, 99th(ms): 192, 99.9th(ms): 192
[Current] PAYMENT - Takes(s): 9.4, Count: 37, TPM: 235.6, Sum(ms): 17736, Avg(ms): 479, 90th(ms): 1000, 99th(ms): 1000, 99.9th(ms): 1000
[Current] STOCK_LEVEL - Takes(s): 9.8, Count: 6, TPM: 36.6, Sum(ms): 554, Avg(ms): 92, 90th(ms): 160, 99th(ms): 160, 99.9th(ms): 160
[Current] DELIVERY - Takes(s): 5.2, Count: 3, TPM: 34.5, Sum(ms): 6562, Avg(ms): 2187, 90th(ms): 4000, 99th(ms): 4000, 99.9th(ms): 4000
[Current] NEW_ORDER - Takes(s): 10.0, Count: 44, TPM: 264.4, Sum(ms): 24958, Avg(ms): 567, 90th(ms): 1000, 99th(ms): 1000, 99.9th(ms): 1000
[Current] ORDER_STATUS - Takes(s): 9.0, Count: 3, TPM: 20.0, Sum(ms): 185, Avg(ms): 61, 90th(ms): 112, 99th(ms): 112, 99.9th(ms): 112
[Current] PAYMENT - Takes(s): 9.6, Count: 40, TPM: 250.2, Sum(ms): 18574, Avg(ms): 464, 90th(ms): 1000, 99th(ms): 1000, 99.9th(ms): 1000
[Current] STOCK_LEVEL - Takes(s): 6.2, Count: 2, TPM: 19.4, Sum(ms): 175, Avg(ms): 87, 90th(ms): 112, 99th(ms): 112, 99.9th(ms): 112
[Current] DELIVERY - Takes(s): 6.0, Count: 4, TPM: 39.7, Sum(ms): 8071, Avg(ms): 2017, 90th(ms): 4000, 99th(ms): 4000, 99.9th(ms): 4000
[Current] NEW_ORDER - Takes(s): 9.9, Count: 36, TPM: 217.5, Sum(ms): 20014, Avg(ms): 555, 90th(ms): 1000, 99th(ms): 1000, 99.9th(ms): 1000
[Current] ORDER_STATUS - Takes(s): 9.5, Count: 4, TPM: 25.2, Sum(ms): 365, Avg(ms): 91, 90th(ms): 160, 99th(ms): 160, 99.9th(ms): 160
[Current] PAYMENT - Takes(s): 10.0, Count: 44, TPM: 264.0, Sum(ms): 21715, Avg(ms): 493, 90th(ms): 1000, 99th(ms): 1000, 99.9th(ms): 1000
[Current] STOCK_LEVEL - Takes(s): 9.8, Count: 2, TPM: 12.2, Sum(ms): 192, Avg(ms): 96, 90th(ms): 112, 99th(ms): 112, 99.9th(ms): 112
[Current] DELIVERY - Takes(s): 7.5, Count: 3, TPM: 24.0, Sum(ms): 6011, Avg(ms): 2003, 90th(ms): 4000, 99th(ms): 4000, 99.9th(ms): 4000
[Current] NEW_ORDER - Takes(s): 9.7, Count: 40, TPM: 248.4, Sum(ms): 22537, Avg(ms): 563, 90th(ms): 1000, 99th(ms): 1000, 99.9th(ms): 1000
[Current] ORDER_STATUS - Takes(s): 8.8, Count: 2, TPM: 13.6, Sum(ms): 82, Avg(ms): 41, 90th(ms): 64, 99th(ms): 64, 99.9th(ms): 64
[Current] PAYMENT - Takes(s): 9.9, Count: 44, TPM: 267.2, Sum(ms): 20570, Avg(ms): 467, 90th(ms): 1000, 99th(ms): 1000, 99.9th(ms): 1000
[Current] STOCK_LEVEL - Takes(s): 2.5, Count: 5, TPM: 118.9, Sum(ms): 411, Avg(ms): 82, 90th(ms): 160, 99th(ms): 160, 99.9th(ms): 160
[Current] DELIVERY - Takes(s): 5.3, Count: 4, TPM: 45.7, Sum(ms): 8818, Avg(ms): 2204, 90th(ms): 4000, 99th(ms): 4000, 99.9th(ms): 4000
[Current] NEW_ORDER - Takes(s): 9.8, Count: 36, TPM: 219.8, Sum(ms): 20063, Avg(ms): 557, 90th(ms): 1000, 99th(ms): 1000, 99.9th(ms): 1000
[Current] ORDER_STATUS - Takes(s): 7.8, Count: 3, TPM: 23.2, Sum(ms): 188, Avg(ms): 62, 90th(ms): 160, 99th(ms): 160, 99.9th(ms): 160
[Current] PAYMENT - Takes(s): 10.0, Count: 41, TPM: 246.4, Sum(ms): 20317, Avg(ms): 495, 90th(ms): 1000, 99th(ms): 1000, 99.9th(ms): 1000
[Current] STOCK_LEVEL - Takes(s): 9.3, Count: 3, TPM: 19.4, Sum(ms): 161, Avg(ms): 53, 90th(ms): 80, 99th(ms): 80, 99.9th(ms): 80
Finished
[Summary] DELIVERY - Takes(s): 51.4, Count: 18, TPM: 21.0, Sum(ms): 37280, Avg(ms): 2071, 90th(ms): 4000, 99th(ms): 4000, 99.9th(ms): 4000
[Summary] DELIVERY_ERR - Takes(s): 51.4, Count: 1, TPM: 1.2, Sum(ms): 314, Avg(ms): 314, 90th(ms): 512, 99th(ms): 512, 99.9th(ms): 512
[Summary] NEW_ORDER - Takes(s): 59.3, Count: 242, TPM: 244.8, Sum(ms): 136763, Avg(ms): 565, 90th(ms): 1000, 99th(ms): 1000, 99.9th(ms): 1000
[Summary] NEW_ORDER_ERR - Takes(s): 59.3, Count: 1, TPM: 1.0, Sum(ms): 32, Avg(ms): 32, 90th(ms): 32, 99th(ms): 32, 99.9th(ms): 32
[Summary] ORDER_STATUS - Takes(s): 57.2, Count: 21, TPM: 22.0, Sum(ms): 1630, Avg(ms): 77, 90th(ms): 160, 99th(ms): 192, 99.9th(ms): 192
[Summary] PAYMENT - Takes(s): 59.6, Count: 255, TPM: 256.8, Sum(ms): 121059, Avg(ms): 474, 90th(ms): 1000, 99th(ms): 1000, 99.9th(ms): 1000
[Summary] PAYMENT_ERR - Takes(s): 59.6, Count: 2, TPM: 2.0, Sum(ms): 450, Avg(ms): 225, 90th(ms): 256, 99th(ms): 256, 99.9th(ms): 256
[Summary] STOCK_LEVEL - Takes(s): 60.0, Count: 19, TPM: 19.0, Sum(ms): 1539, Avg(ms): 81, 90th(ms): 160, 99th(ms): 160, 99.9th(ms): 160
tpmC: 244.8


// 2线程
 tidb ~/tidb/bin/go-tpc/bin/go-tpc tpcc -H 127.0.0.1 -P 4000 -D tpcc --warehouses 20 --time 1m  --threads=2 run
[Current] DELIVERY - Takes(s): 2.5, Count: 1, TPM: 24.0, Sum(ms): 1598, Avg(ms): 1598, 90th(ms): 2000, 99th(ms): 2000, 99.9th(ms): 2000
[Current] NEW_ORDER - Takes(s): 9.4, Count: 21, TPM: 133.9, Sum(ms): 9968, Avg(ms): 474, 90th(ms): 1000, 99th(ms): 1000, 99.9th(ms): 1000
[Current] ORDER_STATUS - Takes(s): 6.2, Count: 1, TPM: 9.7, Sum(ms): 153, Avg(ms): 153, 90th(ms): 160, 99th(ms): 160, 99.9th(ms): 160
[Current] PAYMENT - Takes(s): 9.4, Count: 20, TPM: 127.0, Sum(ms): 7645, Avg(ms): 382, 90th(ms): 512, 99th(ms): 512, 99.9th(ms): 512
[Current] STOCK_LEVEL - Takes(s): 9.9, Count: 5, TPM: 30.3, Sum(ms): 315, Avg(ms): 63, 90th(ms): 112, 99th(ms): 112, 99.9th(ms): 112
[Current] NEW_ORDER - Takes(s): 9.6, Count: 26, TPM: 162.9, Sum(ms): 12785, Avg(ms): 491, 90th(ms): 1000, 99th(ms): 1000, 99.9th(ms): 1000
[Current] ORDER_STATUS - Takes(s): 3.2, Count: 3, TPM: 56.8, Sum(ms): 301, Avg(ms): 100, 90th(ms): 112, 99th(ms): 112, 99.9th(ms): 112
[Current] PAYMENT - Takes(s): 8.1, Count: 16, TPM: 118.4, Sum(ms): 6113, Avg(ms): 382, 90th(ms): 512, 99th(ms): 512, 99.9th(ms): 512
[Current] STOCK_LEVEL - Takes(s): 3.8, Count: 1, TPM: 16.0, Sum(ms): 86, Avg(ms): 86, 90th(ms): 96, 99th(ms): 96, 99.9th(ms): 96
[Current] DELIVERY - Takes(s): 9.2, Count: 5, TPM: 32.7, Sum(ms): 7770, Avg(ms): 1554, 90th(ms): 2000, 99th(ms): 2000, 99.9th(ms): 2000
[Current] NEW_ORDER - Takes(s): 9.7, Count: 17, TPM: 105.4, Sum(ms): 7309, Avg(ms): 429, 90th(ms): 512, 99th(ms): 512, 99.9th(ms): 512
[Current] ORDER_STATUS - Takes(s): 9.6, Count: 3, TPM: 18.8, Sum(ms): 297, Avg(ms): 99, 90th(ms): 160, 99th(ms): 160, 99.9th(ms): 160
[Current] PAYMENT - Takes(s): 8.9, Count: 14, TPM: 94.5, Sum(ms): 4987, Avg(ms): 356, 90th(ms): 512, 99th(ms): 512, 99.9th(ms): 512
[Current] STOCK_LEVEL - Takes(s): 1.1, Count: 1, TPM: 53.9, Sum(ms): 32, Avg(ms): 32, 90th(ms): 32, 99th(ms): 32, 99.9th(ms): 32
[Current] NEW_ORDER - Takes(s): 9.7, Count: 22, TPM: 136.2, Sum(ms): 10306, Avg(ms): 468, 90th(ms): 1000, 99th(ms): 1000, 99.9th(ms): 1000
[Current] PAYMENT - Takes(s): 9.9, Count: 25, TPM: 151.0, Sum(ms): 9145, Avg(ms): 365, 90th(ms): 512, 99th(ms): 512, 99.9th(ms): 512
[Current] STOCK_LEVEL - Takes(s): 8.9, Count: 7, TPM: 46.9, Sum(ms): 602, Avg(ms): 86, 90th(ms): 192, 99th(ms): 192, 99.9th(ms): 192
[Current] DELIVERY - Takes(s): 7.7, Count: 4, TPM: 31.0, Sum(ms): 6028, Avg(ms): 1507, 90th(ms): 2000, 99th(ms): 2000, 99.9th(ms): 2000
[Current] NEW_ORDER - Takes(s): 9.6, Count: 15, TPM: 94.2, Sum(ms): 6610, Avg(ms): 440, 90th(ms): 1000, 99th(ms): 1000, 99.9th(ms): 1000
[Current] PAYMENT - Takes(s): 9.9, Count: 17, TPM: 102.9, Sum(ms): 6314, Avg(ms): 371, 90th(ms): 512, 99th(ms): 512, 99.9th(ms): 512
[Current] DELIVERY - Takes(s): 9.6, Count: 2, TPM: 12.5, Sum(ms): 3126, Avg(ms): 1563, 90th(ms): 2000, 99th(ms): 2000, 99.9th(ms): 2000
[Current] NEW_ORDER - Takes(s): 9.1, Count: 21, TPM: 139.2, Sum(ms): 9752, Avg(ms): 464, 90th(ms): 1000, 99th(ms): 1000, 99.9th(ms): 1000
[Current] ORDER_STATUS - Takes(s): 7.2, Count: 1, TPM: 8.3, Sum(ms): 131, Avg(ms): 131, 90th(ms): 160, 99th(ms): 160, 99.9th(ms): 160
[Current] PAYMENT - Takes(s): 9.9, Count: 21, TPM: 127.6, Sum(ms): 7808, Avg(ms): 371, 90th(ms): 512, 99th(ms): 512, 99.9th(ms): 512
[Current] STOCK_LEVEL - Takes(s): 5.2, Count: 3, TPM: 34.8, Sum(ms): 183, Avg(ms): 61, 90th(ms): 96, 99th(ms): 96, 99.9th(ms): 96
Finished
[Summary] DELIVERY - Takes(s): 52.6, Count: 12, TPM: 13.7, Sum(ms): 18522, Avg(ms): 1543, 90th(ms): 2000, 99th(ms): 2000, 99.9th(ms): 2000
[Summary] NEW_ORDER - Takes(s): 59.5, Count: 123, TPM: 124.0, Sum(ms): 57115, Avg(ms): 464, 90th(ms): 1000, 99th(ms): 1000, 99.9th(ms): 1000
[Summary] NEW_ORDER_ERR - Takes(s): 59.5, Count: 1, TPM: 1.0, Sum(ms): 85, Avg(ms): 85, 90th(ms): 96, 99th(ms): 96, 99.9th(ms): 96
[Summary] ORDER_STATUS - Takes(s): 56.3, Count: 8, TPM: 8.5, Sum(ms): 882, Avg(ms): 110, 90th(ms): 160, 99th(ms): 160, 99.9th(ms): 160
[Summary] PAYMENT - Takes(s): 59.5, Count: 113, TPM: 113.9, Sum(ms): 42012, Avg(ms): 371, 90th(ms): 512, 99th(ms): 512, 99.9th(ms): 512
[Summary] STOCK_LEVEL - Takes(s): 60.0, Count: 17, TPM: 17.0, Sum(ms): 1218, Avg(ms): 71, 90th(ms): 112, 99th(ms): 192, 99.9th(ms): 192
tpmC: 124.0
```

14. go-tpch
```
//load 
~/tidb/bin/go-tpc/bin/go-tpc tpch prepare -H 127.0.0.1 -P 4000 -D tpch --sf 4 --analyze
~/tidb/bin/go-tpc/bin/go-tpc tpch run -H 127.0.0.1 -P 4000 -D tpch --sf 4 

```



附录: 
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


  // 磁盘读写压力 相对较大， 
  ```
  sar -b
  06:14:01 PM       tps      rtps      wtps      dtps   bread/s   bwrtn/s   bdscd/s
06:16:01 PM    456.66      3.64    453.02      0.00    565.37  18111.98      0.00
06:18:01 PM    427.38      0.00    427.38      0.00      0.00   6088.85      0.00
06:20:01 PM    424.00      0.00    424.00      0.00      0.00   5842.69      0.00
06:22:01 PM    444.65      0.00    444.65      0.00      0.00   8527.38      0.00
06:24:01 PM    447.00      0.03    446.96      0.00      5.00  12862.06      0.00
06:26:01 PM    464.93      9.92    455.01      0.00    321.21  24011.40      0.00
06:28:01 PM    451.46      0.00    451.46      0.00      0.00   9549.28      0.00
06:30:01 PM    450.55      0.02    450.53      0.00      2.33  10723.04      0.00
06:32:01 PM    456.38      0.02    456.36      0.00      1.53  50394.13      0.00
06:34:01 PM    456.09      0.00    456.09      0.00      0.00  53976.94      0.00
06:36:01 PM    456.37      0.16    456.21      0.00     23.06  81448.35      0.00
06:38:01 PM    447.68      0.00    447.68      0.00      0.00  49071.44      0.00
06:40:01 PM    447.69      0.02    447.67      0.00      2.00  51851.56      0.00
06:42:01 PM    442.31      0.02    442.30      0.00      2.20  89668.93      0.00
06:44:01 PM    447.63      0.00    447.63      0.00      0.00  61085.75      0.00
06:46:01 PM    447.10      0.02    447.08      0.00      0.20  80567.89      0.00
06:48:01 PM    452.76      0.00    452.76      0.00      0.00  61764.77      0.00
06:50:01 PM    472.39      0.00    472.39      0.00      0.00 112689.01      0.00
06:52:01 PM    449.07      0.01    449.06      0.00      1.40  79171.67      0.00
06:54:01 PM    440.10      0.01    440.09      0.00      1.33  59747.71      0.00
06:56:01 PM    434.21      0.02    434.19      0.00      2.40  62647.16      0.00
Average:       139.30      0.84    138.46      0.00     74.45  26184.09      0.00
  ```