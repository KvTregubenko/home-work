#Hello world
#Test DockerFile

FROM debian:9 as build

ENV NGINX_VER=1.7.9
ENV LUA_VER=2.0.4
ENV ngx_devel_kit=0.2.19
ENV lua_nginx_module=0.9.16

RUN apt-get update  -y && apt-get install -y gcc   libssl-dev   make   libpcre3-dev   zlib1g-dev   libxml2-dev   libxslt-dev   libgd-dev   libgeoip-dev   libperl-dev   wget

RUN wget http://nginx.org/download/nginx-${NGINX_VER}.tar.gz  && tar -zxvf nginx-${NGINX_VER}.tar.gz && rm -rf nginx-${NGINX_VER}.tar.gz
RUN wget https://github.com/openresty/luajit2/archive/refs/tags/v${LUA_VER}.tar.gz && tar -zxvf v${LUA_VER}.tar.gz && rm -rf v${LUA_VER}.tar.gz
RUN wget https://github.com/vision5/ngx_devel_kit/archive/refs/tags/v${ngx_devel_kit}.tar.gz && tar -zxvf v${ngx_devel_kit}.tar.gz && rm -rf v${ngx_devel_kit}.gz
RUN wget https://github.com/openresty/lua-nginx-module/archive/refs/tags/v${lua_nginx_module}.tar.gz && tar -zxvf v${lua_nginx_module}.tar.gz && rm -rf v${lua_nginx_module}.tar.gz

RUN export LUAJIT_LIB=/usr/local/lib \
    export LUAJIT_INC=/usr/local/include/luajit-2.0

WORKDIR /luajit2-${LUA_VER}
RUN make  && make install


# 


RUN ./configure --sbin-path=/usr/sbin/nginx \
#      --conf-path=/etc/nginx/nginx.conf \
#      --pid-path=/var/run/nginx.pid \
     --prefix=/opt/nginx \
     --with-ld-opt="-Wl,-rpath,/usr/local/lib" \
     --add-module=/ngx_devel_kit-0.2.19 \
     --add-module=/lua-nginx-module-0.9.16 && make -j2 && make install



EXPOSE 80


CMD ["nginx", "-g", "daemon off;"]