package cn.bmob.zuqiu.utils;

import android.util.Log;

/**
 * Logger开关类，发布时请注意手动置为false;
 */
public class LogUtil {

    private static final boolean DEBUG = true;
    
    public static void v(String tag, String msg) {
        if(DEBUG) {
            if(msg != null) {
                Log.v(tag, msg);
            }

        }

    }

    public static void d(String tag, String msg) {
        if(DEBUG) {
            if(msg != null) {
                Log.d(tag, msg);
            }
        }

    }

    public static void i(String tag, String msg) {
        if(DEBUG) {
            if(msg != null) {
                Log.i(tag, msg);
            }
        }

    }

    public static void w(String tag, String msg) {
        if(DEBUG) {
            if(msg != null) {
                Log.w(tag, msg);
            }
        }

    }

    public static void e(String tag, String msg) {
        if(DEBUG) {
            if(msg != null) {
                Log.e(tag, msg);
            }
        }

    }
}
