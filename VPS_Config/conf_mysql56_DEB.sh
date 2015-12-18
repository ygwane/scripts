## Conf MySQL 5.6 DEB/UBUNTU
sed -i -e 's/log_slow_queries/#log_slow_queries/g' /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i -e 's/long_query_time/#long_query_time/g' /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i -e 's/log-queries-not-using-indexes/#log-queries-not-using-indexes/g' /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i -e 's/query_cache_type/#query_cache_type/g' /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i -e 's/query_cache_limit/#query_cache_limit/g' /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i -e 's/query_cache_size/#query_cache_size/g' /etc/mysql/mysql.conf.d/mysqld.cnf
echo "slow-query-log-file = /var/log/mysql/mysql-slow.log" >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo "long_query_time = 3" >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo "query_cache_type = 1" >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo "query_cache_limit = 16M" >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo "query_cache_size = 128M" >> /etc/mysql/mysql.conf.d/mysqld.cnf
echo "max_connections = 100" >> /etc/mysql/mysql.conf.d/mysqld.cnf
service mysql restart
