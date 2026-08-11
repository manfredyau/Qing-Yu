package com.qingyu.app

import android.app.Application
import dev.hotwire.core.config.Hotwire
import dev.hotwire.core.turbo.config.PathConfiguration

/**
 * 轻遇 · Hotwire Native 壳应用
 * - 设置 UA 前缀（含 "Turbo Native"，供服务端识别原生壳并切换 :native 视图变体）
 * - 加载服务端的 Path Configuration（决定各页面 modal/push 呈现方式）
 */
class QingyuApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        Hotwire.config.applicationUserAgentPrefix = "Turbo Native; Qingyu;"
        Hotwire.config.webViewDebuggingEnabled = BuildConfig.DEBUG

        Hotwire.loadPathConfiguration(
            context = this,
            location = PathConfiguration.Location(
                remoteFileUrl = "${ServerConfig.getBaseUrl(this)}/hotwire_native/v1/android/path_configuration"
            )
        )
    }
}
