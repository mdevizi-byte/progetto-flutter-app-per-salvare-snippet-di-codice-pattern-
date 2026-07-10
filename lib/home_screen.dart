import 'package:flutter/material.dart';
import 'providers/snippet_provider.dart';
import 'models/snippet.dart' as model; // Usa l'alias per puntare al tuo modello
import 'services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _addFormKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _codeController =
      TextEditingController(); // Gestirà il codice/contenuto
  String _selectedLanguage = 'Codice'; // Diventa il linguaggio/tipo di risorsa

  @override
  void initState() {
    super.initState();
    // Ottieni l'ID dell'utente loggato e avvia l'ascolto dei dati in tempo reale
    final userId = AuthService().currentUser?.uid ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SnippetProvider.instance.listenToSnippets(userId);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _showAddSnippetForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _addFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Aggiungi alla Biblioteca',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titolo dello snippet',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty)
                        return 'Il titolo non può essere vuoto';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _codeController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Codice o contenuto dello snippet',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty)
                        return 'Il codice non può essere vuoto';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedLanguage,
                    decoration: const InputDecoration(
                      labelText: 'Linguaggio / Tipo',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        [
                              'Dart',
                              'Java',
                              'Python',
                              'JavaScript',
                              'HTML/CSS',
                              'Codice',
                            ]
                            .map(
                              (lang) => DropdownMenuItem(
                                value: lang,
                                child: Text(lang),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) _selectedLanguage = value;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (_addFormKey.currentState!.validate()) {
                        final userId = AuthService().currentUser?.uid ?? '';

                        // Creiamo lo snippet reale per Firebase
                        final nuovoSnippet = model.Snippet(
                          title: _titleController.text.trim(),
                          code: _codeController.text.trim(),
                          language: _selectedLanguage,
                          userId: userId,
                          timestamp: DateTime.now(),
                        );

                        // Inviamo a Cloud Firestore tramite il provider
                        await SnippetProvider.instance.addSnippet(nuovoSnippet);

                        _titleController.clear();
                        _codeController.clear();
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Salva su Firebase'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Leggiamo la lista degli snippet aggiornata in tempo reale dal tuo provider
    final snippetProvider = SnippetProvider.instance;
    final realSnippets = snippetProvider.snippets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('La Mia Biblioteca'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: realSnippets.isEmpty
          ? const Center(
              child: Text(
                'La tua biblioteca è vuota.\nAggiungi qualcosa con il tasto +',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: realSnippets.length,
              itemBuilder: (context, index) {
                final item = realSnippets[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: Icon(Icons.code, color: Colors.blue),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${item.language}\n${item.code}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        if (item.id != null) {
                          // Cancella direttamente da Firestore usando la tua funzione
                          await snippetProvider.deleteSnippet(item.id!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${item.title} rimosso.')),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSnippetForm(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
