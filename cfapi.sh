#!/bin/bash

cf_api_url='https://api.cloudflare.com/client/v4'

get_zone_info () {
    curl -s -X GET --url ${cf_api_url}/zones/${ZONE_ID} \
        -H 'Content-Type: application/json' \
        -H "X-Auth-Email: ${EMAIL}" \
        -H "X-Auth-Key: ${GAPI_KEY}"
}

get_zone_name () {
    get_zone_info | jq -r ".result | .name"
}

list_dns_record () {
    curl -s -X GET --url ${cf_api_url}/zones/${ZONE_ID}/dns_records \
        -H 'Content-Type: application/json' \
        -H "X-Auth-Email: ${EMAIL}" \
        -H "X-Auth-Key: ${GAPI_KEY}"
}

get_dns_record () {
    record_name=$1

    allrecord=$(list_dns_record ${ZONE_ID})
    recordid=$(echo $allrecord | jq -r ".result[] | select(.name == \"${record_name}\") | .id")
    recordip=$(echo $allrecord | jq -r ".result[] | select(.name == \"${record_name}\") | .content")
    echo $recordid $recordip
}

create_dns_record () {
    record_name=$1
    record_type=$2
    record_data=$3

    echo Add new record $1 $2 $3
    curl -s -X POST --url ${cf_api_url}/zones/${ZONE_ID}/dns_records \
        -H "Content-Type: application/json" \
        -H "X-Auth-Email: ${EMAIL}" \
        -H "X-Auth-Key: ${GAPI_KEY}" \
        --data "{ \
            \"id\": \"${ZONE_ID}\", \
            \"name\": \"${record_name}\", \
            \"type\": \"${record_type}\", \
            \"content\": \"${record_data}\", \
            \"proxied\": false, \
            \"ttl\": 1 }"
    echo ""
}

update_dns_record () {
    record_id=$1
    record_name=$2
    record_type=$3
    record_data=$4

    echo Update record $2 $3 $4
    curl -s -X PATCH --url ${cf_api_url}/zones/${ZONE_ID}/dns_records/${record_id} \
        -H "Content-Type: application/json" \
        -H "X-Auth-Email: ${EMAIL}" \
        -H "X-Auth-Key: ${GAPI_KEY}" \
        --data "{ \
            \"id\": \"${ZONE_ID}\", \
            \"name\": \"${record_name}\", \
            \"type\": \"${record_type}\", \
            \"content\": \"${record_data}\", \
            \"proxied\": false, \
            \"ttl\": 1 }"
    echo ""
}

del_dns_record () {
    record_name=$1

    v=$(get_dns_record ${record_name}.$(get_zone_name))
    record_id="${v%% *}"

    [ -z "${record_id}" ] && echo Record ${record_name} not found. && return

    echo Delete record $1
    curl -s -X DELETE --url ${cf_api_url}/zones/${ZONE_ID}/dns_records/${record_id} \
        -H "Content-Type: application/json" \
        -H "X-Auth-Email: ${EMAIL}" \
        -H "X-Auth-Key: ${GAPI_KEY}"
    echo ""
}

set_dns_record () {
    record_name=$1
    reocrd_type=$2
    record_data=$3

    v=$(get_dns_record ${record_name}.$(get_zone_name))
    r_record_id="${v%% *}"
    r_record_data="${v#* }"

    echo got record ${record_name} $v

    if [ -z "${r_record_id}" ]; then
        create_dns_record $1 $2 $3
        return
    fi 

    if [ "${r_record_data}" = "${record_data}" ]; then
        echo Dns record not changed, no need update.
        return
    fi

    update_dns_record $r_record_id $1 $2 $3
}

