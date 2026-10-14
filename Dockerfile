FROM php:8.2-cli

# Cài đặt các thư viện cần thiết cho máy chủ
RUN apt-get update -y && apt-get install -y libpq-dev unzip curl

# Cài đặt extension MySQL cho PHP
RUN docker-php-ext-install pdo pdo_mysql

# Cài đặt Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Chuyển vào thư mục làm việc
WORKDIR /app
COPY . .

# Cài đặt thư viện của Laravel
RUN composer install --no-dev --optimize-autoloader

# Lệnh khởi động Server
CMD php artisan serve --host=0.0.0.0 --port=$PORT
