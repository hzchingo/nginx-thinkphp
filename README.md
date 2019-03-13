# nginx-thinkphp
自带配置文件生成功能，用于快速的部署多个访问路径（是指nginx中的一个“location”，本项目中成为`context`）。

## 配置方式

通过在创建docker容器的时候传递环境变量来设置context，环境变量的命名支持`NGINX_CONTEXT`，以及`NGINX_CONTEXT_1`两种格式（第二种格式的1是指数字序号，最多支持到20）。

每个环境变量的值是以竖线分割的字符串，其格式及含义为“type|context|path|host”，其中

* type，是指该context的种类。
* context，是指在nginx服务中的访问路径，如‘/’或‘/myapp’。
* path，是指网页、代码在服务器上的目录，如“/var/www/html”；当type为“http”时，是指要反向代理的源url。
* host，仅在type为thinkphp时有用，是指php-fpm服务的主机和端口，如“172.0.0.2:9000”。

以下是创建docker容器的命令行示例：

```sh
docker run -d -e NGINX_CONTEXT_1=static\|/\|/var/www/html --name nginx chingo/nginx-thinkphp
```
### 访问路径的种类(type)

支持4种context的配置：
* static：普通的访问方式（静态资源）。
* vue：vue虽然也是静态资源，但为了支持它的路由，需要在Nginx中进行特殊设置。
* http：将Context反向代理到另一个网址（传递了域名和原始ip）。
* thinkphp: 将Context反向代理到php-fpm服务器上（php-fpm服务器需要自己另外搞定）。

## docker-compose示例
推荐使用docker-compose来部署。

```yml
version: '3.5'
services:
  nginxv2:
    container_name: nginxv2
    image: e499471b0912
    environment:
      NGINX_CONTEXT: static|/|/var/www/html
      NGINX_CONTEXT_1: thinkphp|/api|/var/www/html/public|agent-php
      NGINX_CONTEXT_2: http|/movie|http://192.168.104.35:8080/movie
      NGINX_CONTEXT_8: vue|/dashboard|/var/www/dashboard
    restart: always
```

则docker容器/etc/nginx/conf.d/目录下将生成default.conf，内容如下
```conf
server {
    listen 80 default_server;
    server_name _;
    error_log /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;


    ##############################################
    # CONTEXT static|/|/var/www/html
    location / {
        alias /var/www/html;
        index index.html;
    }

    ##############################################
    # CONTEXT thinkphp|/api|/var/www/html/public|agent-php
    location /api {
        alias /var/www/html/public;
        try_files $uri $uri/ @thinkphp1;
        client_max_body_size 40m;
        client_body_buffer_size 128k;

        location ~ \.php$ {
            include                            fastcgi_params;
            fastcgi_param   SCRIPT_FILENAME    $request_filename;
            fastcgi_pass                       agent-php;
        }
    }
    location @thinkphp1 {
        rewrite /api/(.*)$ /api/index.php?s=/$1 last;
    }

    ##############################################
    # CONTEXT http|/movie|http://192.168.104.35:8080/movie
    location /movie {
        proxy_pass http://192.168.104.35:8080/movie;

        expires off;
        proxy_set_header HOST $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    ##############################################
    # CONTEXT vue|/dashboard|/var/www/dashboard
    location /dashboard {
        alias /var/www/dashboard;
        try_files $uri $uri/ /index.html;
        index index.html;
    }

    location ~* ^.+.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt)$ {
        access_log        off;
        log_not_found     off;
    }
    location ~ /\. {
        access_log off;
        log_not_found off;
        deny all;
    }
    if ($request_method !~ ^(GET|HEAD|POST|OPTIONS)$ ) {
        return 444;
    }
}
```
