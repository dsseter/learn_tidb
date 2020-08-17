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
pd-server  --data-dir="pd" 
         
```
tikv: 
```
./tikv-server -A 127.0.0.1:20160 --pd="127.0.0.1:2379"  --status-addr="127.0.0.1:20180"
./tikv-server -A 127.0.0.1:20161 --pd="127.0.0.1:2379" --data-dir="tikv1"  --status-addr="127.0.0.1:20181"
./tikv-server -A 127.0.0.1:20162 --pd="127.0.0.1:2379" --data-dir="tikv2"  --status-addr="127.0.0.1:20182
```
tidb:
```
./bin/tidb-server --store=tikv \
                  --path="127.0.0.1:2379"
```
6. 登录 tidb
 mysql -h 127.0.0.1 -P 4000 -u root
7. 创建表，插入数据验证
```
create table t(id int unique key AUTO_INCREMENT);
insert into t values(),(),();
select * from t;
+------+
| id   |
+------+
|    1 |
|    2 |
|    3 |
+------+
 
```

8. 学习 tidb 源码
[TiDB 源码初探](https://segmentfault.com/a/1190000008083158) 熟悉代码架构层次
[TiKV 源码解析系列文章（十二）分布式事务](https://pingcap.com/blog-cn/tikv-source-code-reading-12/)
[TiDB 最佳实践系列（三）乐观锁事务](https://pingcap.com/blog-cn/best-practice-optimistic-transaction/)
[TiKV 事务模型概览，Google Spanner 开源实现](https://pingcap.com/blog-cn/tidb-transaction-model/)
[TiDB 源码阅读系列文章（三）SQL 的一生](https://pingcap.com/blog-cn/tidb-source-code-reading-3/)


9. 分析tidb 源代码内容
kv.go StartTS // 事务定义interface，
tikv/txn.go StartTS// tikv 事务实现 从 pd 读取时间
kv/txn.go RunInNewTxn // 新事务环境执行器。
executor/ 是代码执行器
session/ 是数据库连接 session。

10. 原理分析
SQL语句在经过语义解析，优化后，在执行器执行（executor）
其中 simple.go 的 
func (e *SimpleExec) executeBegin(ctx context.Context, s *ast.BeginStmt) error  负责处理 事务的 begin 语句
func (e *SimpleExec) executeCommit(s *ast.CommitStmt)  负责事务的 commit
func (e *SimpleExec) executeRollback(s *ast.RollbackStmt) error  负责事务回滚


10. 修改代码
在 simple.go: executeBegin 方法中添加日志语句
	logutil.BgLogger().Info("hello transaction")
11. 编译 make
12. 执行，启动一直打印 
```
[2020/08/17 05:09:43.701 +00:00] [INFO] [session.go:1502] ["NewTxn() inside a transaction auto commit"] [conn=1] [schemaVersion=24] [txnStartTS=418811902470651904]
[2020/08/17 05:09:43.702 +00:00] [INFO] [simple.go:584] ["hello transaction"]
[2020/08/17 05:09:44.100 +00:00] [INFO] [simple.go:584] ["hello transaction"]
[2020/08/17 05:09:44.114 +00:00] [INFO] [simple.go:584] ["hello transaction"]
```
其中tidb 每3秒自动执行两个 事务（原因未知). 
执行 begin 语句后， 日志变成奇数个。 


