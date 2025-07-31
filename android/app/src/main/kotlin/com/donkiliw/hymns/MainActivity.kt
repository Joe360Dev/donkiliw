package com.donkiliw.app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.install.model.UpdateAvailability

class MainActivity: FlutterActivity() {
    private var appUpdateManager: AppUpdateManager? = null
    private val REQUEST_CODE_UPDATE = 1001

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        checkForAppUpdate()
    }

    private fun checkForAppUpdate() {
        appUpdateManager = AppUpdateManagerFactory.create(this)
        
        // Returns an intent object that you use to check for an update
        val appUpdateInfoTask = appUpdateManager?.appUpdateInfo
        
        // Check if update is available
        appUpdateInfoTask?.addOnSuccessListener { appUpdateInfo ->
            if (appUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE) {
                // Request the update
                appUpdateManager?.startUpdateFlowForResult(
                    appUpdateInfo,
                    com.google.android.play.core.install.model.AppUpdateType.FLEXIBLE,
                    this,
                    REQUEST_CODE_UPDATE
                )
            }
        }
    }

    override fun onResume() {
        super.onResume()
        checkForAppUpdate()
    }
}
