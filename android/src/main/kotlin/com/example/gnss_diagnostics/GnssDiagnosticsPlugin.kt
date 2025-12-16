package com.example.gnss_diagnostics

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.GnssStatus
import android.location.LocationManager
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel

class GnssDiagnosticsPlugin : FlutterPlugin, EventChannel.StreamHandler {

    private lateinit var context: Context
    private var locationManager: LocationManager? = null
    private var eventSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())

    private val channelName = "gnss_diagnostics/status"

    private val gnssStatusCallback = object : GnssStatus.Callback() {
        override fun onSatelliteStatusChanged(@NonNull status: GnssStatus) {
            if (eventSink == null) return

            val constellationMap = mutableMapOf<String, IntArray>()
            val totalInView = status.satelliteCount
            var totalUsedInFix = 0

            for (i in 0 until status.satelliteCount) {
                val usedInFix = status.usedInFix(i)
                if (usedInFix) totalUsedInFix++

                val constellation = when (status.getConstellationType(i)) {
                    GnssStatus.CONSTELLATION_GPS -> "GPS"
                    GnssStatus.CONSTELLATION_GALILEO -> "GALILEO"
                    GnssStatus.CONSTELLATION_GLONASS -> "GLONASS"
                    GnssStatus.CONSTELLATION_BEIDOU -> "BEIDOU"
                    GnssStatus.CONSTELLATION_QZSS -> "QZSS"
                    GnssStatus.CONSTELLATION_SBAS -> "SBAS"
                    GnssStatus.CONSTELLATION_IRNSS -> "IRNSS"
                    else -> "UNKNOWN"
                }

                val counts = constellationMap.getOrPut(constellation) { intArrayOf(0, 0) }
                counts[0]++
                if (usedInFix) counts[1]++
            }

            val constellationPayload = mutableMapOf<String, Map<String, Int>>()
            for ((key, value) in constellationMap) {
                constellationPayload[key] = mapOf(
                    "inView" to value[0],
                    "usedInFix" to value[1]
                )
            }

            val payload = mapOf(
                "totalInView" to totalInView,
                "totalUsedInFix" to totalUsedInFix,
                "constellations" to constellationPayload
            )

            android.util.Log.d("GNSS_DIAGN_TEST", "Satellite update: $payload")
            eventSink?.success(payload)
        }
    }

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager

        val eventChannel = EventChannel(binding.binaryMessenger, channelName)
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        stopGnssListening()
        locationManager = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        android.util.Log.d("GNSS_DIAGN_TEST", "onListen called")

        // Emit immediate empty/default snapshot
        val emptyPayload = mapOf(
            "totalInView" to 0,
            "totalUsedInFix" to 0,
            "constellations" to mapOf<String, Map<String, Int>>()
        )
        eventSink?.success(emptyPayload)

        startGnssListening()
    }

    override fun onCancel(arguments: Any?) {
        android.util.Log.d("GNSS_DIAGN_TEST", "onCancel called")
        stopGnssListening()
        eventSink = null
    }

    private fun startGnssListening() {
        if (locationManager == null) return

        val permissionGranted = ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED

        if (!permissionGranted) {
            android.util.Log.w("GNSS_DIAGN_TEST", "Permission denied")
            eventSink?.error("PERMISSION_DENIED", "ACCESS_FINE_LOCATION permission not granted", null)
            return
        }

        try {
            val registered = locationManager?.registerGnssStatusCallback(gnssStatusCallback, handler)
            android.util.Log.d("GNSS_DIAGN_TEST", "GNSS status callback registered: $registered")
        } catch (e: Exception) {
            android.util.Log.e("GNSS_DIAGN_TEST", "Failed to register GNSS callback", e)
            eventSink?.error("GNSS_ERROR", "Failed to register GNSS status callback", e.localizedMessage)
        }
    }

    private fun stopGnssListening() {
        try {
            locationManager?.unregisterGnssStatusCallback(gnssStatusCallback)
            android.util.Log.d("GNSS_DIAGN_TEST", "GNSS status callback unregistered")
        } catch (_: Exception) { }
    }
}
