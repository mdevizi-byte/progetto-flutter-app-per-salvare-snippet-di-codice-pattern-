import 'package:flutter/material.dart';

// Modello dei dati per rappresentare un singolo "Snippet" (dato/file)
class SnippetItem {
  final String id;
  final String title;
  final String description;
  final String type; // Es: "Testo", "Codice", "Link", "File PDF"

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
  // Lista di dati "finti" (Mock Data) iniziali
  final List<SnippetItem> _snippets = [
    SnippetItem(
      id: '1',
      title: 'Configurazione Database Firebase',
      description: 'Snippet di codice per l\'inizializzazione di Firebase Firestore in Flutter.',
      type: 'Codice',
    ),
    SnippetItem(
      id: '2',
      title: 'Documento Specifiche Tecniche.pdf',
      description: 'File allegato con i requisiti del cliente per l\'applicazione.',
      type: 'File PDF',
    ),
    SnippetItem(
      id: '3',
      title: 'Note Riunione Marketing',
      description: 'Raccolta di idee per il lancio dell\'app previsto a fine mese.',
      type: 'Testo',
    ),
  ];

  // Controller per i campi del form di aggiunta
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedType = 'Testo'; // Tipo di default

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Funzione per mostrare il Form (Bottom Sheet) per aggiungere un elemento
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
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titolo dello snippet o file',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descrizione o contenuto',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  // Usiamo initialValue per evitare l'avviso di deprecazione di Flutter
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo di Risorsa',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Testo', 'Codice', 'File PDF', 'Link']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty && _descController.text.isNotEmpty) {
                      setState(() {
                        _snippets.add(
                          SnippetItem(
                            id: DateTime.now().toString(),
                            title: _titleController.text,
                            description: _descController.text,
                            type: _selectedType,
                          ),
                        );
                      });
                      _titleController.clear();
                      _descController.clear();
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Salva nella Biblioteca'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Codice':
        return Icons.code;
      case 'File PDF':
        return Icons.picture_as_pdf;
      case 'Link':
        return Icons.link;
      default:
        return Icons.description;
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
          ? const Center(
              child: Text(
                'La biblioteca è vuota.\nAggiungi qualcosa con il tasto +',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _snippets.length,
              itemBuilder: (context, index) {
                final item = _snippets[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12), // Corretto qui!
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: Icon(_getIconForType(item.type), color: Colors.blue),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(item.description),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _snippets.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${item.title} rimosso.')),
                        );
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