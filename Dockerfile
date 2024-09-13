FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    zip \
    unzip \
    git \
    curl \
    nginx \
    && docker-php-ext-install pdo pdo_pgsql

RUN docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN mkdir -p /var/lib/nginx/body /var/lib/nginx/proxy /var/lib/nginx/fastcgi /var/lib/nginx/uwsgi /var/lib/nginx/scgi /var/tmp/nginx && \
    chown -R www-data:www-data /var/lib/nginx && \
    chown -R www-data:www-data /var/tmp/nginx && \
    chown -R www-data:www-data /var/log/nginx

COPY ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf

RUN groupadd -g 1000 laraveluser && \
    useradd -u 1000 -g laraveluser -m laraveluser

WORKDIR /var/www/html

COPY . .

RUN chown -R laraveluser:laraveluser /var/www/html/storage /var/www/html/bootstrap/cache

RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

COPY ./start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

USER laraveluser

EXPOSE 80

CMD ["/usr/local/bin/start.sh"]
