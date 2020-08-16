1. 了解 tidb
 quick start： 快速部署tidb， 试用[tiup](https://docs.pingcap.com/zh/tidb/stable/quick-start-with-tidb)
 ```
 tiup playground
```
2. 学习常规部署方案
[从零部署TiDB集群](http://blog.itpub.net/69908602/viewspace-2670574/)
[TiDB. 单节点部署](https://www.jianshu.com/p/61a2838ae8db)
  
3. 下载源码
pd: https://github.com/pingcap/pd
tikv: https://github.com/tikv/tikv
tidb: https://github.com/pingcap/tidb
4. 编译代码
pd: make -j 20
tidb: make -j 20
tikv: make release -j 20

5. 部署 pd:1, tidb:1 tikv:2集群
pd:
```
pd-server --name="pd" \
          --data-dir="pd" \
          --client-urls="http://192.168.199.123:2379" \
          --peer-urls="http://192.168.199.123:2380" \
          --log-file=pd.lo
```
tikv: 
```
./tikv-server -A 127.0.0.1:20160 --pd="127.0.0.1:2379"  --status-addr="127.0.0.1:20180"
./tikv-server -A 127.0.0.1:20161 --pd="127.0.0.1:2379" --data-dir="tikv1"  --status-addr="127.0.0.1:20181"
./tikv-server -A 127.0.0.1:20162 --pd="127.0.0.1:2379" --data-dir="tikv2"  --status-addr="127.0.0.1:20182
```
tidb:
```
./tidb-server -P 4000
```
6. 登录 tidb
 mysql -h 127.0.0.1 -P 4000 -u root
7. 创建表，插入数据验证
```
create table t(id int unique key AUTO_INCREMENT);
insert into t values(),(),()
select * from t;
+------+
| id   |
+------+
|    1 |
|    2 |
|    3 |
+------+
 
```

