package com.test.test.camera_test_task

import android.content.ContentValues
import android.os.Build
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.IOException

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.test.test.camera_test_task/media_store"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveImage" -> {
                    val path = call.argument<String>("path")
                    val displayName = call.argument<String>("displayName")
                    if (path != null && displayName != null) {
                        val success = saveImageToGallery(path, displayName)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Path and displayName are required", null)
                    }
                }
                "saveVideo" -> {
                    val path = call.argument<String>("path")
                    val displayName = call.argument<String>("displayName")
                    if (path != null && displayName != null) {
                        val success = saveVideoToGallery(path, displayName)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Path and displayName are required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun saveImageToGallery(imagePath: String, displayName: String): Boolean {
        return try {
            val imageFile = File(imagePath)
            if (!imageFile.exists()) {
                return false
            }

            val contentValues = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, displayName)
                put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
                put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/CameraApp")
            }

            val resolver = contentResolver
            val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)

            if (uri != null) {
                resolver.openOutputStream(uri)?.use { outputStream ->
                    FileInputStream(imageFile).use { inputStream ->
                        inputStream.copyTo(outputStream)
                    }
                }
                true
            } else {
                false
            }
        } catch (e: IOException) {
            e.printStackTrace()
            false
        }
    }

    private fun saveVideoToGallery(videoPath: String, displayName: String): Boolean {
        return try {
            val videoFile = File(videoPath)
            if (!videoFile.exists()) {
                return false
            }

            val contentValues = ContentValues().apply {
                put(MediaStore.Video.Media.DISPLAY_NAME, displayName)
                put(MediaStore.Video.Media.MIME_TYPE, "video/mp4")
                put(MediaStore.Video.Media.RELATIVE_PATH, "Movies/CameraApp")
            }

            val resolver = contentResolver
            val uri = resolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, contentValues)

            if (uri != null) {
                resolver.openOutputStream(uri)?.use { outputStream ->
                    FileInputStream(videoFile).use { inputStream ->
                        inputStream.copyTo(outputStream)
                    }
                }
                true
            } else {
                false
            }
        } catch (e: IOException) {
            e.printStackTrace()
            false
        }
    }
}