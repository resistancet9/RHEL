# RHEL
Sensu, Grafaana, InfluxDB complete setup on RHEL OS on AWS EC2.

Document is incomplete. but there is single file(RHEL_CENTOS_Sensu_influxdb_grafana.sh) in which i've included everything thats need to be setup.
Execute this script and make sure to change Public IP Address of your sensu server in the file '/etc/sensu/conf.d/handlers.json' after executing.

once you change the IP Address, restart all the services

'sudo service sensu-server restart && service sensu-api restart && service sensu-client restart && service uchiwa restart && service grafana-server restart && service influxd restart'


The script does following:

installs all the necessary packages(Sensu,influxdb,grafana) and all the links between them. on server machine. (Im doing this on single machine, if this is working i hope setting up client is easy)

it installs 'load-metrics' checks. so when you open 'server_public_IP:8083' and select database 'sensu' and 'show measurements' you must be able to see three metric measurements.

if you need to add more metrics like cpu or memory. download them and edit /etc/sensu/conf.d/metrics.json file and add handler as 'influxdb_udp' this must get you metrics you required in the db.

*:8083 - Influxdb admin page
*:3000 - Grafana
*:3001 - Uchiwa
*:15672 - RabbitMQ

You need to login to Grafana 'admin' and 'admin' as creds and add metrics. follow http://docs.grafana.org/datasources/influxdb/

here are the details i've used.

sensu host - /sensu
sensu password - sensupasswd
sensu username - sensu
database - sensu
db username - test
db test user's password - test
