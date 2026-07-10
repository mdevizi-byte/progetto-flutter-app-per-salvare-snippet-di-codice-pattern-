import 'package:flutter/material.dart';

// Modello dei dati locale (UI)
class SnippetItem {
  final String id;
  final String title;
  final String description;
  final String type;

  SnippetItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Chiave del form per convalidare l'aggiunta di un nuovo snippet
  final _addFormKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedType = 'Testo';

  // Lista locale per mostrare gli elementi a schermo
  final List<SnippetItem> _snippets = [
    SnippetItem(id: '1', title: 'Configurazione Database', description: 'Snippet di codice utile per iniziare.', type: 'Codice'),
    SnippetItem(id: '2', title: 'Note di Progetto', description: 'Promemoria per lo sviluppo dell\'interfaccia.', type: 'Testo'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
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
              key: _addFormKey, // Colleghiamo la chiave al form di inserimento
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Aggiungi alla Biblioteca', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  
                  // CONTROLLO DI VALIDAZIONE SUL TITOLO
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Titolo dello snippet o file', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Il titolo non può essere vuoto';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // CONTROLLO DI VALIDAZIONE SULLA DESCRIZIONE
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Descrizione o contenuto', border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La descrizione non può essere vuota';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(labelText: 'Tipo di Risorsa', border: OutlineInputBorder()),
                    items: ['Testo', 'Codice', 'File PDF', 'Link'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                    onChanged: (value) { if (value != null) _selectedType = value; },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Se la validazione del titolo e della descrizione va a buon fine
                      if (_addFormKey.currentState!.validate()) {
                        setState(() {
                          _snippets.add(
                            SnippetItem(
                              id: DateTime.now().toString(),
                              title: _titleController.text.trim(),
                              description: _descController.text.trim(),
                              type: _selectedType,
                            ),
                          );
                        });
                        _titleController.clear();
                        _descController.clear();
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Salva nella Biblioteca'),
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

  IconData _getIconForType(String type) {
    switch (type) {
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
        title: const Text('La Mia Biblioteca'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: _snippets.isEmpty
          ? const Center(child: Text('La tua biblioteca è vuota.\nAggiungi qualcosa con il tasto +', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _snippets.length,
              itemBuilder: (context, index) {
                final item = _snippets[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: Icon(_getIconForType(item.type), color: Colors.blue)),
                    title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item.description),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _snippets.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.title} rimosso.')));
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
