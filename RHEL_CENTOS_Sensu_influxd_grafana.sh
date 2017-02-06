sudo yum update -y
sudo yum -y install wget
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -Uvh epel-release-latest-7*.rpm
sudo yum -y install gcc glibc-devel make ncurses-devel openssl-devel autoconf
sudo yum install -y erlang
wget https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.5/rabbitmq-server-3.6.5-1.noarch.rpm
rpm --import http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
sudo yum -y install rabbitmq-server-3.6.5-1.noarch.rpm
sudo chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/
sudo systemctl enable rabbitmq-server
sudo systemctl start rabbitmq-server
sudo rabbitmqctl add_vhost /sensu
sudo rabbitmqctl add_user sensu sensupasswd
sudo rabbitmqctl set_user_tags sensu administrator
sudo rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*"
sudo rabbitmq-plugins enable rabbitmq_management
sudo systemctl restart rabbitmq-server
sudo yum install redis -y
sudo systemctl start redis && redis-cli ping
sudo echo '[sensu]
name=sensu
baseurl=http://sensu.global.ssl.fastly.net/yum/$basearch/
gpgcheck=0
enabled=1' | sudo tee /etc/yum.repos.d/sensu.repo
sudo yum install sensu -y
sudo yum install uchiwa -y
sudo echo '{
"rabbitmq":{
"host":"127.0.0.1",
"port":5672,
"vhost":"/sensu",
"user":"sensu",
"password":"sensupasswd"
}
}' > /etc/sensu/conf.d/rabbitmq.json
sudo echo '{
"redis":{
"host":"127.0.0.1",
"port":6379
}
}' > /etc/sensu/conf.d/redis.json
sudo echo '{
"api":{
"host":"127.0.0.1",
"port":4567
}
}' > /etc/sensu/conf.d/api.json
sudo echo '{
  "sensu": [
    {
      "name": "testingserver",
      "host": "127.0.0.1",
      "ssl":false,
      "port": 4567,
  "user":"",
  "pass":"",
  "path":"",
      "timeout": 5000
    }
],

  "uchiwa": {
  "user":"",
  "pass":"",
    "port": 3001,
  "stats":10,
    "refresh": 5
  }
}' > /etc/sensu/uchiwa.json
sudo systemctl start sensu-server && systemctl start sensu-api
sudo /etc/init.d/uchiwa start
sudo yum install -y git-core zlib zlib-devel gcc-c++ patch readline readline-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel ruby ruby-devel
gem install sensu-plugin
gem install mixlib-cli
systemctl status sensu-server && systemctl status sensu-api
sudo /etc/init.d/uchiwa status

sudo systemctl restart sensu-server && systemctl restart sensu-api && systemctl restart uchiwa

sudo echo '{
"client":{
"name":"self",
"address":"localhost",
"subscriptions":["self"],
"safe_mode":true
}
}' > /etc/sensu/conf.d/client.json
sudo service sensu-client restart
sudo yum install https://grafanarel.s3.amazonaws.com/builds/grafana-4.0.2-1481203731.x86_64.rpm -y
sudo service grafana-server start
cat <<EOF | sudo tee /etc/yum.repos.d/influxdb.repo
[influxdb]
name = InfluxDB Repository - RHEL \$releasever
baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key
EOF

sudo yum install influxdb -y
sudo service influxdb start
sudo rm /etc/influxdb/influxdb.conf
cat<<EOF123 | sudo tee /etc/influxdb/influxdb.conf
### Welcome to the InfluxDB configuration file.

# The values in this file override the default values used by the system if
# a config option is not specified.  The commented out lines are the the configuration
# field and the default value used.  Uncommentting a line and changing the value
# will change the value used at runtime when the process is restarted.

# Once every 24 hours InfluxDB will report usage data to usage.influxdata.com
# The data includes a random ID, os, arch, version, the number of series and other
# usage data. No data from user databases is ever transmitted.
# Change this option to true to disable reporting.
# reporting-disabled = false

# we'll try to get the hostname automatically, but if it the os returns something
# that isn't resolvable by other servers in the cluster, use this option to
# manually set the hostname
# hostname = "localhost"

###
### [meta]
###
### Controls the parameters for the Raft consensus group that stores metadata
### about the InfluxDB cluster.
###

[meta]
  # Where the metadata/raft database is stored
  dir = "/var/lib/influxdb/meta"

  # Automatically create a default retention policy when creating a database.
  # retention-autocreate = true

  # If log messages are printed for the meta service
  # logging-enabled = true

###
### [data]
###
### Controls where the actual shard data for InfluxDB lives and how it is
### flushed from the WAL. "dir" may need to be changed to a suitable place
### for your system, but the WAL settings are an advanced configuration. The
### defaults should work for most systems.
###

[data]
  # The directory where the TSM storage engine stores TSM files.
  dir = "/var/lib/influxdb/data"

  # The directory where the TSM storage engine stores WAL files.
  wal-dir = "/var/lib/influxdb/wal"

  # Trace logging provides more verbose output around the tsm engine. Turning
  # this on can provide more useful output for debugging tsm engine issues.
  # trace-logging-enabled = false

  # Whether queries should be logged before execution. Very useful for troubleshooting, but will
  # log any sensitive data contained within a query.
  # query-log-enabled = true

  # Settings for the TSM engine

  # CacheMaxMemorySize is the maximum size a shard's cache can
  # reach before it starts rejecting writes.
  # cache-max-memory-size = 1048576000

  # CacheSnapshotMemorySize is the size at which the engine will
  # snapshot the cache and write it to a TSM file, freeing up memory
  # cache-snapshot-memory-size = 26214400

  # CacheSnapshotWriteColdDuration is the length of time at
  # which the engine will snapshot the cache and write it to
  # a new TSM file if the shard hasn't received writes or deletes
  # cache-snapshot-write-cold-duration = "10m"

  # CompactFullWriteColdDuration is the duration at which the engine
  # will compact all TSM files in a shard if it hasn't received a
  # write or delete
  # compact-full-write-cold-duration = "4h"

  # The maximum series allowed per database before writes are dropped.  This limit can prevent
  # high cardinality issues at the database level.  This limit can be disabled by setting it to
  # 0.
  # max-series-per-database = 1000000

  # The maximum number of tag values per tag that are allowed before writes are dropped.  This limit
  # can prevent high cardinality tag values from being written to a measurement.  This limit can be
  # disabled by setting it to 0.
  # max-values-per-tag = 100000



###
### [admin]
###
### Controls the availability of the built-in, web-based admin interface. If HTTPS is
### enabled for the admin interface, HTTPS must also be enabled on the [http] service.
###
### NOTE: This interface is deprecated as of 1.1.0 and will be removed in a future release.

 [admin]
  # Determines whether the admin service is enabled.
   enabled = true

  # The default bind address used by the admin service.
   bind-address = ":8083"

  # Whether the admin service should use HTTPS.
   https-enabled = false

  # The SSL certificate used when HTTPS is enabled.
  # https-certificate = "/etc/ssl/influxdb.pem"

###
### [http]
###
### Controls how the HTTP endpoints are configured. These are the primary
### mechanism for getting data into and out of InfluxDB.
###

 [http]
  # Determines whether HTTP endpoint is enabled.
   enabled = true

  # The bind address used by the HTTP service.
   bind-address = ":8086"

  # Determines whether HTTP authentication is enabled.
   auth-enabled = false

  # The default realm sent back when issuing a basic auth challenge.
  # realm = "InfluxDB"

  # Determines whether HTTP request logging is enable.d
   log-enabled = true

  # Determines whether detailed write logging is enabled.
   write-tracing = true

  # Determines whether the pprof endpoint is enabled.  This endpoint is used for
  # troubleshooting and monitoring.
   pprof-enabled = true

  # Determines whether HTTPS is enabled.
   https-enabled = false

  # The SSL certificate to use when HTTPS is enabled.
  # https-certificate = "/etc/ssl/influxdb.pem"

  # Use a separate private key location.
  # https-private-key = ""

  # The JWT auth shared secret to validate requests using JSON web tokens.
  # shared-sercret = ""

  # The default chunk size for result sets that should be chunked.
   max-row-limit = 10000

  # The maximum number of HTTP connections that may be open at once.  New connections that
  # would exceed this limit are dropped.  Setting this value to 0 disables the limit.
  # max-connection-limit = 0

  # Enable http service over unix domain socket
  # unix-socket-enabled = false

  # The path of the unix domain socket.
  # bind-socket = "/var/run/influxdb.sock"

###
### [[udp]]
###
### Controls the listeners for InfluxDB line protocol data via UDP.
###

 [[udp]]
   enabled = true
   bind-address = ":8089"
   database = "sensu"
  # retention-policy = ""

  # These next lines control how batching works. You should have this enabled
  # otherwise you could get dropped metrics or poor performance. Batching
  # will buffer points in memory if you have many coming in.

  # Flush if this many points get buffered
   batch-size = 5000

  # Number of batches that may be pending in memory
   batch-pending = 10

  # Will flush at least this often even if we haven't hit buffer limit
   batch-timeout = "1s"

  # UDP Read buffer size, 0 means OS default. UDP listener will fail if set above OS max.
   read-buffer = 0
EOF123
sudo service influxd restart
cat<<EOF | sudo tee /etc/sensu/conf.d/handlers.json
{
  "handlers": {
     "influx-tcp": {
       "type": "pipe",
       "command": "/opt/sensu/embedded/bin/metrics-influxdb.rb"
     },	
"influxdb_udp": {
      "type": "udp",
      "socket": {
        "host": "54.254.208.32",
        "port": 8089
      },
      "mutator": "influxdb_line_protocol"
    }
  }
}
EOF
cat<<EOF | sudo tee /etc/sensu/conf.d/influx.json
{
    "influxdb": {
        "host"          : "localhost",
        "port"          : "8086",
        "username"      : "test",
        "password"      : "test",
        "database"      : "sensu",
	"status"        : true
    }
}
EOF
cat<<EOF | sudo tee /etc/sensu/conf.d/metrics.json
{
"checks": {
	"load_metrics": {
                        "type": "metric",
                        "command": "/opt/sensu/embedded/bin/metrics-load.rb",
                        "subscribers": ["self"],
                        "interval": 10,
                        "standalone": false,
                        "handlers": ["debug","influxdb_udp"]
                }
	}
}
EOF
/opt/sensu/embedded/bin/sensu-install -p influxdb
/opt/sensu/embedded/bin/gem install sensu-plugin
cat<<EOF123 | sudo tee /opt/sensu/embedded/bin/metrics-influx.rb
#! /usr/bin/env ruby
#
#   metrics-influx.rb
#
# DESCRIPTION:
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: influxdb
#
# USAGE:
#   #YELLOW
#
# NOTES:
#
# LICENSE:
#   Copyright (C) 2015, Sensu Plugins
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-handler'
gem 'influxdb', '>=0.2.0'
require 'influxdb'

#
# Sensu To Influxdb
#
class SensuToInfluxDB < Sensu::Handler
  option :config,
         description: 'Configuration information to use',
         short: '-c CONFIG',
         long: '--config CONFIG',
         default: 'influxdb'

  def filter; end

  def create_point(series, value, time)
    point = { series: series,
              tags: { host: @event['client']['name'], metric: @event['check']['name'] },
              values: { value: value },
              timestamp: time }
    point[:tags].merge!(@event['check']['tags']) unless @event['check']['tags'].nil?
    point
  end

  def parse_output
    data = []
    metric_raw = @event['check']['output']
    metric_raw.split("\n").each do |metric|
      m = metric.split
      next unless m.count == 3
      key = m[0].split('.', 2)[1]
      key.tr!('.', '_')
      value = m[1].to_f
      time = m[2]
      point = create_point(key, value, time)
      data.push(point)
    end
    data
  end

  def check_status
    data = []
    data.push(create_point(@event['check']['name'], @event['check']['status'], @event['client']['timestamp']))
  end

  def handle
    opts = settings[config[:config]].each_with_object({}) do |(k, v), sym|
      sym[k.to_sym] = v
    end
    database = opts[:database]

    influxdb_data = InfluxDB::Client.new database, opts
    influxdb_data.create_database(database) # Ensure the database exists

    data = if opts[:status] == false || opts[:status].nil?
             parse_output
           else
             check_status
           end
    influxdb_data.write_points(data)
  end
end
EOF123
sudo chmod 755 /opt/sensu/embedded/bin/metrics-influx.rb
cat<<EOF123 | sudo tee /etc/sensu/extensions/mutator-influxdb-line-protocol.rb
#! /usr/bin/env ruby
#
#   mutator-influxdb-line-protocol
#
# DESCRIPTION:
#   Mutates check results to conform to InfluxDB's line protocol format
#
# Place this file in /etc/sensu/extensions and modify your handlers JSON config
#
# handlers.json
# {
#   "influxdb_udp": {
#      "type": "udp",
#      "mutator": "influxdb_line_protocol",
#      "socket": {
#        "host": "mgt-monitor-db1",
#        "port": 8090
#      }
#    }
# }

require 'sensu/extension'

module Sensu
  module Extension
    class InfluxDBLineProtocol < Mutator
      def name
        'influxdb_line_protocol'
      end

      def description
        "returns check output formatted for InfluxDB's line protocol"
      end

      def run(event)
        tags = event[:check][:tags]
        host = event[:client][:name]
        metric = event[:check][:name]
        output = event[:check][:output]

        data = []
        output.split("\n").each do |result|
          m = result.split
          next unless m.count == 3
          key = m[0].split('.', 2)[1]
          key.tr!('.', '_')
          value = m[1].to_f
          time = m[2].ljust(19, '0')
          linedata = "#{key},host=#{host},metric=#{metric}"
          if tags
            tags.each do |tagname, tagvalue|
              linedata << ",#{tagname}=#{tagvalue}"
            end
          end
          data << "#{linedata} value=#{value} #{time}"
        end

        yield data.join("\n"), 0
      end
    end
  end
end
EOF123
sudo chmod 755 /etc/sensu/extensions/mutator-influxdb-line-protocol.rb
git clone https://github.com/sensu-plugins/sensu-plugins-load-checks.git
cat ./sensu-plugins-load-checks/bin/metrics-load.rb > /opt/sensu/embedded/bin/metrics-load.rb
sudo chmod 755 /opt/sensu/embedded/bin/metrics-load.rb

curl -i -XPOST http://localhost:8086/query --data-urlencode "q=CREATE USER test WITH PASSWORD 'test' WITH ALL PRIVILEGES"

curl -i -XPOST http://localhost:8086/query --data-urlencode "q=CREATE DATABASE sensu"

sudo service sensu-server restart && service sensu-api restart && service sensu-client restart && service uchiwa restart && service grafana-server restart && service influxd restart



