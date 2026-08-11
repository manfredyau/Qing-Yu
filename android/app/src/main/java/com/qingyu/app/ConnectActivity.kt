package com.qingyu.app

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import androidx.appcompat.app.AppCompatActivity
import dev.hotwire.core.config.Hotwire
import dev.hotwire.core.turbo.config.PathConfiguration

/**
 * 服务器连接页（启动入口）
 * 开发调试：在此输入后端地址（如 http://192.168.x.x:3000），
 * 保存后进入主界面；地址保存在本机，换网络只需在此修改。
 */
class ConnectActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_connect)

        val urlInput = findViewById<EditText>(R.id.url_input)
        urlInput.setText(ServerConfig.getBaseUrl(this))

        findViewById<Button>(R.id.connect_button).setOnClickListener {
            val url = urlInput.text.toString().trim().trimEnd('/')
            if (url.isNotBlank()) {
                ServerConfig.saveBaseUrl(this, url)
                // 重新加载路径配置（指向新服务器）
                Hotwire.loadPathConfiguration(
                    context = this,
                    location = PathConfiguration.Location(
                        remoteFileUrl = "$url/hotwire_native/v1/android/path_configuration"
                    )
                )
                startActivity(Intent(this, MainActivity::class.java))
                finish()
            } else {
                urlInput.error = "请输入服务器地址"
            }
        }
    }
}
