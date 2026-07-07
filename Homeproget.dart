import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CodeSnippetApp());
}

class CodeSnippetApp extends StatelessWidget {
  const CodeSnippetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Dev Snippets',
      theme: ThemeData(
        brightness: Brightness.dark, // Tema scuro, perfetto per i programmatori
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E), // Sfondo stile VS Code
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Modello dati per lo Snippet
class Snippet {
  final String title;
  final String language;
  final String code;

  Snippet({required this.title, required this.language, required this.code});
}

// 1. HOME SCREEN - Lista degli snippet
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Dati di esempio (mock data) richiesti per lo sviluppo
  final List<Snippet> _snippets = [
    Snippet(
      title: 'Configurazione Eccezioni Custom Spring Boot',
      language: 'Java',
      code: '@ControllerAdvice\npublic class GlobalExceptionHandler {\n  @ExceptionHandler(ResourceNotFoundException.class)\n  public ResponseEntity<?> handleResourceNotFound() {\n    return new ResponseEntity<>("Non trovato", HttpStatus.NOT_FOUND);\n  }\n}',
    ),
    Snippet(
      title: 'Validazione JWT personalizzata',
      language: 'Java / Spring',
      code: '@Component\npublic class JwtFilter extends OncePerRequestFilter {\n  // Logica custom di estrazione e verifica token\n}',
    ),
    Snippet(
      title: 'Chiamata API standard con Flutter',
      language: 'Dart',
      code: 'Future<void> fetchData() async {\n  final response = await http.get(Uri.parse(url));\n  if (response.statusCode == 200) {\n    // parsing del JSON custom\n  }\n}',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📂 I Miei Snippet Personali'),
        backgroundColor: const Color(0xFF252526),
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: _snippets.length,
        itemBuilder: (context, index) {
          final snippet = _snippets[index];
          return Card(
            color: const Color(0xFF2D2D30),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(snippet.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(snippet.language, style: TextStyle(color: Colors.tealAccent[400])),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
              onTap: () {
                // Naviga al dettaglio dello snippet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(snippet: snippet),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Qui andrebbe la logica per aggiungere un nuovo snippet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Funzionalità di aggiunta in arrivo!')),
          );
        },
      ),
    );
  }
}

// 2. DETAIL SCREEN - Visualizzazione e copia del codice
class DetailScreen extends StatelessWidget {
  final Snippet snippet;

  const DetailScreen({super.key, required this.snippet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(snippet.title),
        backgroundColor: const Color(0xFF252526),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Linguaggio: ${snippet.language}',
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.tealAccent),
                  tooltip: 'Copia codice',
                  onPressed: () {
                    // Copia il codice negli appunti del telefono/PC
                    Clipboard.setData(ClipboardData(text: snippet.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Codice copiato negli appunti!')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black, // Box nero stile terminale
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    snippet.code,
                    style: const TextStyle(
                      fontFamily: 'Courier', // Font monospazio per il codice
                      fontSize: 14,
                      color: Colors.lightGreenAccent,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}