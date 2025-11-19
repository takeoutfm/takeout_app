package com.takeoutfm.watch

import android.os.Bundle
import android.view.MotionEvent
import io.flutter.embedding.android.FlutterActivity
import com.samsung.wearable_rotary.WearableRotaryPlugin
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity : AudioServiceActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        intent.putExtra("background_mode", "transparent")
    }

    override fun onGenericMotionEvent(event: MotionEvent?): Boolean {
        return when {
            WearableRotaryPlugin.onGenericMotionEvent(event) -> true
            else -> super.onGenericMotionEvent(event)
        }
    }

}
