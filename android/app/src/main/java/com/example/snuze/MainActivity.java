package com.example.snuze;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import android.util.Log;
import android.content.Context;
import android.widget.Toast;

import com.stripe.android.Stripe;
import com.stripe.android.model.Token;
import com.stripe.android.model.Card;
import com.stripe.android.TokenCallback;
import org.json.JSONObject;

import static java.security.AccessController.getContext;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "snuze.app/stripe";
  Stripe stripe = new Stripe(this, "pk_test_YhN3AX1KBNqQQbDtGjctrCZd");
  
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
      new MethodCallHandler() {
        @Override
        public void onMethodCall(MethodCall call, final Result result) {
//        System.out.println(call);
          if (call.method.equals("createStripeToken")) {
              System.out.println(call.arguments().toString());

               Card card = new Card("4242424242424242", 11, 2020, "123");
               if (!card.validateCard()) {
                   System.out.println("invalid card format");
               }

              stripe.createToken(
                      card,
                      new TokenCallback() {
                          public void onSuccess(Token token) {
                              result.success(token.getId());
                          }
                          public void onError(Exception error) {
                              // Show localized error message
//                              Toast.makeText(getContext(),
////                                      error.getLocalizedString(getContext()),
//                                      Toast.LENGTH_LONG
//                              ).show();
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
  }
}
