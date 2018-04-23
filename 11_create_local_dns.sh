#/bin/bash

officialserver=192.168.0.1
DOM=example.com
REV=0.168.192.in-addr.arpa
NAMESERVER=oselab.example.com  
ocp_hosts_file=$HOME/project/homework/hosts 
zone_file=/var/named/zones/${DOM}.db
reverse_zone_file=/var/named/zones/${REV}.db
named_conf=/etc/named.conf
tmp_file=$(mktemp)

export DOM NAMESERVER ocp_hosts_file

function forw_record {
     echo -n "$1. IN A "
     dig +short $1 @$officialserver
}

function rev_record {
     dig +short $1 @$officialserver | sed -e 's:\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\)\.\([0-9]*\):\4.\3.\2.\1.in-addr.arpa. IN PTR '$1'.:'
}

function zone_head {
cat << EOF
\$ORIGIN  .
\$TTL 1  ;  1 seconds (for testing only)
${1}. IN SOA ${NAMESERVER}.  root.${NAMESERVER}.  (
  2011112904  ;  serial
  60  ;  refresh (1 minute)
  15  ;  retry (15 seconds)
  1800  ;  expire (30 minutes)
  10  ; minimum (10 seconds)
)
  NS ${NAMESERVER}.
\$ORIGIN ${1}.

EOF
}

function add_zone_to_named_conf  {
cat << EOF

zone "$1" IN {
  type master;
  file "zones/$1.db";
  allow-update { key cloudapps-86ca.oslab.opentlc.com ; } ;
};
EOF
}

function add_forwarders_to_named_conf {
   gawk '
      /options / { 
           print ; 
           print "        forwarders {"
           print "              8.8.8.8 ;"
           print "              8.8.4.4 ;"
           print "              } ;"
           next ;
        }
        { print }
      
' $named_conf 
}


#### MAIN
## create forward zone
zone_head $DOM > $zone_file
forw_record $NAMESERVER >> $zone_file
awk '/'$DOM'/ { print $1 }' $ocp_hosts_file | sed -e 's/#//g'  -e '/^$/d' | sort -u | while read name
do
 forw_record $name >> $zone_file
done

## create reverse zone
zone_head $REV > $reverse_zone_file
rev_record $NAMESERVER >> $reverse_zone_file
awk '/'$DOM'/ { print $1 }' $ocp_hosts_file | sed -e 's/#//g'  -e '/^$/d' | sort -u | while read name
do
 rev_record $name >> $reverse_zone_file
done


## add zone to nameserver

grep -q "$DOM" $named_conf || add_zone_to_named_conf $DOM >> $named_conf
grep -q "$REV" $named_conf || add_zone_to_named_conf $REV >> $named_conf
grep -q "forwarders" $named_conf || { 
    add_forwarders_to_named_conf > $tmp_file
    mv $tmp_file $named_conf
    chmod 640 $named_conf
    chgrp named $named_conf
}

sytemctl restart named
