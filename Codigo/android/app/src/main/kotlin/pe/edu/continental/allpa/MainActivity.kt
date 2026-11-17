package pe.edu.continental.allpa

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.content.ClipData
import androidx.core.content.FileProvider
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "allpa/respaldo")
            .setMethodCallHandler { call, result ->
                if (call.method != "compartir") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                try {
                    val ruta = call.argument<String>("ruta")
                        ?: throw IllegalArgumentException("Falta el archivo de respaldo.")
                    val origen = File(ruta).canonicalFile
                    val permitido = File(filesDir, "respaldo_illpe.json").canonicalFile
                    require(origen == permitido && origen.isFile) {
                        "No se encontró el respaldo de Allpa. Créalo nuevamente."
                    }
                    val carpeta = File(cacheDir, "respaldos")
                    check(carpeta.isDirectory || carpeta.mkdirs()) { "No se pudo preparar el respaldo." }
                    val fecha = SimpleDateFormat("yyyyMMdd_HHmmss_SSS", Locale.ROOT).format(Date())
                    val copia = File(carpeta, "ALLPA_respaldo_$fecha.json")
                    origen.copyTo(copia, overwrite = false)
                    val uri = FileProvider.getUriForFile(this, "$packageName.respaldos", copia)
                    val envio = Intent(Intent.ACTION_SEND).apply {
                        type = "application/json"
                        putExtra(Intent.EXTRA_STREAM, uri)
                        putExtra(Intent.EXTRA_SUBJECT, "Respaldo de ALLPA")
                        clipData = ClipData.newRawUri("Respaldo de ALLPA", uri)
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    }
                    startActivity(Intent.createChooser(envio, "Compartir respaldo de ALLPA"))
                    result.success(null)
                } catch (error: Exception) {
                    result.error("RESPALDO_NO_COMPARTIDO", "No se pudo abrir el menú para compartir el respaldo.", null)
                }
            }
    }
}
