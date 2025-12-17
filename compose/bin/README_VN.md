# Thư Mục Bin - Các Script Hỗ Trợ

Thư mục này chứa các script hỗ trợ giúp đơn giản hóa việc làm việc với môi trường phát triển Magento dựa trên Docker. Các script này hoạt động như các wrapper để thực thi lệnh bên trong Docker container mà không cần nhớ các lệnh Docker Compose phức tạp.

## Tổng Quan

Thư mục `bin` cung cấp một bộ sưu tập các tiện ích dòng lệnh giúp trừu tượng hóa các thao tác Docker, giúp dễ dàng:
- Thực thi các lệnh Magento CLI
- Chạy PHP, Composer, Node.js và các công cụ khác
- Quản lý Docker containers
- Xử lý các thao tác cơ sở dữ liệu
- Cấu hình các công cụ phát triển (Xdebug, Blackfire, v.v.)
- Thực hiện các tác vụ thiết lập và bảo trì Magento thông thường

## Cách Sử Dụng

Tất cả các script trong thư mục này đều là các script bash có thể thực thi. Bạn có thể chạy chúng trực tiếp từ thư mục gốc của dự án:

```bash
bin/<tên-script> [đối-số]
```

Ví dụ:
```bash
bin/magento cache:flush
bin/composer install
bin/mysql
```

## Các Script Chính

### Lệnh Magento

#### `magento`
Chạy công cụ dòng lệnh Magento CLI. Đây là điểm vào chính cho tất cả các thao tác Magento.

**Cách sử dụng:**
```bash
bin/magento <lệnh> [tùy-chọn]
```

**Ví dụ:**
```bash
bin/magento cache:flush
bin/magento setup:upgrade
bin/magento indexer:reindex
bin/magento setup:di:compile
```

**Lưu ý:** Script này là điểm vào PHP CLI khởi tạo ứng dụng Magento. Nó phải được chạy trong ngữ cảnh Docker container.

### Quản Lý Container

#### `cli`
Thực thi bất kỳ lệnh CLI nào bên trong container `phpfpm`.

**Cách sử dụng:**
```bash
bin/cli <lệnh> [đối-số]
```

**Ví dụ:**
```bash
bin/cli ls -la
bin/cli php -v
bin/cli whoami
```

#### `clinotty`
Giống như `cli`, nhưng chạy không có TTY (hữu ích cho script và tự động hóa).

**Cách sử dụng:**
```bash
bin/clinotty <lệnh> [đối-số]
```

**Ví dụ:**
```bash
bin/clinotty chmod u+x bin/magento
bin/clinotty php script.php
```

#### `bash`
Vào shell bash tương tác bên trong container `phpfpm`.

**Cách sử dụng:**
```bash
bin/bash
```

#### `root`
Thực thi lệnh với quyền root bên trong container.

**Cách sử dụng:**
```bash
bin/root <lệnh> [đối-số]
```

**Ví dụ:**
```bash
bin/root apt-get update
bin/root chown -R app:app /var/www/html
```

#### `rootnotty`
Thực thi lệnh với quyền root không có TTY.

**Cách sử dụng:**
```bash
bin/rootnotty <lệnh> [đối-số]
```

### Thao Tác Docker

#### `start`
Khởi động tất cả các Docker container cho dự án.

**Cách sử dụng:**
```bash
bin/start [--no-dev]
```

**Tùy chọn:**
- `--no-dev`: Khởi động container không có công cụ phát triển

#### `stop`
Dừng tất cả các container của dự án.

**Cách sử dụng:**
```bash
bin/stop
```

#### `restart`
Dừng và sau đó khởi động lại tất cả các container.

**Cách sử dụng:**
```bash
bin/restart
```

#### `status`
Kiểm tra trạng thái của tất cả các container.

**Cách sử dụng:**
```bash
bin/status
```

#### `remove`
Xóa tất cả các container.

**Cách sử dụng:**
```bash
bin/remove
```

#### `removeall`
Xóa tất cả container, network, volume và image.

**Cách sử dụng:**
```bash
bin/removeall
```

**Cảnh báo:** Lệnh này sẽ xóa tất cả tài nguyên Docker liên quan đến dự án.

### Quản Lý Gói

#### `composer`
Chạy các lệnh Composer bên trong container.

**Cách sử dụng:**
```bash
bin/composer <lệnh> [tùy-chọn]
```

**Ví dụ:**
```bash
bin/composer install
bin/composer update
bin/composer require vendor/package
bin/composer show
```

#### `npm`
Chạy các lệnh npm bên trong container.

**Cách sử dụng:**
```bash
bin/npm <lệnh> [tùy-chọn]
```

**Ví dụ:**
```bash
bin/npm install
bin/npm run build
bin/npm --version
```

#### `node`
Chạy các lệnh Node.js bên trong container.

**Cách sử dụng:**
```bash
bin/node <lệnh> [tùy-chọn]
```

**Ví dụ:**
```bash
bin/node --version
bin/node script.js
```

### Thao Tác Cơ Sở Dữ Liệu

#### `mysql`
Truy cập MySQL CLI với cấu hình cơ sở dữ liệu từ `env/db.env`.

**Cách sử dụng:**
```bash
bin/mysql [tùy-chọn]
bin/mysql < file.sql  # Nhập file SQL
```

**Ví dụ:**
```bash
bin/mysql
bin/mysql -e "SHOW TABLES;"
bin/mysql < backup.sql
```

#### `mysqldump`
Xuất/sao lưu cơ sở dữ liệu Magento.

**Cách sử dụng:**
```bash
bin/mysqldump [tùy-chọn] > output.sql
```

**Ví dụ:**
```bash
bin/mysqldump > backup.sql
bin/mysqldump --single-transaction > backup.sql
```

### Thao Tác File

#### `copytocontainer`
Sao chép file hoặc thư mục từ host vào container.

**Cách sử dụng:**
```bash
bin/copytocontainer [đường-dẫn]
bin/copytocontainer --all  # Sao chép tất cả file
```

**Ví dụ:**
```bash
bin/copytocontainer vendor
bin/copytocontainer app/code
bin/copytocontainer --all
```

#### `copyfromcontainer`
Sao chép file hoặc thư mục từ container ra host.

**Cách sử dụng:**
```bash
bin/copyfromcontainer [đường-dẫn]
bin/copyfromcontainer --all  # Sao chép tất cả file
```

**Ví dụ:**
```bash
bin/copyfromcontainer vendor
bin/copyfromcontainer generated
bin/copyfromcontainer --all
```

### Thiết Lập & Cài Đặt

#### `setup`
Chạy quy trình thiết lập Magento để cài đặt Magento từ mã nguồn.

**Cách sử dụng:**
```bash
bin/setup [tên-miền]
```

**Ví dụ:**
```bash
bin/setup
bin/setup magento.test
```

#### `download`
Tải xuống phiên bản Magento cụ thể từ Composer.

**Cách sử dụng:**
```bash
bin/download [phiên-bản] [bản-phát-hành]
```

**Đối số:**
- `phiên-bản`: `community` (mặc định), `enterprise`, hoặc `mageos`
- `bản-phát-hành`: Phiên bản Magento (mặc định là phiên bản mới nhất nếu không chỉ định)

**Ví dụ:**
```bash
bin/download
bin/download community 2.4.8
bin/download enterprise 2.4.7-p3
bin/download mageos
```

#### `setup-domain`
Cấu hình tên miền Magento.

**Cách sử dụng:**
```bash
bin/setup-domain <tên-miền>
```

**Ví dụ:**
```bash
bin/setup-domain magento.test
bin/setup-domain local.magento.com
```

#### `setup-ssl`
Tạo chứng chỉ SSL cho một hoặc nhiều tên miền.

**Cách sử dụng:**
```bash
bin/setup-ssl <tên-miền1> [tên-miền2] ...
```

**Ví dụ:**
```bash
bin/setup-ssl magento.test
bin/setup-ssl magento.test admin.magento.test
```

### Công Cụ Phát Triển

#### `xdebug`
Bật, tắt hoặc kiểm tra trạng thái Xdebug.

**Cách sử dụng:**
```bash
bin/xdebug [enable|disable|status|mode]
```

**Ví dụ:**
```bash
bin/xdebug enable
bin/xdebug disable
bin/xdebug status
bin/xdebug debug  # Đặt chế độ tùy chỉnh
```

#### `debug-cli`
Bật Xdebug cho các lệnh `bin/magento`.

**Cách sử dụng:**
```bash
bin/debug-cli enable [IDE_KEY]
```

**Ví dụ:**
```bash
bin/debug-cli enable
bin/debug-cli enable PHPSTORM
```

#### `blackfire`
Bật hoặc tắt Blackfire profiler.

**Cách sử dụng:**
```bash
bin/blackfire [enable|disable|status]
```

**Ví dụ:**
```bash
bin/blackfire enable
bin/blackfire disable
bin/blackfire status
```

#### `spx`
Bật hoặc tắt SPX profiler.

**Cách sử dụng:**
```bash
bin/spx [enable|disable]
```

**Ví dụ:**
```bash
bin/spx enable
bin/spx disable
```

### Chất Lượng Mã

#### `phpcs`
Chạy PHP CodeSniffer với tiêu chuẩn mã Magento 2.

**Cách sử dụng:**
```bash
bin/phpcs <đường-dẫn>
```

**Ví dụ:**
```bash
bin/phpcs app/code
bin/phpcs app/code/Vendor/Module
```

#### `phpcbf`
Tự động sửa lỗi PHP CodeSniffer.

**Cách sử dụng:**
```bash
bin/phpcbf <đường-dẫn>
```

**Ví dụ:**
```bash
bin/phpcbf app/code
bin/phpcbf app/code/Vendor/Module
```

#### `analyse`
Chạy phân tích tĩnh PHPStan.

**Cách sử dụng:**
```bash
bin/analyse <đường-dẫn>
```

**Ví dụ:**
```bash
bin/analyse app/code
bin/analyse app/code/Vendor/Module
```

### Tiện Ích

#### `log`
Theo dõi các file log Magento.

**Cách sử dụng:**
```bash
bin/log [file-log]
```

**Ví dụ:**
```bash
bin/log              # Theo dõi tất cả file log
bin/log system.log
bin/log exception.log
bin/log debug.log
```

#### `cache-clean`
Truy cập CLI cache-clean để quản lý cache thông minh.

**Cách sử dụng:**
```bash
bin/cache-clean [loại-cache]
```

**Ví dụ:**
```bash
bin/cache-clean config
bin/cache-clean full_page
bin/cache-clean block_html
```

#### `fixperms`
Sửa quyền hệ thống file bên trong container.

**Cách sử dụng:**
```bash
bin/fixperms
```

#### `fixowns`
Sửa quyền sở hữu hệ thống file bên trong container.

**Cách sử dụng:**
```bash
bin/fixowns
```

#### `cron`
Khởi động hoặc dừng dịch vụ cron Magento.

**Cách sử dụng:**
```bash
bin/cron [start|stop]
```

**Ví dụ:**
```bash
bin/cron start
bin/cron stop
```

#### `redis`
Chạy các lệnh Redis CLI.

**Cách sử dụng:**
```bash
bin/redis <lệnh>
```

**Ví dụ:**
```bash
bin/redis redis-cli monitor
bin/redis redis-cli info
bin/redis redis-cli flushall
```

#### `magento-version`
Hiển thị phiên bản Magento đã cài đặt.

**Cách sử dụng:**
```bash
bin/magento-version
```

### Công Cụ Nâng Cao

#### `grunt`
Chạy Grunt JavaScript task runner.

**Cách sử dụng:**
```bash
bin/grunt <tác-vụ>
```

**Ví dụ:**
```bash
bin/grunt exec
bin/grunt watch
bin/grunt less
```

#### `n98-magerun2`
Truy cập công cụ CLI n98-magerun2.

**Cách sử dụng:**
```bash
bin/n98-magerun2 <lệnh>
```

**Ví dụ:**
```bash
bin/n98-magerun2 dev:console
bin/n98-magerun2 sys:info
bin/n98-magerun2 cache:clean
```

#### `mftf`
Chạy các lệnh Magento Functional Testing Framework.

**Cách sử dụng:**
```bash
bin/mftf <lệnh>
```

**Ví dụ:**
```bash
bin/mftf build:project
bin/mftf run:test AdminLoginSuccessfulTest
bin/mftf doctor
```

#### `deploy`
Chạy quy trình triển khai Magento tiêu chuẩn.

**Cách sử dụng:**
```bash
bin/deploy [ngôn-ngữ1] [ngôn-ngữ2] ...
```

**Ví dụ:**
```bash
bin/deploy
bin/deploy en_US nl_NL
```

## Quy Trình Làm Việc Thông Thường

### Thiết Lập Ban Đầu
```bash
bin/download community 2.4.8
bin/setup magento.test
bin/setup-ssl magento.test
```

### Phát Triển Hàng Ngày
```bash
bin/start
bin/magento cache:flush
bin/composer require vendor/package
bin/magento setup:upgrade
```

### Sao Lưu & Khôi Phục Cơ Sở Dữ Liệu
```bash
# Sao lưu
bin/mysqldump > backup.sql

# Khôi phục
bin/mysql < backup.sql
```

### Kiểm Tra Chất Lượng Mã
```bash
bin/phpcs app/code/Vendor/Module
bin/phpcbf app/code/Vendor/Module
bin/analyse app/code/Vendor/Module
```

### Gỡ Lỗi
```bash
bin/xdebug enable
bin/debug-cli enable PHPSTORM
# Đặt breakpoint trong IDE và chạy:
bin/magento cache:flush
```

## Lưu Ý

- Tất cả các script giả định bạn đang chạy chúng từ thư mục gốc của dự án (nơi có `compose.yaml`)
- Script tự động xử lý cấu hình Docker Compose
- Hầu hết các script yêu cầu container đang chạy (`bin/start`)
- Một số script có thể yêu cầu quyền root trên máy host của bạn (ví dụ: để sửa đổi `/etc/hosts`)
- Script sử dụng biến môi trường từ thư mục `env/` để cấu hình

## Khắc Phục Sự Cố

### Không tìm thấy script
Đảm bảo bạn đang ở thư mục gốc của dự án và script có quyền thực thi:
```bash
chmod +x bin/<tên-script>
```

### Container không chạy
Khởi động container trước:
```bash
bin/start
```

### Lỗi quyền
Sửa quyền bên trong container:
```bash
bin/fixperms
bin/fixowns
```

## Xem Thêm

- README dự án chính: `/README.md`
- Cấu hình Docker Compose: `/compose/compose.yaml`
- Cấu hình môi trường: `/compose/env/`
