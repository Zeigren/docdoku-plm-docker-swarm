#!/bin/bash

source /env_secrets_expand.sh

set -e

DOCDOKU_PLM_CODEBASE=${DOCDOKU_PLM_CODEBASE:-http://localhost}
HEAP_SIZE=${HEAP_SIZE:-2g}
AS_ADMIN_PASSWORD=${AS_ADMIN_PASSWORD:-changeit}
JWT_ENABLED=${JWT_ENABLED:-true}
JWT_KEY=${JWT_KEY:-MyVerySecretPhrase}
SESSION_ENABLED=${SESSION_ENABLED:-false}
BASIC_AUTH_ENABLED=${BASIC_AUTH_ENABLED:-false}
DATABASE_USER=${DATABASE_USER:-docdokuplm}
DATABASE_PWD=${DATABASE_PWD:-changeit}
DATABASE_URL=${DATABASE_URL:-jdbc:mysql://localhost:3306/docdokuplm}
ES_SERVER_URI=${ES_SERVER_URI:-http://localhost:9200}
ES_SERVER_SHARDS=${ES_SERVER_SHARDS:-4}
ES_SERVER_AUTO_EXPAND_REPLICAS=${ES_SERVER_AUTO_EXPAND_REPLICAS:-0-3}
ES_SERVER_REPLICAS=${ES_SERVER_REPLICAS:-0}
ES_SERVER_PWD=${ES_SERVER_PWD:-changeme}
ES_SERVER_USERNAME=${ES_SERVER_USERNAME:-elastic}
ES_SERVER_AWS_SERVICE=${ES_SERVER_AWS_SERVICE:-}
ES_SERVER_AWS_REGION=${ES_SERVER_AWS_REGION:-}
ES_SERVER_AWS_KEY=${ES_SERVER_AWS_KEY:-}
ES_SERVER_AWS_SECRET=${ES_SERVER_AWS_SECRET:-}
SMTP_HOST=${SMTP_HOST:-}
SMTP_PORT=${SMTP_PORT:-}
SMTP_USER=${SMTP_USER:-}
SMTP_FROM_ADDR=${SMTP_FROM_ADDR:-}
KEYSTORE_LOCATION=${KEYSTORE_LOCATION:-/opt/payara41/keystore/dplm.jceks}
KEYSTORE_KEY_ALIAS=${KEYSTORE_KEY_ALIAS:-mykey}
KEYSTORE_PASS=${KEYSTORE_PASS:-changeit}
KEYSTORE_KEY_PASS=${KEYSTORE_KEY_PASS:-changeit}
KEYSTORE_TYPE=${KEYSTORE_TYPE:-JCEKS}
SOLIDWORKS_LICENSE_PATH=${SOLIDWORKS_LICENSE_PATH:-/opt/plugins/solidworks/license.txt}
SOLIDWORKS_SCHEMA_PATH=${SOLIDWORKS_SCHEMA_PATH:-/opt/plugins/solidworks/schema}
CATIA_LICENSE_PATH=${CATIA_LICENSE_PATH:-/opt/plugins/catia/license.txt}
OFFICE_PORT=${OFFICE_PORT:-8100}
OFFICE_HOME=${OFFICE_HOME:-/usr/lib/libreoffice}
ASADMIN_PATH=${ASADMIN_PATH:-/opt/payara41/bin}
DOMAIN_DIR=${DOMAIN_DIR:-/opt/payara41/glassfish/domains/domain1}
VAULT_PATH=${VAULT_PATH:-/var/lib/docdoku/vault}
NATIVE_LIBS=${NATIVE_LIBS:-/opt/native-libs}
UPDATE=${UPDATE:-false}

if [[ ${UPDATE} = true ]]; then

if [[ ! -f ${KEYSTORE_LOCATION} ]]; then
	keytool -genseckey -storetype JCEKS -keyalg AES -keysize 256 -keystore ${KEYSTORE_LOCATION} -storepass ${KEYSTORE_PASS} -keypass ${KEYSTORE_KEY_PASS}
fi

cat > "/opt/tmpfile" <<EOF
AS_ADMIN_PASSWORD=
AS_ADMIN_NEWPASSWORD=${AS_ADMIN_PASSWORD}
EOF

cat > "/opt/pwdfile" <<EOF
AS_ADMIN_PASSWORD=${AS_ADMIN_PASSWORD}
EOF

 ${ASADMIN_PATH}/asadmin start-domain
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/tmpfile change-admin-password
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile enable-secure-admin
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile create-custom-resource --restype java.util.Properties --factoryclass org.glassfish.resources.custom.factory.PropertiesFactory --property="" docdokuplm.config
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile create-custom-resource --restype java.util.Properties --factoryclass org.glassfish.resources.custom.factory.PropertiesFactory --property="" auth.config
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile create-custom-resource --restype java.util.Properties --factoryclass org.glassfish.resources.custom.factory.PropertiesFactory --property="" security.config
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile create-custom-resource --restype java.util.Properties --factoryclass org.glassfish.resources.custom.factory.PropertiesFactory --property="" elasticsearch.config
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile create-custom-resource --restype java.util.Properties --factoryclass org.glassfish.resources.custom.factory.PropertiesFactory --property="" office.config
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile create-jdbc-connection-pool --restype javax.sql.ConnectionPoolDataSource --datasourceclassname com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource --property="" DocDokuPLMPool
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile create-jdbc-resource --connectionpoolid DocDokuPLMPool jdbc/docdokuPU
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile create-jvm-options -Dfile.encoding=UTF-8
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile delete-jvm-options '-Xmx512m'
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile create-jvm-options -Xmx${HEAP_SIZE}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile create-javamail-resource --mailhost ${SMTP_HOST} --mailuser ${SMTP_USER} --fromaddress ${SMTP_FROM_ADDR} --property mail.smtp.host=${SMTP_HOST}:mail.smtp.starttls.enable=false:mail.smtp.port=${SMTP_PORT}:mail.smtp.auth=false mail/docdokuSMTP
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set server.network-config.protocols.protocol.http-listener-1.http.upload-timeout-enabled=false
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set server.network-config.protocols.protocol.http-listener-1.http.connection-upload-timeout-millis=-1
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.jdbc-connection-pool.DocDokuPLMPool.property.URL=${DATABASE_URL}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.jdbc-connection-pool.DocDokuPLMPool.property.user=${DATABASE_USER}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.jdbc-connection-pool.DocDokuPLMPool.property.password=${DATABASE_PWD}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.docdokuplm.config.property.vaultPath=${VAULT_PATH}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.docdokuplm.config.property.codebase=${DOCDOKU_PLM_CODEBASE}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.auth.config.property."jwt\.enabled"=${JWT_ENABLED}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.auth.config.property."jwt\.key"=${JWT_KEY}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.auth.config.property."session\.enabled"=${SESSION_ENABLED}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.auth.config.property."basic\.header\.enabled"=${BASIC_AUTH_ENABLED}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.elasticsearch.config.property.serverUri=${ES_SERVER_URI}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.elasticsearch.config.property.number_of_shards=${ES_SERVER_SHARDS}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.elasticsearch.config.property.auto_expand_replicas="${ES_SERVER_AUTO_EXPAND_REPLICAS}"
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.elasticsearch.config.property.number_of_replicas=${ES_SERVER_REPLICAS}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.elasticsearch.config.property.password=${ES_SERVER_PWD}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.elasticsearch.config.property.username=${ES_SERVER_USERNAME}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.elasticsearch.config.property.awsService=${ES_SERVER_AWS_SERVICE}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.elasticsearch.config.property.awsRegion=${ES_SERVER_AWS_REGION}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.elasticsearch.config.property.awsAccessKey=${ES_SERVER_AWS_KEY}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.elasticsearch.config.property.awsSecretKey=${ES_SERVER_AWS_SECRET}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.office.config.property.office_home=${OFFICE_HOME}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.office.config.property.office_port=${OFFICE_PORT}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.security.config.property.keystoreLocation=${KEYSTORE_LOCATION}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.security.config.property.keystorePass=${KEYSTORE_PASS}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.security.config.property.keyAlias=${KEYSTORE_KEY_ALIAS}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.security.config.property.keystoreType=${KEYSTORE_TYPE}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set resources.custom-resource.security.config.property.keyPass=${KEYSTORE_KEY_PASS}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile set server.java-config.native-library-path-prefix=${NATIVE_LIBS}
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile create-custom-resource --restype java.lang.String --factoryclass org.glassfish.resources.custom.factory.PrimitivesAndStringFactory --property value=${SOLIDWORKS_LICENSE_PATH} datakit/solidworks/licensePath
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile create-custom-resource --restype java.lang.String --factoryclass org.glassfish.resources.custom.factory.PrimitivesAndStringFactory --property value=${SOLIDWORKS_SCHEMA_PATH} datakit/solidworks/schemaDir
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile create-custom-resource --restype java.lang.String --factoryclass org.glassfish.resources.custom.factory.PrimitivesAndStringFactory --property value=${CATIA_LICENSE_PATH} datakit/catia/licensePath
 ${ASADMIN_PATH}/asadmin --user admin --passwordfile=/opt/pwdfile stop-domain
 rm /opt/pwdfile
 rm /opt/tmpfile
fi

exec "$@"