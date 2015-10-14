/*
 * Copyright 2013 David Schreiber
 *           2013 John Paul Nalog
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

package at.technikum.mti.fancycoverflow;

import cn.bmob.zuqiu.R;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.*;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.view.ViewGroup;
import android.view.animation.Transformation;
import android.widget.Gallery;
import android.widget.SpinnerAdapter;

public class FancyCoverFlow extends Gallery {

    // =============================================================================
    // Constants
    // =============================================================================

    public static final int ACTION_DISTANCE_AUTO = Integer.MAX_VALUE;

    public static final float SCALEDOWN_GRAVITY_TOP = 0.0f;

    public static final float SCALEDOWN_GRAVITY_CENTER = 0.5f;

    public static final float SCALEDOWN_GRAVITY_BOTTOM = 1.0f;

    // =============================================================================
    // Private members
    // =============================================================================

    private float reflectionRatio = 0.4f;

    private int reflectionGap = 20;

    private boolean reflectionEnabled = false;

    /**
     * TODO: Doc
     */
    private float unselectedAlpha;

    /**
     * Camera used for view transformation.
     */
    private Camera transformationCamera;

    /**
     * TODO: Doc
     */
    private int maxRotation = 75;

    /**
     * Factor (0-1) that defines how much the unselected children should be scaled down. 1 means no scaledown.
     */
    private float unselectedScale;

    /**
     * TODO: Doc
     */
    private float scaleDownGravity = SCALEDOWN_GRAVITY_CENTER;

    /**
     * Distance in pixels between the transformation effects (alpha, rotation, zoom) are applied.
     */
    private int actionDistance;

    /**
     * Saturation factor (0-1) of items that reach the outer effects distance.
     */
    private float unselectedSaturation;

    // =============================================================================
    // Constructors
    // =============================================================================

    private float mLastMotionX;//滑动过程中，x方向的初始坐标
    private float mLastMotionY;//滑动过程中，y方向的初始坐标
    private int mTouchSlop;//手指大小的距离
    
    public FancyCoverFlow(Context context) {
        super(context);
        this.initialize();
    }

    public FancyCoverFlow(Context context, AttributeSet attrs) {
        super(context, attrs);
        this.initialize();
        this.applyXmlAttributes(attrs);
    }

    public FancyCoverFlow(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        this.initialize();
        this.applyXmlAttributes(attrs);
    }

    private void init() {
        final ViewConfiguration configuration = ViewConfiguration
                .get(getContext());
        mTouchSlop = configuration.getScaledTouchSlop();
    }
    
    private void initialize() {
        this.transformationCamera = new Camera();
        this.setSpacing(0);
        init();
    }
    
    /*
     * 重写的方法，最关键的地方
     * */
    
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        final int action = ev.getAction();//获取触摸事件类型
        final float x = ev.getX();//每次触摸事件的x坐标
        final float y = ev.getY();//每次触摸事件的y坐标
        switch (action) {
        case MotionEvent.ACTION_DOWN://按下事件
            mLastMotionX = x;//初始化每次触摸事件的x方向的初始坐标，即手指按下的x方向坐标
            mLastMotionY = y;//初始化每次触摸事件的y方向的初始坐标，即手指按下的y方向坐标
            break;

        case MotionEvent.ACTION_MOVE:
            final int deltaX = (int) (mLastMotionX - x);//每次滑动事件x方向坐标与触摸事件x方向初始坐标的距离
            final int deltaY = (int) (mLastMotionY - y);//每次滑动事件y方向坐标与触摸事件y方向初始坐标的距离
            boolean xMoved = Math.abs(deltaX) > mTouchSlop && Math.abs(deltaY/deltaX) < 1;
            //判断触摸事件处理的传递方向，该业务中是，
            //x方向的距离大于手指，并且y方向滑动的距离小于x方向的滑动距离时，Gallery消费掉此次触摸事件
            //如果需要，请在您的业务中，改变判断的逻辑
            if (xMoved) {//Gallery需要消费掉此次触摸事件
                return true;//返回true就不会将此次触摸事件传递给子View了，我的业务中是ListView
            }
            break;
        }
        return false;//将此次触摸事件传递给子View，即ListView
    }
    

    private void applyXmlAttributes(AttributeSet attrs) {
        TypedArray a = getContext().obtainStyledAttributes(attrs, R.styleable.FancyCoverFlow);

        this.actionDistance = a.getInteger(R.styleable.FancyCoverFlow_actionDistance, ACTION_DISTANCE_AUTO);
        this.scaleDownGravity = a.getFloat(R.styleable.FancyCoverFlow_scaleDownGravity, 1.0f);
        this.maxRotation = a.getInteger(R.styleable.FancyCoverFlow_maxRotation, 45);
        this.unselectedAlpha = a.getFloat(R.styleable.FancyCoverFlow_unselectedAlpha, 0.3f);
        this.unselectedSaturation = a.getFloat(R.styleable.FancyCoverFlow_unselectedSaturation, 0.0f);
        this.unselectedScale = a.getFloat(R.styleable.FancyCoverFlow_unselectedScale, 0.75f);
    }

    // =============================================================================
    // Getter / Setter
    // =============================================================================

    public float getReflectionRatio() {
        return reflectionRatio;
    }

    public void setReflectionRatio(float reflectionRatio) {
        if (reflectionRatio <= 0 || reflectionRatio > 0.5f) {
            throw new IllegalArgumentException("reflectionRatio may only be in the interval (0, 0.5]");
        }

        this.reflectionRatio = reflectionRatio;

        if (this.getAdapter() != null) {
            ((FancyCoverFlowAdapter) this.getAdapter()).notifyDataSetChanged();
        }
    }

    public int getReflectionGap() {
        return reflectionGap;
    }

    public void setReflectionGap(int reflectionGap) {
        this.reflectionGap = reflectionGap;

        if (this.getAdapter() != null) {
            ((FancyCoverFlowAdapter) this.getAdapter()).notifyDataSetChanged();
        }
    }

    public boolean isReflectionEnabled() {
        return reflectionEnabled;
    }

    public void setReflectionEnabled(boolean reflectionEnabled) {
        this.reflectionEnabled = reflectionEnabled;

        if (this.getAdapter() != null) {
            ((FancyCoverFlowAdapter) this.getAdapter()).notifyDataSetChanged();
        }
    }

    /**
     * Use this to provide a {@link FancyCoverFlowAdapter} to the coverflow. This
     * method will throw an {@link ClassCastException} if the passed adapter does not
     * subclass {@link FancyCoverFlowAdapter}.
     *
     * @param adapter
     */
    @Override
    public void setAdapter(SpinnerAdapter adapter) {
        if (!(adapter instanceof FancyCoverFlowAdapter)) {
            throw new ClassCastException(FancyCoverFlow.class.getSimpleName() + " only works in conjunction with a " + FancyCoverFlowAdapter.class.getSimpleName());
        }

        super.setAdapter(adapter);
    }

    /**
     * Returns the maximum rotation that is applied to items left and right of the center of the coverflow.
     *
     * @return
     */
    public int getMaxRotation() {
        return maxRotation;
    }

    /**
     * Sets the maximum rotation that is applied to items left and right of the center of the coverflow.
     *
     * @param maxRotation
     */
    public void setMaxRotation(int maxRotation) {
        this.maxRotation = maxRotation;
    }

    /**
     * TODO: Write doc
     *
     * @return
     */
    public float getUnselectedAlpha() {
        return this.unselectedAlpha;
    }

    /**
     * TODO: Write doc
     *
     * @return
     */
    public float getUnselectedScale() {
        return unselectedScale;
    }

    /**
     * TODO: Write doc
     *
     * @param unselectedScale
     */
    public void setUnselectedScale(float unselectedScale) {
        this.unselectedScale = unselectedScale;
    }

    /**
     * TODO: Doc
     *
     * @return
     */
    public float getScaleDownGravity() {
        return scaleDownGravity;
    }

    /**
     * TODO: Doc
     *
     * @param scaleDownGravity
     */
    public void setScaleDownGravity(float scaleDownGravity) {
        this.scaleDownGravity = scaleDownGravity;
    }

    /**
     * TODO: Write doc
     *
     * @return
     */
    public int getActionDistance() {
        return actionDistance;
    }

    /**
     * TODO: Write doc
     *
     * @param actionDistance
     */
    public void setActionDistance(int actionDistance) {
        this.actionDistance = actionDistance;
    }

    /**
     * TODO: Write doc
     *
     * @param unselectedAlpha
     */
    @Override
    public void setUnselectedAlpha(float unselectedAlpha) {
        super.setUnselectedAlpha(unselectedAlpha);
        this.unselectedAlpha = unselectedAlpha;
    }

    /**
     * TODO: Write doc
     *
     * @return
     */
    public float getUnselectedSaturation() {
        return unselectedSaturation;
    }

    /**
     * TODO: Write doc
     *
     * @param unselectedSaturation
     */
    public void setUnselectedSaturation(float unselectedSaturation) {
        this.unselectedSaturation = unselectedSaturation;
    }

    // =============================================================================
    // Supertype overrides
    // =============================================================================

    @Override
    protected boolean getChildStaticTransformation(View child, Transformation t) {
        // We can cast here because FancyCoverFlowAdapter only creates wrappers.
        FancyCoverFlowItemWrapper item = (FancyCoverFlowItemWrapper) child;

        // Since Jelly Bean childs won't get invalidated automatically, needs to be added for the smooth coverflow animation
        if (android.os.Build.VERSION.SDK_INT >= 16) {
            item.invalidate();
        }

        final int coverFlowWidth = this.getWidth();
        final int coverFlowCenter = coverFlowWidth / 2;
        final int childWidth = item.getWidth();
        final int childHeight = item.getHeight();
        final int childCenter = item.getLeft() + childWidth / 2;

        // Use coverflow width when its defined as automatic.
        final int actionDistance = (this.actionDistance == ACTION_DISTANCE_AUTO) ? (int) ((coverFlowWidth + childWidth) / 2.0f) : this.actionDistance;

        // Calculate the abstract amount for all effects.
        final float effectsAmount = Math.min(1.0f, Math.max(-1.0f, (1.0f / actionDistance) * (childCenter - coverFlowCenter)));

        // Clear previous transformations and set transformation type (matrix + alpha).
        t.clear();
        t.setTransformationType(Transformation.TYPE_BOTH);

        // Alpha
        if (this.unselectedAlpha != 1) {
            final float alphaAmount = (this.unselectedAlpha - 1) * Math.abs(effectsAmount) + 1;
            t.setAlpha(alphaAmount);
        }

        // Saturation
        if (this.unselectedSaturation != 1) {
            // Pass over saturation to the wrapper.
            final float saturationAmount = (this.unselectedSaturation - 1) * Math.abs(effectsAmount) + 1;
            item.setSaturation(saturationAmount);
        }

        final Matrix imageMatrix = t.getMatrix();

        // Apply rotation.
        if (this.maxRotation != 0) {
            final int rotationAngle = (int) (-effectsAmount * this.maxRotation);
            this.transformationCamera.save();
            this.transformationCamera.rotateY(rotationAngle);
            this.transformationCamera.getMatrix(imageMatrix);
            this.transformationCamera.restore();
        }

        // Zoom.
        if (this.unselectedScale != 1) {
            final float zoomAmount = (this.unselectedScale - 1) * Math.abs(effectsAmount) + 1;
            // Calculate the scale anchor (y anchor can be altered)
            final float translateX = childWidth / 2.0f;
            final float translateY = childHeight * this.scaleDownGravity;
            imageMatrix.preTranslate(-translateX, -translateY);
            imageMatrix.postScale(zoomAmount, zoomAmount);//zoonamout
            imageMatrix.postTranslate(translateX, translateY);
        }

        return true;
    }

    // =============================================================================
    // Public classes
    // =============================================================================

    public static class LayoutParams extends Gallery.LayoutParams {
        public LayoutParams(Context c, AttributeSet attrs) {
            super(c, attrs);
        }

        public LayoutParams(int w, int h) {
            super(w, h);
        }

        public LayoutParams(ViewGroup.LayoutParams source) {
            super(source);
        }
    }
}
