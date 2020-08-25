# 启动 pd
~/tidb/pd/bin/pd-server -config ~/tidb/config/pd_config.toml
# tikv
~/tidb/tikv/target/release/tikv-server --config ~/tidb/config/tikv_config_20161.toml
~/tidb/tikv/target/release/tikv-server --config ~/tidb/config/tikv_config_20162.toml
~/tidb/tikv/target/release/tikv-server --config ~/tidb/config/tikv_config_20163.toml
 # tidb
~/tidb/tidb/bin/tidb-server --config ~/tidb/config/tidb_config.toml

 ~/tidb/bin/prometheus-2.20.1.linux-386/prometheus  --config.file ~/tidb/config/prometheus.yml \
    --web.listen-address=":9090" \
    --web.external-url="http://192.168.199.123:9090/" \
    --web.enable-admin-api \
    --log.level="info" \
    --storage.tsdb.path="/home/dsseter/tidb/data/prometheus" \
    --storage.tsdb.retention="15d"