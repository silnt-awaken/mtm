import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mtm/app.dart';
import 'package:mtm/core/observer/observer.dart';
import 'package:mtm/routing/router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Set up Bloc observer for debugging
  Bloc.observer = AppBlocObserver();
  
  runApp(App(router: router));
}