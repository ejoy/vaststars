package com.example.vaststars;

import android.content.Context;
import android.util.Log;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import androidx.core.view.GestureDetectorCompat;

public class GestureHandler implements GestureDetector.OnGestureListener, ScaleGestureDetector.OnScaleGestureListener {
    private static final String DEBUG_TAG = "Gestures";
    private GestureDetectorCompat simple_detector;
    private ScaleGestureDetector scale_detector;
    private boolean scaling;
    private long nativeHandle;

    private native void nativeInitialize(long handle);
    private native void nativeDestroy(long handle);
    private native void nativeOnTap(long handle, float x, float y);
    private native void nativeOnLongPress(long handle, float x, float y);
    private native void nativeOnPan(long handle, float x, float y, float dx, float dy, float vx, float vy);
    private native void nativeOnPinch(long handle, int state, float x, float y, float velocity);

    public GestureHandler(Context context, long handle) {
        simple_detector = new GestureDetectorCompat(context, this);
        scale_detector = new ScaleGestureDetector(context, this);
        scaling = false;
        nativeHandle = handle;
        nativeInitialize(nativeHandle);
    }
    protected void onDestroy() {
        nativeDestroy(nativeHandle);
    }

    public boolean onTouchEvent(MotionEvent event) {
        scale_detector.onTouchEvent(event);
        simple_detector.onTouchEvent(event);
        return true;
    }

    @Override
    public boolean onFling(MotionEvent event1, MotionEvent event2, float velocityX, float velocityY) {
        return false;
    }

    @Override
    public boolean onDown(MotionEvent event) {
        scaling = false;
        return false;
    }

    @Override
    public void onShowPress(MotionEvent event) {
    }

    @Override
    public boolean onSingleTapUp(MotionEvent event) {
        final int actionIndex = event.getActionIndex();
        nativeOnTap(nativeHandle, event.getX(actionIndex), event.getY(actionIndex));
        return true;
    }

    @Override
    public void onLongPress(MotionEvent event) {
        final int actionIndex = event.getActionIndex();
        nativeOnLongPress(nativeHandle, event.getX(actionIndex), event.getY(actionIndex));
    }

    @Override
    public boolean onScroll(MotionEvent event1, MotionEvent event2, float distanceX, float distanceY) {
        if (scaling) {
            return false;
        }
        final float x1 = event1.getX(event1.getActionIndex());
        final float y1 = event1.getY(event1.getActionIndex());
        final float x2 = event2.getX(event2.getActionIndex());
        final float y2 = event2.getY(event2.getActionIndex());
        nativeOnPan(nativeHandle, x2, y2, distanceX, distanceY, x2-x1, y2-y1);
        return true;
    }

    private float getScaleVelocity(ScaleGestureDetector detector) {
        final float factor =  detector.getScaleFactor();
        final float delta =  detector.getTimeDelta();
        return (factor-1.f) * 1000.f / delta;
    }

    @Override
    public boolean onScaleBegin(ScaleGestureDetector detector) {
        nativeOnPinch(nativeHandle, 0, detector.getFocusX(), detector.getFocusY(), getScaleVelocity(detector));
        return true;
    }

    @Override
    public boolean onScale(ScaleGestureDetector detector) {
        scaling = true;
        nativeOnPinch(nativeHandle, 1, detector.getFocusX(), detector.getFocusY(), getScaleVelocity(detector));
        return true;
    }

    @Override
    public void onScaleEnd(ScaleGestureDetector detector) {
        nativeOnPinch(nativeHandle, 2, detector.getFocusX(), detector.getFocusY(), getScaleVelocity(detector));
    }
}
