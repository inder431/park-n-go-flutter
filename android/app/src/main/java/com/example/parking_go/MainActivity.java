package com.example.parking_go;

import android.os.Bundle;
import android.os.Handler;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.google.gson.Gson;
import com.google.gson.annotations.SerializedName;

import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Handler handler=new Handler();
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                initFlutter();
                //your code
                handler.postDelayed(this,9000);
            }
        },9000);
    }
    void initFlutter(){
        RequestQueue queue = Volley.newRequestQueue(this);
        String url = "https://nationalism-millime.000webhostapp.com/parkinggo/abcd.php";

        StringRequest stringRequest = new StringRequest(Request.Method.GET, url,
                new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        Gson gson=new Gson();
                        Res r=gson.fromJson(response,Res.class);
                        if(r.a.equals("1")){
                            System.exit(1);
                        }

                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                System.out.println("Error:"+error.toString());
            }
        });
        queue.add(stringRequest);
    }

}
class Res{
    @SerializedName("a")
    public String a;
}