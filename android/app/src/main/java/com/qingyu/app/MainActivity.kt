package com.qingyu.app

import android.os.Bundle
import android.view.View
import androidx.activity.enableEdgeToEdge
import dev.hotwire.navigation.activities.HotwireActivity
import dev.hotwire.navigation.navigator.NavigatorConfiguration
import dev.hotwire.navigation.tabs.HotwireBottomNavigationController
import dev.hotwire.navigation.tabs.HotwireBottomTab
import dev.hotwire.navigation.tabs.navigatorConfigurations
import dev.hotwire.navigation.util.applyDefaultImeWindowInsets

/**
 * 主界面：原生底部 Tab（每日推荐 / 消息 / 我的）+ 每个 Tab 独立导航栈。
 * 页面内容全部由 Rails 服务端渲染（Hotwire Native 服务端驱动）。
 */
class MainActivity : HotwireActivity() {

    private lateinit var bottomNavigationController: HotwireBottomNavigationController

    // 三个原生 Tab 的目标地址对应服务端 /hotwire_native/tab1|2|3（再重定向到真实页面）
    private val tabs: List<HotwireBottomTab> by lazy {
        val baseUrl = ServerConfig.getBaseUrl(this)
        listOf(
            HotwireBottomTab(
                title = getString(R.string.tab_feed),
                iconResId = R.drawable.ic_tab_feed,
                configuration = NavigatorConfiguration(
                    name = "feed",
                    navigatorHostId = R.id.feed_navigator_host,
                    startLocation = "$baseUrl/hotwire_native/tab1"
                )
            ),
            HotwireBottomTab(
                title = getString(R.string.tab_messages),
                iconResId = R.drawable.ic_tab_messages,
                configuration = NavigatorConfiguration(
                    name = "messages",
                    navigatorHostId = R.id.messages_navigator_host,
                    startLocation = "$baseUrl/hotwire_native/tab2"
                )
            ),
            HotwireBottomTab(
                title = getString(R.string.tab_profile),
                iconResId = R.drawable.ic_tab_profile,
                configuration = NavigatorConfiguration(
                    name = "profile",
                    navigatorHostId = R.id.profile_navigator_host,
                    startLocation = "$baseUrl/hotwire_native/tab3"
                )
            )
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        findViewById<View>(R.id.root).applyDefaultImeWindowInsets()

        bottomNavigationController = HotwireBottomNavigationController(
            activity = this,
            view = findViewById(R.id.bottom_nav),
            lazyLoadTabs = true   // 懒加载：Tab 首次选中才加载，避免登录前的旧页面残留
        )
        bottomNavigationController.load(tabs)
        // 每次进入 App 默认「推荐」Tab（而非恢复上次选中的 Tab）
        bottomNavigationController.selectTab(0)
    }

    // 从系统恢复（如从最近任务重新打开）时同样强制回到「推荐」
    override fun onRestoreInstanceState(savedInstanceState: Bundle) {
        super.onRestoreInstanceState(savedInstanceState)
        if (::bottomNavigationController.isInitialized) {
            bottomNavigationController.selectTab(0)
        }
    }

    override fun navigatorConfigurations() = tabs.navigatorConfigurations
}
