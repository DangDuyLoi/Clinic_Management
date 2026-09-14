FROM php:8.2-fpm

# Cài đặt các thư viện hệ thống cần thiết
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Cài đặt các extension PHP (quan trọng nhất là pdo_mysql để gọi DB)
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Cài đặt Composer để quản lý thư viện Laravel
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html