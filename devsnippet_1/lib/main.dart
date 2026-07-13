import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/snippet_provider.dart';

// Importa tutte le schermate del front-end
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //[cite: 6]
  
  // Modifica questa riga inserendo il cast esplicito alla fine:
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform as FirebaseOptions,
  );

  runApp(
    MultiProvider( //[cite: 6]
      providers: [ChangeNotifierProvider(create: (_) => SnippetProvider())], //[cite: 6]
      child: const MyApp(), //[cite: 6]
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DevSnippet App',
      theme: ThemeData(
        brightness: Brightness.dark, // Stile scuro preferito da Angelo
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}