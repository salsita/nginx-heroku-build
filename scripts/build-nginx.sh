#!/bin/bash
# Build NGINX and modules on Heroku.
# This program is designed to run in a web dyno provided by Heroku.
# We would like to build an NGINX binary for the builpack on the
# exact machine in which the binary will run.
# Our motivation for running in a web dyno is that we need a way to
# download the binary once it is built so we can vendor it in the buildpack.
#
# Once the dyno has is 'up' you can open your browser and navigate
# this dyno's directory structure to download the nginx binary.

NGINX_VERSION=${NGINX_VERSION-1.15.7}
PCRE_VERSION=${PCRE_VERSION-8.42}
HEADERS_MORE_VERSION=${HEADERS_MORE_VERSION-0.33}
LUA_MODULE_VERSION=${LUA_MODULE_VERSION-0.10.13}
LUA_SRC_VERSION=${LUA_SRC_VERSION-5.1}
NGX_DEVEL_KIT_VERSION=${NGX_DEVEL_KIT_VERSION-0.2.19}
ZLIB_VERSION=${ZLIB_VERSION-1.2.11}

nginx_tarball_url=http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
pcre_tarball_url=http://iweb.dl.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.bz2
headers_more_nginx_module_url=https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERS_MORE_VERSION}.tar.gz
lua_module_url=https://github.com/openresty/lua-nginx-module/archive/v${LUA_MODULE_VERSION}.tar.gz
lua_src=http://www.lua.org/ftp/lua-${LUA_SRC_VERSION}.tar.gz
ngx_devel_kit_module_url=https://github.com/simpl/ngx_devel_kit/archive/v${NGX_DEVEL_KIT_VERSION}.tar.gz
zlib_url=http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz
ngx_brotli_url=https://github.com/google/ngx_brotli.git

temp_dir=$(mktemp -d /tmp/nginx.XXXXXXXXXX)

echo "Serving files from /tmp on $PORT"
cd /tmp
python -m SimpleHTTPServer $PORT &

cd $temp_dir
echo "Temp dir: $temp_dir"

#define where lua libs are
export LUA_LIB=${temp_dir}/nginx-${NGINX_VERSION}/lua-${LUA_SRC_VERSION}/src
export LUA_INC=${temp_dir}/nginx-${NGINX_VERSION}/lua-${LUA_SRC_VERSION}/src

echo "Downloading $nginx_tarball_url"
curl -L $nginx_tarball_url | tar xzv

echo "Downloading $pcre_tarball_url"
(cd nginx-${NGINX_VERSION} && curl -L $pcre_tarball_url | tar xvj )

echo "Downloading $headers_more_nginx_module_url"
(cd nginx-${NGINX_VERSION} && curl -L $headers_more_nginx_module_url | tar xvz )

echo "Downloading $lua_module_url"
(cd nginx-${NGINX_VERSION} && curl -L $lua_module_url | tar xvz )

echo "Downloading $ngx_devel_kit_module_url"
(cd nginx-${NGINX_VERSION} && curl -L $ngx_devel_kit_module_url | tar xvz )
echo "Downloading and building $lua_src"
(
  cd nginx-${NGINX_VERSION} && curl -L $lua_src | tar xvz
  cd /${temp_dir}/nginx-${NGINX_VERSION}/lua-${LUA_SRC_VERSION}
  make linux
)

echo "Downloading $zlib_url"
(cd nginx-${NGINX_VERSION} && curl -L $zlib_url | tar xvz )


echo "Downloading $ngx_brotli_url"
(cd nginx-${NGINX_VERSION} && git clone --recursive $ngx_brotli_url )

(
  cd nginx-${NGINX_VERSION}
  ./configure \
    --prefix=/tmp/nginx \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_gzip_static_module \
    --without-http_scgi_module  \
    --without-http_uwsgi_module  \
    --without-http_fastcgi_module \
    --error-log-path=/tmp/nginx/log/error.log \
    --http-client-body-temp-path=/tmp/nginx/body \
    --http-log-path=/tmp/nginx/log/access.log \
    --http-proxy-temp-path=/tmp/nginx/proxy \
    --lock-path=/tmp/nginx/nginx.lock \
    --pid-path=/tmp/nginx/nginx.pid \
    --with-pcre=pcre-${PCRE_VERSION} \
    --with-zlib=zlib-${ZLIB_VERSION} \
    --add-module=${temp_dir}/nginx-${NGINX_VERSION}/headers-more-nginx-module-${HEADERS_MORE_VERSION} \
    --add-module=${temp_dir}/nginx-${NGINX_VERSION}/ngx_devel_kit-${NGX_DEVEL_KIT_VERSION} \
    --add-module=${temp_dir}/nginx-${NGINX_VERSION}/lua-nginx-module-${LUA_MODULE_VERSION} \
    --add-module=${temp_dir}/nginx-${NGINX_VERSION}/ngx_brotli
  make install
)

rm -f $1
cp /tmp/nginx/sbin/nginx $1
