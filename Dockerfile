# 基础镜像
FROM  openjdk:8u342-jdk-oracle
# author
MAINTAINER yangzeling@126.com

LABEL project="flowable" \
    tier="infra" \
    app="flowable-admin" \
    version="v1.0.0"

# 设置JAVA 启动参数
ENV JAVA_OPTS="-Xms128m -Xmx2G -Dfile.encoding=UTF-8 -Djava.security.egd=file:/dev/./urandom "

# 挂载目录
VOLUME /home/app
# 创建目录
RUN mkdir -p /home/app \
 && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
 &&  echo 'Asia/Shanghai' >/etc/timezone
# 指定路径
WORKDIR /home/app
# 复制jar文件到路径
COPY ./ruoyi-admin/target/ruoyi-admin.jar /home/app/app-admin.jar
# 启动系统服务
ENTRYPOINT ["/bin/sh", "-c", "java -jar app-admin.jar ${JAVA_OPTS}"]