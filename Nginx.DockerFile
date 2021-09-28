FROM debian:9 as build

ENV VER_NGINX_DEVEL_KIT=0.2.19
ENV VER_LUA_NGINX_MODULE=0.9.16
ENV VER_NGINX=1.7.10
ENV VER_LUAJIT=2.0.4
ENV NGINX_DEVEL_KIT ngx_devel_kit-${VER_NGINX_DEVEL_KIT}
ENV LUA_NGINX_MODULE lua-nginx-module-${VER_LUA_NGINX_MODULE}
ENV NGINX_ROOT=/nginx
ENV WEB_DIR ${NGINX_ROOT}/html
ENV LUAJIT_LIB /usr/local/lib
ENV LUAJIT_INC /usr/local/include/luajit-2.0

RUN apt update && apt -y install wget make libpcre3 libpcre3-dev zlib1g-dev libssl-dev gcc

RUN wget http://nginx.org/download/nginx-${VER_NGINX}.tar.gz \
    && wget http://luajit.org/download/LuaJIT-${VER_LUAJIT}.tar.gz \
    && wget https://github.com/simpl/ngx_devel_kit/archive/v${VER_NGINX_DEVEL_KIT}.tar.gz -O ${NGINX_DEVEL_KIT}.tar.gz \
    && wget https://github.com/openresty/lua-nginx-module/archive/v${VER_LUA_NGINX_MODULE}.tar.gz -O ${LUA_NGINX_MODULE}.tar.gz \
    && tar -xzvf nginx-${VER_NGINX}.tar.gz && rm nginx-${VER_NGINX}.tar.gz \
    && tar -xzvf LuaJIT-${VER_LUAJIT}.tar.gz && rm LuaJIT-${VER_LUAJIT}.tar.gz \
    && tar -xzvf ${NGINX_DEVEL_KIT}.tar.gz && rm ${NGINX_DEVEL_KIT}.tar.gz \
    && tar -xzvf ${LUA_NGINX_MODULE}.tar.gz && rm ${LUA_NGINX_MODULE}.tar.gz

WORKDIR /LuaJIT-${VER_LUAJIT}
RUN make && make install

WORKDIR /nginx-${VER_NGINX}

RUN ./configure --prefix=${NGINX_ROOT} --with-ld-opt="-Wl,-rpath,${LUAJIT_LIB}" --add-module=/${NGINX_DEVEL_KIT} --add-module=/${LUA_NGINX_MODULE} \
    && make -j2 && make install
RUN ln -s ${NGINX_ROOT}/sbin/nginx /usr/local/sbin/nginx

WORKDIR ${WEB_DIR}
EXPOSE 80
EXPOSE 443

RUN rm -rf /nginx-${VER_NGINX} && rm -rf /LuaJIT-${VER_LUAJIT} && rm -rf /${NGINX_DEVEL_KIT} && rm -rf /${LUA_NGINX_MODULE}


FROM debian:9
WORKDIR /usr/local/sbin/nginx
COPY --from=build /nginx/sbin/ .
RUN mkdir ../logs ../conf && touch ../logs/error.log && chmod +x nginx
CMD ["nginx", "-g", "daemon off;"]