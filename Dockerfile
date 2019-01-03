FROM alpine as clone

WORKDIR /src

RUN apk add git

RUN git init \
    && git remote add origin https://github.com/ProjectNami/projectnami \
    && git fetch --depth 1 origin 2.0.2 \
    && git checkout FETCH_HEAD \
    && rm -rf .git

FROM php:7.1-apache

RUN echo "deb http://httpredir.debian.org/debian jessie main contrib non-free\ndeb-src http://httpredir.debian.org/debian jessie main contrib non-free\n\ndeb http://security.debian.org/ jessie/updates main contrib non-free\ndeb-src http://security.debian.org/ jessie/updates main contrib non-free" > /etc/apt/sources.list.d/jessie.list \
	&& apt-get update \
    && apt-get install -y --no-install-recommends \
        locales \
        apt-transport-https \
		libssl1.0.0 \
		gnupg \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/8/prod.list > /etc/apt/sources.list.d/mssql-release.list \
	&& echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && apt-get update \
	&& export ACCEPT_EULA=y \
    && apt-get -y --no-install-recommends install \
        msodbcsql \
        unixodbc-dev \
	&& rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/jessie.list \
	&& docker-php-ext-install \
		mbstring \
		pdo \
		pdo_mysql \
    && pecl install \
		sqlsrv \
		pdo_sqlsrv \
    && docker-php-ext-enable \
		sqlsrv \
		pdo_sqlsrv

VOLUME [ "/var/www/html/" ]

COPY --from=clone --chown=www-data:www-data /src /var/www/html/
