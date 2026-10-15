FROM php:8.3-cli

# Cài đặt các thư viện cần thiết
RUN apt-get update -y && apt-get install -y libpq-dev unzip curl

# Cài đặt extension MySQL cho PHP
RUN docker-php-ext-install pdo pdo_mysql

# Cài đặt Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Chuyển vào thư mục gốc và copy code
WORKDIR /app
COPY . .

# Chui vào đúng thư mục backend
WORKDIR /app/backend_api

# XÓA TẬN GỐC CÁI FILE NHỚ TẠM BỊ DÍNH TỪ MÁY TÍNH LÊN
RUN rm -f bootstrap/cache/*.php

# Cài đặt thư viện của Laravel 
RUN composer install --no-dev --optimize-autoloader

# Lệnh khởi động Server và bơm dữ liệu
CMD php artisan migrate:fresh --seed --force && php artisan serve --host=0.0.0.0 --port=$PORT
