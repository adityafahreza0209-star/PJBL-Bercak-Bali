import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/routes/app_pages.dart';
import 'app/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://exsafhemjamjrieqdarn.supabase.co',   
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV4c2FmaGVtamFtanJpZXFkYXJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk2NzEwNzMsImV4cCI6MjA5NTI0NzA3M30.tUbaMJLesHdRqftjGwLxFOmq2v8sHbr-bXX4CD0RoQA',            
  );

  Get.put(AuthService(), permanent: true);

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bercak Bali',
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}