package com.example.snuze;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.provider.AlarmClock;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.stripe.android.Stripe;
import com.stripe.android.model.Token;
import com.stripe.android.model.Card;
import com.stripe.android.TokenCallback;

import org.json.JSONException;
import org.json.JSONObject;

public class MainActivity extends FlutterActivity {

    private static final String STRIPE_CHANNEL = "snuze.app/stripe";
    private static final String ALARM_CHANNEL = "snuze.app/alarm";
    private static final int MY_PERMISSIONS_REQUEST_SET_ALARM = 17;
    Stripe stripe = new Stripe(this, "pk_test_YhN3AX1KBNqQQbDtGjctrCZd");

    private JSONObject newJSONObject(String string) {
        try {
            JSONObject result = new JSONObject(string);
            return result;
        } catch (JSONException e) {
            System.out.println(e.getMessage());
            throw new RuntimeException(e);
        }
    }

    private Card createCard(JSONObject cardInfo) {
        try {
            Card result = new Card(
                    cardInfo.getString("number"),
                    cardInfo.getInt("expMonth"),
                    cardInfo.getInt("expYear"),
                    cardInfo.getString("cvc")
            );
            return result;
        } catch (JSONException e) {
            System.out.println(e.getMessage());
            throw new RuntimeException(e);
        }
    }

    private Intent createAlarmIntent(JSONObject alarmInfo) {
        try {
            Intent alarmIntent = new Intent(AlarmClock.ACTION_SET_ALARM);
            alarmIntent.putExtra(AlarmClock.EXTRA_HOUR, alarmInfo.getInt("hour"));
            alarmIntent.putExtra(AlarmClock.EXTRA_HOUR, alarmInfo.getInt("minute"));
            return alarmIntent;
        } catch (JSONException e) {
            System.out.println(e.getMessage());
            throw new RuntimeException(e);
        }
    }

    private Intent dismissAlarmIntent() {
        Intent alarmIntent = new Intent(AlarmClock.ACTION_DISMISS_ALARM);
        return alarmIntent;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        switch (requestCode) {
            case MY_PERMISSIONS_REQUEST_SET_ALARM: {
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    // permission was granted, yay! Do the
                    // contacts-related task you need to do.
                } else {
                    // permission denied, boo! Disable the
                    // functionality that depends on this permission.
                }
                return;
            }
            // other 'case' lines to check for other
            // permissions this app might request.
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        if (ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.SET_ALARM) != PackageManager.PERMISSION_GRANTED) {
            if (ActivityCompat.shouldShowRequestPermissionRationale(MainActivity.this, Manifest.permission.SET_ALARM)) {
                System.out.println("needs explanation");
                // Show an explanation to the user *asynchronously* -- don't block
                // this thread waiting for the user's response! After the user
                // sees the explanation, try again to request the permission.

            } else {
                // No explanation needed; request the permission
                ActivityCompat.requestPermissions(MainActivity.this,
                        new String[]{Manifest.permission.SET_ALARM},
                        MY_PERMISSIONS_REQUEST_SET_ALARM);
            }
        } else {
            // Permission already granted
        }

        new MethodChannel(getFlutterView(), STRIPE_CHANNEL).setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, final Result result) {
                        if (call.method.equals("createStripeToken")) {
                            JSONObject cardInfo = newJSONObject(call.arguments().toString());
                            Card card = createCard(cardInfo);
                            if (!card.validateCard()) {
                                System.out.println("invalid card format");
                                result.error("INVALID_CARD", "card not valid", null);
                            }

                            stripe.createToken(
                                    card,
                                    new TokenCallback() {
                                        public void onSuccess(Token token) {
                                            result.success(token.getId().toString());
                                        }

                                        public void onError(Exception error) {
                                            result.error("STRIPE_TOKEN", "error creating stripe token", null);
                                        }
                                    }
                            );


                        } else {
                            result.notImplemented();
                        }
                    }
                }
        );
        new MethodChannel(getFlutterView(), ALARM_CHANNEL).setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {
                        if (call.method.equals("setAlarm")) {
                            JSONObject alarmInfo = newJSONObject(call.arguments().toString());
                            Intent alarmIntent = createAlarmIntent(alarmInfo);
                            startActivity(alarmIntent);
                        } else if (call.method.equals("cancelAlarm")) {
                            Intent alarmIntent = dismissAlarmIntent();
                            startActivity(alarmIntent);
                        }
                    }
                }
        );
    }
}
