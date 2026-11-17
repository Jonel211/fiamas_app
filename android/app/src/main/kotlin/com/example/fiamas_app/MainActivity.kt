package com.example.fiamas_app

import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val canal = "fiamas/whatsapp"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, canal)
            .setMethodCallHandler { call, result ->
                if (call.method == "enviarImagen") {
                    val telefono = call.argument<String>("telefono") ?: ""
                    val ruta = call.argument<String>("ruta") ?: ""
                    val texto = call.argument<String>("texto") ?: ""
                    result.success(enviarImagen(telefono, ruta, texto))
                } else {
                    result.notImplemented()
                }
            }
    }

    /// Abre WhatsApp (normal o Business) en el chat del número, con la imagen adjunta.
    /// Devuelve false si no se pudo, para que Flutter use la hoja de compartir.
    private fun enviarImagen(telefono: String, ruta: String, texto: String): Boolean {
        val archivo = File(ruta)
        if (telefono.isEmpty() || !archivo.exists()) return false

        val uri = try {
            FileProvider.getUriForFile(this, "$packageName.fiamasfileprovider", archivo)
        } catch (e: Exception) {
            return false
        }

        val paquetes = listOf("com.whatsapp", "com.whatsapp.w4b")
        for (paquete in paquetes) {
            if (packageManager.getLaunchIntentForPackage(paquete) == null) continue
            try {
                val intent = Intent(Intent.ACTION_SEND).apply {
                    type = "image/png"
                    setPackage(paquete)
                    putExtra(Intent.EXTRA_STREAM, uri)
                    putExtra(Intent.EXTRA_TEXT, texto)
                    putExtra("jid", "$telefono@s.whatsapp.net")
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }
                grantUriPermission(paquete, uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
                startActivity(intent)
                return true
            } catch (e: Exception) {
                // probar el siguiente paquete
            }
        }
        return false
    }
}