package com.qingyu.app

import android.content.Context

/**
 * 服务器地址配置（本地持久化）
 * 开发调试：真机在「连接页」直接输入局域网地址，无需重新构建 APK。
 * 生产环境：应使用 BuildConfig.BASE_URL 固定为正式域名。
 */
object ServerConfig {
    private const val PREFS = "qingyu_prefs"
    private const val KEY_BASE_URL = "base_url"

    fun getBaseUrl(context: Context): String =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString(KEY_BASE_URL, null)
            ?: BuildConfig.BASE_URL

    fun saveBaseUrl(context: Context, url: String) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_BASE_URL, url.trim().trimEnd('/'))
            .apply()
    }
}
