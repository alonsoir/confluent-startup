set -x JAVA_HOME (/usr/libexec/java_home -v 1.8)
set -x CONFLUENT_CLI_HOME /Users/aironman/confluent-5.3.1/confluent-cli
set -x CONFLUENT_HOME /Users/aironman/confluent-5.3.1
set PATH $CONFLUENT_CLI_HOME/bin $PATH
set PATH $CONFLUENT_HOME/bin $PATH
set PATH $JAVA_HOME $PATH
# start the platform
confluent local start

