import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Chiave di controllo per la validazione del Form
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Questa variabile controlla se la password deve essere nascosta (true) o visibile (false)
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
                  const SizedBox(height: 24),
                  const Text(
                    'Bentornato!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  
                  // CAMPO EMAIL
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Per favore, inserisci l\'email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Inserisci un indirizzo email valido (es. nome@test.com)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // CAMPO PASSWORD CON ACCUMULO DI TUTTI GLI ERRORI
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _isPasswordObscured,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordObscured = !_isPasswordObscured;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Per favore, inserisci la password';
                      }

                      // Creiamo una lista vuota per accumulare tutti gli errori riscontrati
                      List<String> errors = [];
                      
                      // 1. Controllo Lunghezza
                      if (value.length < 6) {
                        errors.add('• Minimo 6 caratteri');
                      }
                      
                      // 2. Controllo Lettera Maiuscola
                      if (!RegExp(r'[A-Z]').hasMatch(value)) {
                        errors.add('• Almeno una lettera maiuscola');
                      }
                      
                      // 3. Controllo 2 Numeri
                      int countNumbers = RegExp(r'\d').allMatches(value).length;
                      if (countNumbers < 2) {
                        errors.add('• Almeno 2 numeri');
                      }
                      
                      // 4. Controllo Carattere Speciale
                      if (!RegExp(r'[^a-zA-Z0-9\s]').hasMatch(value)) {
                        errors.add('• Almeno un carattere speciale (es. @, #, !, ?)');
                      }
                      
                      // Se la lista NON è vuota, uniamo tutti gli errori separandoli con un a capo
                      if (errors.isNotEmpty) {
                        return 'La password deve contenere:\n' + errors.join('\n');
                      }
                      
                      return null; // Zero errori, la password è valida!
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  Center(
                    child: SizedBox(
                      width: 160,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreen()),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Accedi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                    },
                    child: const Text('Non hai un account? Registrati'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
