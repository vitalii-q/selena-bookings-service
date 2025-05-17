CREATE DATABASE IF NOT EXISTS bookings;

CREATE USER IF NOT EXISTS 'booking_user'@'%' IDENTIFIED BY 'secure_password';

GRANT ALL PRIVILEGES ON bookings.* TO 'booking_user'@'%';

FLUSH PRIVILEGES;
