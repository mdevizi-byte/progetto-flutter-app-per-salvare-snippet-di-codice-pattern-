import 'package:flutter/material.dart';
import '../models/snippet.dart';
import '../services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _addFormKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _codeController = TextEditingController(); 
  String _selectedLanguage = 'Testo'; 

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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24, left: 24, right: 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _addFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Aggiungi alla Biblioteca', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Tìtolo dello snippet o file', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Il titolo non può essere vuoto' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _codeController, 
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Contenuto o codice', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Il contenuto non può essere vuoto' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedLanguage, 
                    decoration: const InputDecoration(labelText: 'Tipo di Risorsa / Lingua', border: OutlineInputBorder()),
                    items: ['Testo', 'Codice', 'File PDF', 'Link'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                    onChanged: (value) { if (value != null) _selectedLanguage = value; },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (_addFormKey.currentState!.validate()) {
                        final nuovoSnippet = Snippet(
                          title: _titleController.text.trim(),
                          code: _codeController.text.trim(),
                          language: _selectedLanguage,
                          userId: 'utente_corrente_id', 
                          timestamp: DateTime.now(),
                        );

                        await FirebaseService.addSnippet(nuovoSnippet);

                        _titleController.clear();
                        _codeController.clear();
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Salva nel Cloud'),
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

  IconData _getIconForType(String language) {
    switch (language) {
      case 'Codice': return Icons.code;
      case 'File PDF': return Icons.picture_as_pdf;
      case 'Link': return Icons.link;
      default: return Icons.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('La Mia Biblioteca Cloud'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          )
        ],
      ),
      body: StreamBuilder<List<Snippet>>(
        stream: FirebaseService.getSnippetsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Errore di connessione al Cloud.'));
          }

          final cloudSnippets = snapshot.data ?? [];

          if (cloudSnippets.isEmpty) {
            return const Center(child: Text('Nessun elemento nel Cloud.\nAggiungi qualcosa con il tasto +', textAlign: TextAlign.center));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cloudSnippets.length,
            itemBuilder: (context, index) {
              final item = cloudSnippets[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: Icon(_getIconForType(item.language), color: Colors.blue)),
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item.code), 
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      if (item.id != null) {
                        await FirebaseService.deleteSnippet(item.id!);
                      }
                    },
                  ),
                ),
              );
            },
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
