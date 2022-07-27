import 'package:flutter/material.dart';
import 'package:go_park/provider/address_data_provider.dart';
import 'package:go_park/provider/authentication_provider.dart';
import 'package:go_park/screens/auth_screen.dart';
import 'package:go_park/screens/map_screen.dart';
import 'package:go_park/screens/search_screen.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        //Providing Auth Data
        ChangeNotifierProvider(
          create: (ctx) => AuthenticationProvider(),
        ),

        ChangeNotifierProvider(
          create: (ctx) => AddressDataProvider(),
        ),
      ],
      child: Consumer<AuthenticationProvider>(
        builder: (ctx, authProviderObj, _) => MaterialApp(
          debugShowCheckedModeBanner: true,
          theme: ThemeData(
            primaryColor: Color.fromRGBO(241, 101, 115, 1).withOpacity(1),
            accentColor: Color.fromRGBO(241, 101, 115, 1).withOpacity(1),
          ),
          home: authProviderObj.checkauthentication() == true
              ? MapScreen()
              : FutureBuilder(
                  future: authProviderObj.tryAutoSignIn(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()),
          routes: {
            //MapScreen.routeName: (ctx) => MapScreen(),
            SearchScreen.routeName: (ctx) => SearchScreen(),
          },
        ),
      ),
    );
  }
}
