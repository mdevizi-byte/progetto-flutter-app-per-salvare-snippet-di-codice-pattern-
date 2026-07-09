import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'home_screen.dart'; // Importiamo la nuova schermata Home

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller per tracciare il testo inserito nei campi
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // Liberiamo la memoria quando lo schermo viene rimosso
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
                TextField(
                  controller: _emailController, // Collegato al controller email
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController, // Collegato al controller password
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),
                
                // PULSANTE ACCEDI AGGIORNATO CON LOGICA DI SBLOCCO
                Center(
                  child: SizedBox(
                    width: 160,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // Controllo di convalida: l'utente deve inserire qualcosa
                        if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                          
                          // Navighiamo alla HomeScreen sostituendo la schermata corrente (così non si può tornare indietro con il tasto "back")
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                          );
                          
                        } else {
                          // Se i campi sono vuoti, mostra un avviso in basso
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Errore: Inserisci sia l\'email che la password!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Accedi',
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Non hai un account? Registrati'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
