package com.example.flutter1

import java.util.TimeZone
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val timezoneChannelName = "app.timezone"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, timezoneChannelName)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"getTimeZone" -> result.success(TimeZone.getDefault().id)
					else -> result.notImplemented()
				}
			}
	}
}
