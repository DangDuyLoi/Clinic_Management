FROM php:8.3-cli

# Cài đặt các thư viện hệ thống và extension PHP bắt buộc cho Laravel
RUN apt-get update -y && apt-get install -y \
    libpq-dev \
    libzip-dev \
    libicu-dev \
    libonig-dev \
    unzip \
    curl \
    && docker-php-ext-install pdo pdo_mysql zip intl bcmath ctype fileinfo mbstring

# Cài đặt Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Chuyển vào thư mục gốc và copy code
WORKDIR /app
COPY . .

# Chui vào đúng thư mục backend chứa mã nguồn Laravel
WORKDIR /app/backend_api

# Xóa các file nhớ tạm (cache) bị dính từ máy tính lên
RUN rm -f bootstrap/cache/*.php

# Cài đặt thư viện của Laravel 
RUN composer install --no-dev --optimize-autoloader

# Lệnh khởi động Server và chạy migrate an toàn
CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=${PORT:-8000}
