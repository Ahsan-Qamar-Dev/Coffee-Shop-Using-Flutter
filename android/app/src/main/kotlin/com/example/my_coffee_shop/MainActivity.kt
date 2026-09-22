package com.example.my_coffee_shop

import android.os.Build
import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var receiptResult: MethodChannel.Result? = null
    private var receiptBytes: ByteArray? = null
    private val saveReceiptRequest = 4107

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "coffee_shop/receipt")
            .setMethodCallHandler { call, result ->
                if (call.method != "savePdf") {
                    result.notImplemented()
                } else if (receiptResult != null) {
                    result.error("busy", "A receipt is already being saved.", null)
                } else {
                    val bytes = call.argument<ByteArray>("bytes")
                    if (bytes == null || bytes.isEmpty()) {
                        result.error("invalid_pdf", "Receipt data is empty.", null)
                        return@setMethodCallHandler
                    }
                    receiptBytes = bytes
                    receiptResult = result
                    val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE)
                        type = "application/pdf"
                        putExtra(Intent.EXTRA_TITLE, call.argument<String>("name") ?: "receipt.pdf")
                    }
                    try {
                        startActivityForResult(intent, saveReceiptRequest)
                    } catch (error: Exception) {
                        receiptBytes = null
                        receiptResult = null
                        result.error("save_unavailable", error.message, null)
                    }
                }
            }
    }

    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != saveReceiptRequest) return
        val result = receiptResult ?: return
        val bytes = receiptBytes
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK) {
            receiptBytes = null
            receiptResult = null
            result.success(false)
            return
        }
        if (uri == null || bytes == null) {
            receiptBytes = null
            receiptResult = null
            result.error("invalid_destination", "No save destination was returned.", null)
            return
        }
        // File providers can be slow; keep writing off the animation/UI thread.
        Thread {
            try {
                contentResolver.openOutputStream(uri, "wt").use { stream ->
                    checkNotNull(stream) { "Could not open the selected file." }
                    stream.write(bytes)
                }
                runOnUiThread {
                    receiptBytes = null
                    receiptResult = null
                    result.success(true)
                }
            } catch (error: Exception) {
                runOnUiThread {
                    receiptBytes = null
                    receiptResult = null
                    result.error("save_failed", error.message, null)
                }
            }
        }.start()
    }

    override fun onResume() {
        super.onResume()
        requestHighRefreshRate()
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) requestHighRefreshRate()
    }

    @Suppress("DEPRECATION")
    private fun requestHighRefreshRate() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        val activeDisplay = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            display
        } else {
            windowManager.defaultDisplay
        } ?: return
        val current = activeDisplay.mode
        // Keep the current resolution. The small tolerance handles 120.00001 Hz.
        val target = activeDisplay.supportedModes
            .filter { it.physicalWidth == current.physicalWidth &&
                it.physicalHeight == current.physicalHeight && it.refreshRate <= 120.1f }
            .maxByOrNull { it.refreshRate } ?: return
        val params = window.attributes
        if (params.preferredRefreshRate == target.refreshRate) return
        // A preference, not a forced mode: Android retains power/thermal/user control.
        params.preferredRefreshRate = target.refreshRate
        window.attributes = params
    }
}
