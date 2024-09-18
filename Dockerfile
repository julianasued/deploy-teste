# Use a imagem base PHP com FPM
FROM php:8.2-fpm

# Instale pacotes essenciais e dependências para PHP e Nginx
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
    && docker-php-ext-install pdo pdo_pgsql \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instale o Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Crie o usuário 'laraveluser'
RUN groupadd -g 1000 laraveluser && \
    useradd -u 1000 -g laraveluser -m laraveluser

# Defina o diretório de trabalho
WORKDIR /var/www/html

# Copie os arquivos da aplicação Laravel para o contêiner
COPY . .

# Ajuste permissões para a pasta de armazenamento e cache
RUN chown -R laraveluser:laraveluser /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Crie diretórios necessários para o Nginx e ajuste permissões
RUN mkdir -p /var/www/html/logs /run /var/lib/nginx/body /var/lib/nginx/proxy /var/lib/nginx/fastcgi /var/lib/nginx/uwsgi /var/lib/nginx/scgi /var/tmp/nginx /var/log/nginx && \
    touch /var/www/html/logs/access.log /var/log/nginx/error.log && \
    chown -R laraveluser:laraveluser /var/lib/nginx /var/tmp/nginx /var/log/nginx /run /var/www/html/logs && \
    chmod -R 775 /var/www/html/logs /var/log/nginx /run

# Copie a configuração do Nginx
COPY ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf

COPY ./start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Defina o usuário 'laraveluser' para rodar os comandos
USER laraveluser

# Exponha as portas 80 (Nginx) e 9000 (PHP-FPM)
EXPOSE 80 9000  

# Copie o script de inicialização
# COPY ./start.sh /usr/local/bin/start.sh
# RUN chmod +x /usr/local/bin/start.sh

# Comando de inicialização
CMD ["/usr/local/bin/start.sh"]