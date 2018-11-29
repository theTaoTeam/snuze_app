package com.example.snuze;

import android.os.Bundle;

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
    Stripe stripe = new Stripe(this, "pk_test_YhN3AX1KBNqQQbDtGjctrCZd");

    public JSONObject newJSONObject(String string) {
        try {
            JSONObject result = new JSONObject(string);
            return result;
        } catch (JSONException e) {
            System.out.println(e.getMessage());
            throw new RuntimeException(e);
        }
    }

    public Card createCard(JSONObject cardInfo) {
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

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

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
                            System.out.println("SETTING ALARM");
                            System.out.println(call.arguments().toString());
                        } else if (call.method.equals("cancelAlarm")) {
                            System.out.println("CANCELLING ALARM");
                            System.out.println(call.arguments().toString());
                        }
                    }
                }
        );
    }
}
