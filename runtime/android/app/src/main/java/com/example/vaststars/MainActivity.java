package com.example.vaststars;

import android.os.Bundle;
import android.view.View;
import android.view.MotionEvent;
import com.google.androidgamesdk.GameActivity;

public class MainActivity extends GameActivity {
    static {
        System.loadLibrary("vaststars");
    }

    private GestureHandler gesture_handler;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        gesture_handler = new GestureHandler(this, super.getGameActivityNativeHandle());
    }

    @Override
    protected void onDestroy() {
        gesture_handler.onDestroy();
        gesture_handler = null;
        super.onDestroy();
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        gesture_handler.onTouchEvent(event);
        return true;
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);

        if (hasFocus) {
            hideSystemUi();
        }
    }

    private void hideSystemUi() {
        View decorView = getWindow().getDecorView();
        decorView.setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                        | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                        | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                        | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                        | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                        | View.SYSTEM_UI_FLAG_FULLSCREEN
        );
    }
}
