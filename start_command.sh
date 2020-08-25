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

 ~/tidb/bin/prometheus-2.20.1.linux-386/prometheus  --config.file ~/tidb/config/prometheus.yml \
    --web.listen-address=":9090" \
    --web.external-url="http://192.168.199.123:9090/" \
    --web.enable-admin-api \
    --log.level="info" \
    --storage.tsdb.path="/home/dsseter/tidb/data/prometheus" \
    --storage.tsdb.retention="15d"

# sysbench
sysbench --config-file=/home/dsseter/tidb/config/sysbench_config.conf oltp_point_select --threads=20 --tables=32 --table-size=10000 prepare


# kill tidb 
ps -ef |grep tidb |grep -v  tail  |grep -v ps |grep -v grep | awk '{print $2}' |xargs kill -9