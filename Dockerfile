FROM php:8.3-cli

# Cài đặt các thư viện cần thiết
RUN apt-get update -y && apt-get install -y libpq-dev unzip curl

# Cài đặt extension MySQL cho PHP
RUN docker-php-ext-install pdo pdo_mysql

# Cài đặt Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 1. Tạo thư mục làm việc gốc và copy toàn bộ code trên Git vào
WORKDIR /app
COPY . .

# 2. CHỈ ĐƯỜNG CHUI VÀO ĐÚNG THƯ MỤC BACKEND
WORKDIR /app/backend_api

# 3. Cài đặt thư viện của Laravel (lúc này đã thấy file composer.json)
RUN composer install --no-dev --optimize-autoloader

# 4. Lệnh khởi động Server
CMD php artisan migrate:fresh --seed --force && php artisan serve --host=0.0.0.0 --port=$PORT
