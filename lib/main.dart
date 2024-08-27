import 'package:flutter/material.dart';
import 'package:hotel_finde_hotel/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/storage/shared/shared_pref.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences shPref = await SharedPreferences.getInstance();
  AppSharedPreferences.init(shPref);

  runApp(
    const HotelFinder(),
  );
}
