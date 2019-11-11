# confluent-startup

## PREREQUESITES

  	jdk8
  	Docker
  	fish bash (in order to use some commands, but you can use bash or zsh)
  	curl
  
# Setting the environment

	set -x JAVA_HOME (/usr/libexec/java_home -v 1.8)

	set -x CONFLUENT_CLI_HOME /Users/aironman/confluent-5.3.1/confluent-cli

	set -x CONFLUENT_HOME /Users/aironman/confluent-5.3.1
  
	docker run -it -p 9000:9000 tgowda/inception_serving_tika

	curl -L https://cnfl.io/cli | sh -s -- -b /Users/aironman/confluent-5.3.1/confluent-cli/bin

	$CONFLUENT_HOME/bin/confluent-hub install --no-prompt confluentinc/kafka-connect-datagen:latest

	set PATH $JAVA_HOME $PATH

	set PATH $CONFLUENT_CLI_HOME/bin $PATH

	set PATH $CONFLUENT_HOME/bin $PATH

# Start the platform!

	confluent local start

# creating some kafka topics 
	
	kafka-topics --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic users

	kafka-topics --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic pageviews

# Install a Kafka Connector and Generate Sample Data
# Run one instance of the Kafka Connect Datagen connector to produce Kafka data to the pageviews topic in AVRO format
	
	wget https://github.com/confluentinc/kafka-connect-datagen/raw/master/config/connector_pageviews_cos.config
	curl -X POST -H "Content-Type: application/json" --data @connector_pageviews_cos.config http://localhost:8083/connectors

# Run another instance of the Kafka Connect Datagen connector to produce Kafka data to the users topic in AVRO format

	wget https://github.com/confluentinc/kafka-connect-datagen/raw/master/config/connector_users_cos.config
	curl -X POST -H "Content-Type: application/json" --data @connector_users_cos.config http://localhost:8083/connectors

## Create and Write to a Stream and Table using KSQL
## Start the KSQL CLI in your terminal with this command

	LOG_DIR=./ksql_logs 
	set LOG_DIR ./ksql_logs

	$CONFLUENT_HOME/bin/ksql

# Run these commands within ksql session

	CREATE STREAM pageviews (viewtime BIGINT, userid VARCHAR, pageid VARCHAR) WITH (KAFKA_TOPIC='pageviews', VALUE_FORMAT='AVRO');

	SHOW STREAMS;

	CREATE TABLE users (registertime BIGINT, gender VARCHAR, regionid VARCHAR, userid VARCHAR) WITH (KAFKA_TOPIC='users', VALUE_FORMAT='AVRO', KEY = 'userid');

	SHOW TABLES;

	SET 'auto.offset.reset'='earliest';

	SELECT pageid FROM pageviews LIMIT 3;

	CREATE STREAM pageviews_female AS SELECT users.userid AS userid, pageid, regionid, gender FROM pageviews LEFT JOIN users ON pageviews.userid = users.userid WHERE gender = 'FEMALE';

	CREATE STREAM pageviews_female_like_89 WITH (kafka_topic='pageviews_enriched_r8_r9', value_format='AVRO') AS SELECT * FROM pageviews_female WHERE regionid LIKE '%_8' OR regionid LIKE '%_9';

	CREATE TABLE pageviews_regions AS SELECT gender, regionid , COUNT(*) AS numusers FROM pageviews_female WINDOW TUMBLING (size 30 second) GROUP BY gender, regionid HAVING COUNT(*) > 1;

# Monitor Streaming Data

	DESCRIBE EXTENDED pageviews_female_like_89;

	show queries;

	EXPLAIN CTAS_PAGEVIEWS_REGIONS_2;

  	confluent local stop

# BE CAREFUL! ARE YOU SURE?
  	
	confluent local destroy

Links

  # https://docs.confluent.io/current/quickstart/cos-quickstart.html#cos-quickstart
