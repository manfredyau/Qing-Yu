# 轻遇 (Qingyu) · 实名制交友 App

> 主打「减少信息过载」的实名制交友应用——每天限量精选推荐，不刷屏、不海选；
> 实名认证（身份证 + 学信网）保证真实，认证通过后才能出现在推荐中。

## ✨ 功能

| 模块 | 说明 |
|---|---|
| 手机号登录 | 短信验证码登录，新手机号自动注册（开发环境 Mock 短信写入日志） |
| 实名认证 | 身份证二要素核验（GB 11643 校验位算法）+ 学信网在线验证码核验，V1/V2 等级 |
| 个人资料 | 昵称/性别/生日/身高/学历/职业/简介、照片（人工审核）、兴趣标签、择偶偏好 |
| 轻量推荐 | **每日限量 10 位**精选推荐，卡片滑动（左滑跳过/右滑喜欢），互相喜欢自动配对 |
| 实时聊天 | ActionCable + Turbo Stream 实时消息、未读计数、已读回执 |
| 管理后台 | 独立管理员登录，认证/照片审核队列、用户封禁管理 |
| 移动端 | Hotwire Native（iOS/Android 原生壳），原生 Tab + 路径配置 + Strada bridge 骨架 |

## 🛠 技术栈

- **Ruby 4.0 + Rails 8.1**（最新稳定版）
- **Hotwire**：Turbo Drive / Frames / Streams + Stimulus（无 Node 构建，importmap）
- **Hotwire Native**（hotwire_native_rails）：原生移动端壳集成
- **PostgreSQL 17**、Active Storage（本地磁盘 / 生产 S3）
- **Tailwind CSS 4**、Solid Queue/Cache/Cable（生产无需 Redis）
- ActiveRecord 加密（身份证号）、18 岁年龄校验、限流防刷

## 🚀 快速开始

```bash
# 1. 环境要求：Ruby 4.0+、PostgreSQL 15+
gem install rails

# 2. 安装依赖并初始化
cd qingyu
bundle install
bin/rails db:create db:migrate db:seed

# 3. 启动（Tailwind 自动构建）
bin/rails server
```

打开 http://localhost:3000 —— 登录、实名认证、完善资料后即进入每日推荐。

### 演示账号

| 角色 | 账号 | 说明 |
|---|---|---|
| 普通用户 | 任意手机号 + 验证码 | 验证码在服务器日志中显示 `[MOCK-SMS]` |
| 演示用户 | `13800000001` ~ `13800000008` | 已实名 V2 + 完整资料 + 照片（种子生成） |
| 管理员 | `admin@qingyu.local` / `Qingyu@2026` | 后台入口 `/admin` |

### Mock 认证演示数据

- **身份证**：18 位校验位合法的号码即可通过；姓名含「李四 / 测试失败 / 无效」会模拟核验失败
- **学信网**（在线验证码 12 位 + 报告编号 16 位）：
  - `100000000001` → 北京大学·本科
  - `200000000002` → 清华大学·硕士
  - `300000000003` → 浙江大学·博士
  - 其余格式合法验证码 → 模拟「未查询到学籍信息」

## 🏗 架构

### 实名认证服务商抽象层

```
app/services/verification/
├── id_card_provider.rb            # 身份证服务商接口
├── id_card/ mock / aliyun / tencent
├── education_provider.rb          # 学信网服务商接口
├── education/ mock / xuexin / aliyun
├── id_card_verification_service.rb      # 核验 + 落库 + 等级更新
└── education_verification_service.rb
```

通过环境变量切换服务商（默认 Mock）：

```bash
ID_CARD_PROVIDER=mock      # mock | aliyun | tencent
EDUCATION_PROVIDER=mock    # mock | xuexin | aliyun
```

生产接入真实服务商：购买相应 API 套餐，在占位 Provider 中实现 `verify` 方法并返回 `Verification::Result` 即可，业务代码零改动。

### 数据模型

`users` → `identity_verifications` / `education_verifications`（实名认证）
→ `photos`（照片，人工审核）→ `interests`（标签）
→ `swipes`（滑卡）→ `matches`（配对）→ `match_memberships`（未读）→ `messages`（聊天）
→ `blocks`（拉黑）→ `admin_users`（后台）

### 认证等级

- `V0` 未认证 → 无法浏览/匹配
- `V1` 身份证核验通过
- `V2` 身份证 + 学信网核验通过

## 📱 Hotwire Native 移动端

服务端已就绪（`/hotwire_native/v1/{ios,android}/path_configuration`、原生 Tab、Strada bridge 骨架）。

### Android APK（GitHub Actions 云端构建）

`android/` 目录是完整的 Hotwire Native Android 壳工程（Kotlin + dev.hotwire:core / navigation-fragments），
含原生底部 Tab（推荐/消息/我的），页面全部由 Rails 服务端渲染。

**构建 APK 步骤：**

1. 把项目推到 GitHub：
   ```bash
   git remote add origin https://github.com/<你的账号>/qingyu.git
   git push -u origin main
   ```
2. 打开 GitHub 仓库 → **Actions** → **Build Android APK** → **Run workflow**（推送 `android/**` 改动也会自动触发）
3. 构建完成后进入该次运行 → **Artifacts** → 下载 `qingyu-debug-apk`（内含 APK）

**APK 连接哪个后端？**

- 默认 `http://10.0.2.2:3000`（Android 模拟器 → 开发机 localhost）
- 真机调试：手机与电脑同一局域网，用电脑局域网 IP 覆盖：
  ```bash
  gradle -p android :app:assembleDebug -PQINGYU_BASE_URL=http://192.168.x.x:3000
  # 或在 android/app/build.gradle.kts 中直接修改默认值
  ```
- 注意：APK 是开发调试版（`usesCleartextTraffic` 允许 HTTP）；生产应部署 HTTPS 后端并移除该开关

**本地构建**（需 Android Studio + Android SDK）：用 Android Studio 打开 `android/` 目录，
或命令行 `./gradlew -p android :app:assembleDebug`。

### iOS

iOS 壳需 macOS/Xcode 编译（本仓库不含壳源码，均为服务端集成），
可使用 Hotwire Native 官方模板指向本服务端。

原生壳 UA 含 `Turbo Native`，服务端自动切换 `:native` 视图变体与原生标题/视口。

## 🔒 安全与合规

- 身份证号经 ActiveRecord 加密存储（开发密钥在 `config/environments/{development,test}.rb`，生产通过 `RAILS_ENCRYPTION_*` 注入）
- 手机号/身份证号等敏感参数默认过滤日志
- 强制 18 周岁（生日校验 + 前端限制）
- 验证码 5 分钟有效、5 次尝试上限、接口限流（3 次/分钟获取、10 次/3 分钟登录）
- 图片类型/大小白名单校验；照片需人工审核后公开展示

## ✅ 测试

```bash
bin/rails test
```

79 个测试覆盖：认证校验/加密、Mock 服务商、推荐过滤、配对、聊天未读、后台审核、Native 端点。
（Windows 下线程并行加载 fixtures 会触发 PG 死锁，已默认单线程；CI 可用 `PARALLEL_WORKERS` 覆盖。）

## 🌍 部署

Rails 8 标配 Docker + Kamal：

```bash
docker build -t qingyu .
bin/kamal setup   # 生产部署（需配置 config/deploy.yml 与 .kamal/secrets）
```

生产必配环境变量：

```bash
SECRET_KEY_BASE=...                    RAILS_MASTER_KEY=...
QINGYU_DATABASE_PASSWORD=...           RAILS_ENCRYPTION_PRIMARY_KEY=...
RAILS_ENCRYPTION_DETERMINISTIC_KEY=... RAILS_ENCRYPTION_KEY_DERIVATION_SALT=...
ID_CARD_PROVIDER=aliyun                EDUCATION_PROVIDER=xuexin   # 真实服务商
```
