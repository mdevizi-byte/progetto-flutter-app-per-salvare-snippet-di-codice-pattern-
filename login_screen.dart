import 'package:flutter/material.dart';
import 'package:devsnippet_app/screens/register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),

                // --- MODIFICA DEL PULSANTE ACCEDI ---
                Center(
                  child: SizedBox(
                    width:
                        160, // Larghezza contenuta, ideale per un utente medio
                    height: 48, // Altezza standard ma ben visibile e cliccabile
                    child: ElevatedButton(
                      onPressed: () {
                        // Inserisci qui la logica di login in futuro
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Sfondo blu
                        foregroundColor: Colors.white, // Testo bianco
                        elevation: 2, // Una leggera ombra per farlo risaltare
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // Bordi leggermente arrotondati
                        ),
                      ),
                      child: const Text(
                        'Accedi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight
                              .bold, // Testo in grassetto per massima leggibilità
                        ),
                      ),
                    ),
                  ),
                ),

                // -------------------------------------
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
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
