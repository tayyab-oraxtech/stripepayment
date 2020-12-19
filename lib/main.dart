import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stripe_payment/stripe_payment.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Token _token;
  PaymentMethod _paymentMethod;
  Source _source;
  final String _secretKey =
      'sk_test_51HzeBoExaxBaYn3vpaAeUuO2tdhiH26Cvxi70dbzSwa6JAlpP7mItV9un4bfWx0ylUt6fLgUam2JislnmCc2lccw00Dmob85Dz';
  PaymentIntentResult _paymentIntentResult;
  final CreditCard creditCard =
      CreditCard(number: '4111111111111111',cvc: '123', expMonth: 02, expYear: 24);
  String _error;
  GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  void getError(dynamic error) {
    _globalKey.currentState.showSnackBar(SnackBar(
      content: Text(error.toString()),
    ));
    setState(() {
      _error = error;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    StripePayment.setOptions(StripeOptions(
        publishableKey:
            'pk_test_51HzeBoExaxBaYn3vt9WIEAR5Jl2y5qztQklSzRlII8Gbqt91nkBK73uB5LWTHBjBPz4bzYp8DY2DY6Wrhdtf1qnz00MnWH9Moh',
        androidPayMode: 'test',
        merchantId: 'Test'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stripe basic"),
      ),
      body: Container(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                MaterialButton(
                  child: Text('Initialize Source'),
                  color: Colors.lightBlue,
                  onPressed: () {
                    StripePayment.createSourceWithParams(SourceParams(
                            returnURL: 'example://stripe-redirect',
                            amount: 800,
                            currency: 'PKR',
                            type: 'ideal'))
                        .then((source) {
                      setState(() {
                        _source = source;
                      });
                    }).catchError(getError);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      child: Text('Token with Card Form'),
                      color: Colors.redAccent,
                      onPressed: () {
                        StripePayment.paymentRequestWithCardForm(
                                CardFormPaymentRequest())
                            .then((paymentMethod) {
                          setState(() {
                            _paymentMethod = paymentMethod;
                          });
                        }).catchError(getError);
                      },
                    ),
                    MaterialButton(
                      child: Text('Token with Card'),
                      color: Colors.yellow,
                      onPressed: () {
                        StripePayment.createTokenWithCard(creditCard)
                            .then((token) {
                          setState(() {
                            _token = token;
                          });
                        }).catchError(getError);
                      },
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      child: Text('Payment Method with Card'),
                      color: Colors.amber,
                      onPressed: () {
                        StripePayment.createPaymentMethod(
                                PaymentMethodRequest(card: creditCard))
                            .then((paymentMethod) {
                          setState(() {
                            _paymentMethod = paymentMethod;
                          });
                        }).catchError(getError);
                      },
                    ),
                    Expanded(
                      child: MaterialButton(
                        child: Text('Payment Method with token'),
                        color: Colors.red,
                        onPressed: _token == null
                            ? null
                            : () {
                                StripePayment.createPaymentMethod(
                                        PaymentMethodRequest(
                                            card: CreditCard(
                                                token: _token.tokenId)))
                                    .then((paymentMethod) {
                                  setState(() {
                                    _paymentMethod = paymentMethod;
                                  });
                                }).catchError(getError);
                              },
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      child: Text('Get Payment Intent'),
                      color: Colors.greenAccent,
                      onPressed: _paymentMethod == null || _secretKey == null
                          ? null
                          : () {
                              StripePayment.confirmPaymentIntent(PaymentIntent(
                                      clientSecret: _secretKey,
                                      paymentMethodId: _paymentMethod.id))
                                  .then((paymentIntent) {
                                setState(() {
                                  _paymentIntentResult = paymentIntent;
                                });
                              }).catchError(getError);
                            },
                    ),
                    Expanded(
                      child: MaterialButton(
                        child: Text('Authenticate Payment Intent'),
                        color: Colors.purpleAccent,
                        onPressed: () {
                          StripePayment.authenticatePaymentIntent(
                                  clientSecret: _secretKey)
                              .then((paymentIntent) {
                            setState(() {
                              _paymentIntentResult = paymentIntent;
                            });
                          }).catchError(getError);
                        },
                      ),
                    )
                  ],
                ),
                Divider(),
                Text('Source:'),
                Text(JsonEncoder.withIndent(' ')
                    .convert(_source?.toJson() ?? {})),
                Text('Token:'),
                Text(JsonEncoder.withIndent(' ')
                    .convert(_token?.toJson() ?? {})),
                Text('Payment Method:'),
                Text(JsonEncoder.withIndent(' ')
                    .convert(_paymentMethod?.toJson() ?? {})),
                Text('Payment Intent:'),
                Text(JsonEncoder.withIndent(' ')
                    .convert(_paymentIntentResult?.toJson() ?? {})),
                Text('Error'),
                Text(_error.toString())
              ],
            ),
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
