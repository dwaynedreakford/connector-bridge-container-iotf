#!/bin/sh

report_ip_address()
{
   IP_ADDRESS=`ifconfig | perl -nle'/dr:(\S+)/ && print $1' | tail -1`
   HOSTNAME=`hostname`
   echo "Container Hostname: " ${HOSTNAME} " IP: " ${IP_ADDRESS}
}

update_hosts()
{
    sudo /home/arm/update_hosts.sh
}

run_supervisord()
{
   /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf 2>&1 1>/tmp/supervisord.log
}

run_bridge()
{
   cd /home/arm
   su -l arm -s /bin/bash -c "/home/arm/restart.sh"
}

run_configurator()
{
  cd /home/arm/configurator
  su -l arm -s /bin/bash -c "/home/arm/configurator/runConfigurator.sh 2>&1 1> /tmp/configurator.log &"
}

enable_long_polling() {
   LONG_POLL="$2"
   if [ "${LONG_POLL}" = "use-long-polling" ]; then
        DIR="mds/connector-bridge/conf"
        FILE="gateway.properties"
        cd /home/arm
        sed -e "s/mds_enable_long_poll=false/mds_enable_long_poll=true/g" ${DIR}/${FILE} 2>&1 1> ${DIR}/${FILE}.new
        mv ${DIR}/${FILE} ${DIR}/${FILE}.poll
        mv ${DIR}/${FILE}.new ${DIR}/${FILE}
        chown arm.arm ${DIR}/${FILE}
   fi
}

set_mdc_api_token() {
   API_TOKEN="$2"
   if [ "$2" = "use-long-polling" ]; then
        API_TOKEN="$3"
   fi
   if [ "${API_TOKEN}X" != "X" ]; then
        DIR="mds/connector-bridge/conf"
        FILE="gateway.properties"
        cd /home/arm
        sed -e "s/mbed_connector_api_token_goes_here/${API_TOKEN}/g" ${DIR}/${FILE} 2>&1 1> ${DIR}/${FILE}.new
        mv ${DIR}/${FILE} ${DIR}/${FILE}.mdc_api_token
        mv ${DIR}/${FILE}.new ${DIR}/${FILE}
        chown arm.arm ${DIR}/${FILE}
   fi
}

set_watson_api_key() {
   API_KEY="$3"
   if [ "$2" = "use-long-polling" ]; then
        API_KEY="$4"
   fi
   if [ "${API_KEY}X" != "X" ]; then
        DIR="mds/connector-bridge/conf"
        FILE="gateway.properties"
        cd /home/arm
        sed -e "s/a-__ORG_ID__-__ORG_KEY__/${API_KEY}/g" ${DIR}/${FILE} 2>&1 1> ${DIR}/${FILE}.new
        mv ${DIR}/${FILE} ${DIR}/${FILE}.watson_api_key
        mv ${DIR}/${FILE}.new ${DIR}/${FILE}
        chown arm.arm ${DIR}/${FILE}
   fi
}

set_watson_auth_token() {
   API_TOKEN="$4"
   if [ "$2" = "use-long-polling" ]; then
        API_TOKEN="$5"
   fi
   if [ "${API_TOKEN}X" != "X" ]; then
        DIR="mds/connector-bridge/conf"
        FILE="gateway.properties"
        cd /home/arm
        sed -e "s/iotf_authentication_token_goes_here/${API_TOKEN}/g" ${DIR}/${FILE} 2>&1 1> ${DIR}/${FILE}.new
        mv ${DIR}/${FILE} ${DIR}/${FILE}.watson_auth_token
        mv ${DIR}/${FILE}.new ${DIR}/${FILE}
        chown arm.arm ${DIR}/${FILE}
   fi
}

set_mbed_rest_api() {
   MBED_REST_API="$5"
   if [ "$2" = "use-long-polling" ]; then
       MBED_REST_API="$6"
   fi
   if [ "${MBED_REST_API}X" != "X" ]; then
        DIR="mds/connector-bridge/conf"
        FILE="gateway.properties"
        cd /home/arm
        sed -e "s/mbed_rest_api_goes_here/${MBED_REST_API}/g" ${DIR}/${FILE} 2>&1 1> ${DIR}/${FILE}.new
        mv ${DIR}/${FILE} ${DIR}/${FILE}.mbed_rest_api
        mv ${DIR}/${FILE}.new ${DIR}/${FILE}
        chown arm.arm ${DIR}/${FILE}
   fi

}

set_perms() {
  cd /home/arm
  chown -R arm.arm .
}

main() 
{
   # report_ip_address
   update_hosts
   enable_long_polling $*
   set_mdc_api_token $*
   set_watson_api_key $*
   set_watson_auth_token $*
   set_mbed_rest_api $*
   set_perms $*
   run_bridge
   run_configurator
   run_supervisord
}

main $*
