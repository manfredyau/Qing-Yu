-- 轻遇生产库初始化：创建 Rails 8 多数据库（primary / cache / queue / cable）
-- Postgres 镜像首次启动时以 superuser(postgres) 执行本脚本

CREATE DATABASE qingyu_production;
CREATE DATABASE qingyu_production_cache;
CREATE DATABASE qingyu_production_queue;
CREATE DATABASE qingyu_production_cable;
