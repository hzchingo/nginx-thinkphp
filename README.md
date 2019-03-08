# nginx-thinkphp
用于反向代理php-fpm的thinkphp项目，内置rewrite规则。

这个容器被设计为与chingo/php72-fpm一起使用，用于运行一个基于ThinkPHP开发的项目。

本容器在部署时需要提供环境变量`PHP_FPM_HOST`来传递fastcgi反向代理的主机名称。端口强制为9000。

# 使用方法
建议使用docker-compose来一键部署。

假设我们有一个项目名为`project`，为此我们需要启动两个容器：
* `project`-php 运行php-fpm，负责php文件的执行
* `project`-nginx 运行nginx，提供静态文件服务，反向代理php-fpm。

为了网络安全，我们使用docker的network机制来创建一个专有的网络，名为`project-network`，使得php-fpm的端口仅能被nginx在专网内部被访问到。

docker-compose.yml示例如下
```yml
version: '3.5'
services:
  project-nginx:
    container_name: project-nginx
    image: "chingo/nginx-thinkphp"
    ports:
     - "89:80"
    volumes:
     - ./src:/var/www/html
    environment:
     PHP_FPM_HOST: project-php
    restart: always
    networks: 
     - project-network
  project-php:
    container_name: project-php
    image: "chingo/php72-fpm"
    volumes:
     - ./src:/var/www/html
    restart: always
    networks: 
     - project-network
networks:
    project-network:
      name: project-network

```
