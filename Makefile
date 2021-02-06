build: build-cedar-14 build-heroku-16 build-heroku-18 build-heroku-20

build-cedar-14:
	@echo "Building nginx in Docker for cedar-14..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=cedar-14" -e "NGINX_VERSION=1.9.5" -w /buildpack heroku/cedar:14 scripts/build-nginx.sh /buildpack/bin/nginx-cedar-14

build-heroku-16:
	@echo "Building nginx in Docker for heroku-16..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=heroku-16" -e "NGINX_VERSION=1.9.5" -w /buildpack heroku/heroku:16-build scripts/build-nginx.sh /buildpack/bin/nginx-heroku-16

build-heroku-18:
	@echo "Building nginx in Docker for heroku-18..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=heroku-18" -e "NGINX_VERSION=1.14.1" -e "PCRE_VERSION=8.42" -e "HEADERS_MORE_VERSION=0.33" -w /buildpack heroku/heroku:18-build scripts/build-nginx.sh /buildpack/bin/nginx-heroku-18

build-heroku-20:
	@echo "Building nginx in Docker for heroku-20..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=heroku-20" -e "NGINX_VERSION=1.19.6" -e "PCRE_VERSION=8.42" -e "HEADERS_MORE_VERSION=0.33" -w /buildpack heroku/heroku:18-build scripts/build-nginx.sh /buildpack/bin/nginx-heroku-20

shell:
	@echo "Opening heroku-20 shell..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=heroku-20" -e "PORT=5000" -w /buildpack heroku/heroku:20 bash
