package uk.co.piggz.jewelrush;

import org.qtproject.qt5.android.bindings.QtApplication;
import org.qtproject.qt5.android.bindings.QtActivity;
import org.json.JSONObject;
import org.json.JSONException;

import android.util.Log;
import android.os.Bundle;
import android.os.IBinder;
import android.content.ServiceConnection;
import android.content.Intent;
import android.content.ComponentName;
import android.content.Context;
import android.content.res.Configuration;
import android.content.pm.ActivityInfo;
import android.app.PendingIntent;
import android.app.Activity;
import android.view.*;
import android.view.animation.*;
import android.view.animation.Animation.AnimationListener;
import android.widget.FrameLayout;
import android.widget.FrameLayout.LayoutParams;
import android.widget.LinearLayout;

import java.util.ArrayList;
import java.util.EnumSet;
import com.amazon.ags.api.*;
import com.amazon.device.ads.*;

import org.onepf.oms.OpenIabHelper;
import org.onepf.oms.appstore.AmazonAppstore;
import org.onepf.oms.appstore.googleUtils.IabHelper;
import org.onepf.oms.appstore.googleUtils.IabResult;
import org.onepf.oms.appstore.googleUtils.Inventory;
import org.onepf.oms.appstore.googleUtils.Purchase;

import org.qtproject.qt5.android.QtLayout;

public class JewelRushActivity extends QtActivity
{
    private static JewelRushActivity m_instance;
    private ViewGroup adViewContainer; // View group to which the ad view will be added.
    private AdLayout currentAdView; // The ad that is currently visible to the user.
    private AdLayout nextAdView; // A placeholder for the next ad so we can keep the current ad visible while the next ad loads.
    private static final String APP_KEY = "b8021cb27bb24d04b47421197eecd3d2";
    private static final String LOG_TAG = "uk.co.piggz.jewelrush"; // tag used to prefix all log messages.
    private Boolean setupDone;  // is billing setup completed
    static final int RC_REQUEST = 10001; // (arbitrary) request code for the purchase flow
    boolean mIsNoAds = false; // Does the user have the no ads upgrade?
    AmazonGamesClient agsClient; //reference to the agsClient
    OpenIabHelper mHelper; // The helper object
    private boolean agsReady = false;

    public JewelRushActivity()
    {
        m_instance = this;
    }

    AmazonGamesCallback callback = new AmazonGamesCallback() {
        @Override
        public void onServiceNotReady(AmazonGamesStatus status) {
            Log.e("-----AGS Service Not Ready", status.toString());
        }
        @Override
        public void onServiceReady(AmazonGamesClient amazonGamesClient) {
            agsClient = amazonGamesClient;
            agsClient.initializeJni();
            agsReady = true;
            Log.e("-----AGS Service Ready", "---");
        }
    };

    //list of features your game uses (in this example, achievements and leaderboards)
    EnumSet<AmazonGamesFeature> myGameFeatures = EnumSet.of(
            AmazonGamesFeature.Achievements, AmazonGamesFeature.Leaderboards);

    @Override
    public void onResume() {
        super.onResume();
        AmazonGamesClient.initialize(this, callback, myGameFeatures);
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig){
        super.onConfigurationChanged(newConfig);
        if(newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE){
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        }
    }

    public static void printViewHierarchy(ViewGroup $vg, String $prefix)
    {
        for (int i = 0; i < $vg.getChildCount(); i++) {
            View v = $vg.getChildAt(i);
            String desc = $prefix + " | " + "[" + i + "/" + ($vg.getChildCount()-1) + "] "+ v.getClass().getSimpleName() + " " + v.getId();
            Log.v("x", desc);

            if (v instanceof ViewGroup) {
                printViewHierarchy((ViewGroup)v, desc);
            }
        }
    }

    public static View findQtLayout(ViewGroup $vg)
    {
        View qtl = null;
        for (int i = 0; i < $vg.getChildCount(); i++) {
            View v = $vg.getChildAt(i);
            if (v instanceof QtLayout){
                qtl = v;
            } else if (v instanceof ViewGroup) {
                qtl = findQtLayout((ViewGroup)v);
            }
            if (qtl instanceof QtLayout){
                break;
            }
        }
        return qtl;
    }


    /**
     * When the activity starts, load an ad and set up the button's click event to load another ad when it's clicked.
     */
    @Override
    public void onCreate(final Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        setupAds();

        //=========================IAP Setup==============================
        // Create the helper, passing it our context and the public key to verify signatures with
        Log.d(LOG_TAG, "Creating IAB helper.");
        //Only map SKUs for stores that using purchase with SKUs different from described in store console.
        OpenIabHelper.Options.Builder builder = new OpenIabHelper.Options.Builder()
                .setStoreSearchStrategy(OpenIabHelper.Options.SEARCH_STRATEGY_INSTALLER_THEN_BEST_FIT)
 //               .setVerifyMode(OpenIabHelper.Options.VERIFY_EVERYTHING)
                .addStoreKeys(InAppConfig.STORE_KEYS_MAP);
        mHelper = new OpenIabHelper(this, builder.build());

        // enable debug logging (for a production application, you should set this to false).
        //mHelper.enableDebugLogging(true);

        // Start setup. This is asynchronous and the specified listener
        // will be called once setup completes.
        Log.d(LOG_TAG, "Starting setup.");
        mHelper.startSetup(new IabHelper.OnIabSetupFinishedListener() {
            public void onIabSetupFinished(IabResult result) {
                Log.d(LOG_TAG, "Setup finished.");
                consumeTestPurchases();

                if (!result.isSuccess()) {
                    // Oh noes, there was a problem.
                    setupDone = false;
                    Log.e(LOG_TAG, "Problem setting up in-app billing: " + result);
                    return;
                }

                // Hooray, IAB is fully set up. Now, let's get an inventory of stuff we own.
                Log.d(LOG_TAG, "Setup successful. Querying inventory.");
                setupDone = true;
                mHelper.queryInventoryAsync(mGotInventoryListener);
            }
        });

    }

    //=========================Advert Setup==============================
    public void setupAds()
    {
        if (this.adViewContainer == null) {
            View view = findQtLayout((ViewGroup)getWindow().getDecorView().getRootView());
            if (view instanceof QtLayout) {
                this.adViewContainer = (ViewGroup)view;
            } else {
                Log.e(LOG_TAG, "Unable to find QtLayout!");
            }

            // For debugging purposes enable logging, but disable for production builds.
            AdRegistration.enableLogging(false);
            // For debugging purposes flag all ad requests as tests, but set to false for production builds.
            AdRegistration.enableTesting(false);

            try {
                AdRegistration.setAppKey(APP_KEY);
            } catch (final Exception e) {
                Log.e(LOG_TAG, "Exception thrown: " + e.toString());
                return;
            }
        }
    }

    public static void showAd() {
        Log.d(LOG_TAG, "PGZ Show Ad");
        m_instance.loadAd();
    }

    public static void hideAd() {
        Log.d(LOG_TAG, "PGZ Hiding Ad");
    }

    public static boolean isAGSReady() {
        Log.d(LOG_TAG, "isAGSReady" + m_instance.agsReady);
        return m_instance.agsReady;
    }

    /**
     * Clean up all ad view resources when destroying the activity.
     */
    @Override
    public void onDestroy() {
        super.onDestroy();
        if (this.currentAdView != null)
            this.currentAdView.destroy();
        if (this.nextAdView != null)
            this.nextAdView.destroy();
    }

    /**
     * Loads a new ad. Keeps the current ad visible while the next ad loads.
     */
    private void loadAd() {
        Log.d(LOG_TAG, "PGZ LoadAd");

        if (this.nextAdView == null) { // Create and configure a new ad if the next ad doesn't currently exist.
            this.nextAdView = new AdLayout(this);
            final LayoutParams layoutParams = new FrameLayout.LayoutParams(LayoutParams.MATCH_PARENT,
                                LayoutParams.WRAP_CONTENT, Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL);
            this.nextAdView.setLayoutParams(layoutParams);

            // Register our ad handler that will receive callbacks for state changes during the ad lifecycle.
            this.nextAdView.setListener(new PGZAdListener());
        }

        // Load the ad with default ad targeting.
        this.nextAdView.loadAd();
    }

    /**
     * Shows the ad that is in the current ad view to the user.
     */
    private void showCurrentAd() {
        this.currentAdView.measure(this.adViewContainer.getWidth(),this.adViewContainer.getHeight());
        this.currentAdView.setY(this.adViewContainer.getHeight() - this.currentAdView.getMeasuredHeight());
        this.adViewContainer.addView(this.currentAdView);
        final Animation slideUp = AnimationUtils.loadAnimation(JewelRushActivity.this, R.anim.slide_up);
        this.currentAdView.startAnimation(slideUp);
    }

    /**
     * Shows the ad that is in the next ad view to the user.
     */
    private void showNextAd() {
        this.adViewContainer.removeView(this.currentAdView);
        final AdLayout tmp = this.currentAdView;
        this.currentAdView = this.nextAdView;
        this.nextAdView = tmp;
        showCurrentAd();
    }

    /**
     * Hides the ad that is in the current ad view, and then displays the ad that is in the next ad view.
     */
    private void swapCurrentAd() {
        Log.d(LOG_TAG, "PGZ Swap Current Ad");
        final Animation slideDown = AnimationUtils.loadAnimation(JewelRushActivity.this, R.anim.slide_down);
         slideDown.setAnimationListener(new AnimationListener() {
             public void onAnimationEnd(final Animation animation) {
                showNextAd();
             }

             public void onAnimationRepeat(final Animation animation) {
             }

             public void onAnimationStart(final Animation animation) {
             }
         });
         this.currentAdView.startAnimation(slideDown);
    }

    /**
     * This class is for an event listener that tracks ad lifecycle events.
     * It extends DefaultAdListener, so you can override only the methods that you need.
     */
    class PGZAdListener extends DefaultAdListener
    {
        /**
         * This event is called once an ad loads successfully.
         */
        @Override
        public void onAdLoaded(final Ad ad, final AdProperties adProperties) {
            Log.i(LOG_TAG, adProperties.getAdType().toString() + " ad loaded successfully.");
            // If there is an ad currently being displayed, swap the ad that just loaded with current ad.
            // Otherwise simply display the ad that just loaded.
            if (JewelRushActivity.this.currentAdView != null) {
                swapCurrentAd();
            } else {
                Log.d(LOG_TAG, "PGZ onAdLoaded..first time");
                // This is the first time we're loading an ad, so set the
                // current ad view to the ad we just loaded and set the next to null
                // so that we can load a new ad in the background.
                JewelRushActivity.this.currentAdView = JewelRushActivity.this.nextAdView;
                JewelRushActivity.this.nextAdView = null;
                showCurrentAd();
            }
        }

        /**
         * This event is called if an ad fails to load.
         */
        @Override
        public void onAdFailedToLoad(final Ad ad, final AdError error) {
            Log.w(LOG_TAG, "Ad failed to load. Code: " + error.getCode() + ", Message: " + error.getMessage());
        }

        /**
         * This event is called after a rich media ad expands.
         */
        @Override
        public void onAdExpanded(final Ad ad) {
            Log.i(LOG_TAG, "Ad expanded.");
            // You may want to pause your activity here.
        }

        /**
         * This event is called after a rich media ad has collapsed from an expanded state.
         */
        @Override
        public void onAdCollapsed(final Ad ad) {
            Log.i(LOG_TAG, "Ad collapsed.");
            // Resume your activity here, if it was paused in onAdExpanded.
        }
    }

    //=========================Native IAP Interface==============================

    private static native void itemPurchased(String itemName, int purchaseState);

    public static void purchaseItem(String itemName)
    {
        m_instance.purchaseItemReal(itemName);
    }

    public static int checkItemPurchased(String itemName)
    {
        return m_instance.checkItemPurchasedReal(itemName) ? 1 : 0;
    }


    //=============================================================================

    public void purchaseItemReal(String itemName)
    {
        Log.e(LOG_TAG, "In purhaseItem");

        if (!setupDone) {
            Log.e(LOG_TAG, "IAP is not setup");
            return;
        }

        String payload = "";
        mHelper.launchPurchaseFlow(this, itemName, RC_REQUEST, mPurchaseFinishedListener, payload);
    }

    public boolean checkItemPurchasedReal(String itemName)
    {
        Log.d(LOG_TAG, "checkItemPurchasedReal:" + itemName);
        if (itemName.equals(InAppConfig.SKU_NOADS)) {
            return mIsNoAds;
        }

        return false;
    }

    /**
     * Verifies the developer payload of a purchase.
     */
    boolean verifyDeveloperPayload(Purchase p) {
        String payload = p.getDeveloperPayload();

        /*
         * TODO: verify that the developer payload of the purchase is correct. It will be
         * the same one that you sent when initiating the purchase.
         *
         * WARNING: Locally generating a random string when starting a purchase and
         * verifying it here might seem like a good approach, but this will fail in the
         * case where the user purchases an item on one device and then uses your app on
         * a different device, because on the other device you will not have access to the
         * random string you originally generated.
         *
         * So a good developer payload has these characteristics:
         *
         * 1. If two different users purchase an item, the payload is different between them,
         *    so that one user's purchase can't be replayed to another user.
         *
         * 2. The payload must be such that you can verify it even when the app wasn't the
         *    one who initiated the purchase flow (so that items purchased by the user on
         *    one device work on other devices owned by the user).
         *
         * Using your own server to store and verify developer payloads across app
         * installations is recommended.
         */

        return true;
    }

    private void consumeTestPurchases() {
        Log.d(LOG_TAG, "Consuming test purchases");
        Purchase pp = null;
        try {
                pp = new Purchase("inapp","{\"packageName\":\"uk.co.piggz.jewelrush\","+"\"orderId\":\"transactionId.android.test.purchased\","+"\"productId\":\"android.test.purchased\",\"developerPayload\":\"\",\"purchaseTime\":0,"+
                "\"purchaseState\":0,\"purchaseToken\":\"inapp:uk.co.piggz.jewelrush:android.test.purchased\"}",
                "", OpenIabHelper.NAME_GOOGLE);
        } catch (JSONException e) {
                e.printStackTrace();
        }

        mHelper.consumeAsync(pp, new IabHelper.OnConsumeFinishedListener() {
                @Override
                public void onConsumeFinished(Purchase purchase, IabResult result) {
                        if(result.isSuccess()) {
                            Log.d(LOG_TAG, "Purchase consumed!");
                        } else {
                            Log.d(LOG_TAG, "Purchase NOT consumed!");
                        }
                }
        });

    }

    // Callback for when a purchase is finished
    IabHelper.OnIabPurchaseFinishedListener mPurchaseFinishedListener = new IabHelper.OnIabPurchaseFinishedListener() {
        public void onIabPurchaseFinished(IabResult result, Purchase purchase) {
            Log.d(LOG_TAG, "Purchase finished: " + result + ", purchase: " + purchase);
            if (result.isFailure()) {
                itemPurchased("", result.getResponse());
                return;
            }
            if (!verifyDeveloperPayload(purchase)) {
                return;
            }

            Log.d(LOG_TAG, "Purchase successful.");

            if (purchase.getSku().equals(InAppConfig.SKU_NOADS)) {
                // bought no-ads
                itemPurchased(purchase.getSku(), result.getResponse());
            }
        }
    };

    // Listener that's called when we finish querying the items and subscriptions we own
    private IabHelper.QueryInventoryFinishedListener mGotInventoryListener =
            new IabHelper.QueryInventoryFinishedListener() {
                @Override
                public void onQueryInventoryFinished(IabResult result, Inventory inventory) {
                    Log.d(LOG_TAG, "Query inventory finished.");
                    if (result.isFailure()) {
                        Log.e(LOG_TAG, "Query inventory failed." + result);
                        return;
                    }

                    Log.d(LOG_TAG, "Query inventory was successful.");

                    /*
                     * Check for items we own. Notice that for each purchase, we check
                     * the developer payload to see if it's correct! See
                     * verifyDeveloperPayload().
                     */

                    // Do we have no ads?
                    Purchase noAdsPurchase = inventory.getPurchase(InAppConfig.SKU_NOADS);
                    mIsNoAds = noAdsPurchase != null && verifyDeveloperPayload(noAdsPurchase);
                    Log.d(LOG_TAG, "Ads purchase is " + (mIsNoAds ? "PURCHASED" : "NOT PURCHASED"));
                }
            };

}
