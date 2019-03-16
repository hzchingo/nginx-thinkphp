#!/usr/bin/env sh

gen_location()
{
    type=$1
    context=$2
    path=$3
    host=$4

    gen_${type}_location $context $path $host
}

gen_http_location()
{
    location=$1
    destination=$2
    cat <<EOF
    location $1 {
        proxy_pass $2;

        expires off;
        proxy_set_header HOST \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
EOF
}
gen_vue_location()
{
    location=$1
    destination=$2
    cat <<EOF
    location $1 {
        alias $2;
        try_files \$uri \$uri/ /index.html;
        index index.html;
    }
EOF
}
gen_static_location()
{
    location=$1
    destination=$2
    cat <<EOF
    location $1 {
        alias $2;
        index index.html;
    }
EOF
}
gen_thinkphp_location()
{
    location=$1
    destination=$2
    host=$3

    if [ "$location" = "/" ]; then
        location1=""
    else
        location1=$location
    fi

    cat <<EOF
    location $location {
        alias $destination;
        try_files \$uri \$uri/ @thinkphp$context_index;
        client_max_body_size 40m;
        client_body_buffer_size 128k;

        location ~ \.php$ {
            include                            fastcgi_params;
            fastcgi_param   SCRIPT_FILENAME    \$request_filename;
            fastcgi_pass                       $host;
        }
    }
    location @thinkphp$context_index {
        rewrite $location1/(.*)\$ $location1/index.php?s=/\$1 last;
    }
EOF
}

cat  <<EOF
    log_format main1 "\$request_filename - fastcgi_script_filename";
server {
    listen 80 default_server;
    error_log /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log main1;

EOF

for i in "" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
do
    if [ "$i" = "" ]; then
        config=$NGINX_CONTEXT
    else
        eval config='$'NGINX_CONTEXT_$i
    fi
    if [ ! "$config" = "" ]; then
        echo ""
        echo "    ##############################################"
        echo "    # CONTEXT $config"
        var1=`echo $config | cut -f 1 -d\|`
        var2=`echo $config | cut -f 2 -d\|`
        var3=`echo $config | cut -f 3 -d\|`
        var4=`echo $config | cut -f 4 -d\|`
        export context_index=$i
        gen_location $var1 $var2 $var3 $var4
    fi
done

cat <<EOF

    location ~* ^.+.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt)\$ {
        access_log        off;
        log_not_found     off;
    }
    location ~ /\. {
        access_log off;
        log_not_found off;
        deny all;
    }
    if (\$request_method !~ ^(GET|HEAD|POST|OPTIONS)\$ ) {
        return 444;
    }
}
EOF
