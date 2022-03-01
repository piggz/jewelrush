package uk.co.piggz.jewelrush;

import org.onepf.oms.OpenIabHelper;
import org.onepf.oms.SkuManager;

import java.util.HashMap;
import java.util.Map;

/**
 * In-app products configuration.
 */
public final class InAppConfig {
    //noads upgrade (non-consumable)
    public static final String SKU_NOADS = "uk.co.piggz.jewelrush.sku_noads";

    //Google Play
    public static final String GOOGLE_PLAY_KEY = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlH0yXiuoyz+8jN6HmuS1tny3eLaFacfdln6s61zp6b8ChPwvUDj52UCXP7mGEyVQz6KfyLsVidhkPSlH1AnvBWYvJfPmw+xVocFkA+VIW1kWIiA/16gNV9pXQ+Ns2g4d8FZGcZ8s1FUyymT+slMXKwiBRhUEhsonPpqKRF/sZ8rQV7d01af+iO0s225m/ncb5v4qqLtJA0EjmaDmOcwDx5mfwZVVv6XB3Xa4ebcj7I2vNpXmMsFqt7kRrNfsgqXR99FgXccwLFapbgFe19fI5iA1q1H742xXHQLcLh0gKG69Ivv4kUkXcrIxu1Fg+/eJ3mEo2UpfxHCEm4+oIzTzvQIDAQAB";
    public static Map<String, String> STORE_KEYS_MAP;

    public static void init() {
        STORE_KEYS_MAP = new HashMap<String, String>();
        STORE_KEYS_MAP.put(OpenIabHelper.NAME_GOOGLE, InAppConfig.GOOGLE_PLAY_KEY);

//        STORE_KEYS_MAP.put(OpenIabHelper.NAME_AMAZON,
//                "Unavailable. Amazon doesn't support RSA verification. So this mapping is not needed");

        SkuManager.getInstance()
                        //Amazon
                .mapSku(SKU_NOADS, OpenIabHelper.NAME_AMAZON, "uk.co.piggz.jewelrush.sku_noads");
    }

    private InAppConfig() {
    }
}

