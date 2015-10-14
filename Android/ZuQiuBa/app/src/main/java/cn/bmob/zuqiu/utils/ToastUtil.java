package cn.bmob.zuqiu.utils;

import android.content.Context;
import android.widget.Toast;

/**
 * 保证屏幕上只有一个toast
 * @author kingofglory
 *
 */
public class ToastUtil {
    private static Toast toast;
    
    public static void showToast(Context context,String text){
        if(toast == null){
            toast = Toast.makeText(context, text, Toast.LENGTH_SHORT);
        }else{
            toast.setText(text);
        }
        toast.show();
    }
    

    public static void cancleToast(){
        if(toast!=null){
            toast.cancel();
        }
    }
}
