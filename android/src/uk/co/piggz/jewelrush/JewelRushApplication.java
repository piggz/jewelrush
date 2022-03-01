package uk.co.piggz.jewelrush;
import android.util.Log;

public class JewelRushApplication extends org.qtproject.qt5.android.bindings.QtApplication {
    static {
        Log.e("Jewel Rush Starting", "**********");
    }
    @Override
    public void onCreate() {
        super.onCreate();
        InAppConfig.init();
    }
} 
