# 基础镜像
FROM nginx:1.21
# author
MAINTAINER yangzeling@126.com

ENV BASEDIR='/home/app/'



ADD ./dist  /usr/share/nginx/html/
COPY default.conf /etc/nginx/nginx.conf

WORKDIR /home/

EXPOSE 80
