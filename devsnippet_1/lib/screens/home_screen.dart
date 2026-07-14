import 'package:flutter/material.dart';
import 'dart:async';

import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/snippet_provider.dart';
import '../models/snippet.dart' as model;
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _addFormKey = GlobalKey<FormState>();
  StreamSubscription<User?>? _authSub;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String _selectedLanguage = 'Codice';

  static const List<String> _monthNames = [
    'gen',
    'feb',
    'mar',
    'apr',
    'mag',
    'giu',
    'lug',
    'ago',
    'set',
    'ott',
    'nov',
    'dic',
  ];

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _formatPublishedAt(DateTime timestamp) {
    final day = _twoDigits(timestamp.day);
    final month = _monthNames[timestamp.month - 1];
    final year = timestamp.year;
    final time =
        '${_twoDigits(timestamp.hour)}:${_twoDigits(timestamp.minute)}';
    return 'Pubblicato il $day $month $year, ore $time';
  }

  @override
  void initState() {
    super.initState();
    final userId = AuthService().currentUser?.uid ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SnippetProvider>(
        context,
        listen: false,
      ).listenToSnippets(userId);
    });
    // Se non c'è ancora un utente (ad esempio la pagina è caricata
    // immediatamente dopo l'inizializzazione), ascoltiamo i cambiamenti
    // dello stato di autenticazione e avviamo l'ascolto degli snippet
    // appena l'utente diventa disponibile.
    if (userId.isEmpty) {
      _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
        final uid = user?.uid ?? '';
        if (uid.isNotEmpty) {
          Provider.of<SnippetProvider>(context, listen: false)
              .listenToSnippets(uid);
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    _authSub?.cancel();
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
                      if (value == null || value.trim().isEmpty) {
                        return 'Il titolo non può essere vuoto';
                      }
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
                      if (value == null || value.trim().isEmpty) {
                        return 'Il codice non può essere vuoto';
                      }
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
                    items: [
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
                      if (value != null) {
                        setState(() => _selectedLanguage = value);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (_addFormKey.currentState!.validate()) {
                        final userId = AuthService().currentUser?.uid ?? '';

                        final nuovoSnippet = model.Snippet(
                          title: _titleController.text.trim(),
                          code: _codeController.text.trim(),
                          language: _selectedLanguage,
                          userId: userId,
                          timestamp: DateTime.now(),
                        );

                        await Provider.of<SnippetProvider>(
                          context,
                          listen: false,
                        ).addSnippet(nuovoSnippet);

                        _titleController.clear();
                        _codeController.clear();
                        if (context.mounted) Navigator.pop(context);
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

  void _showSnippetDetails(BuildContext context, model.Snippet snippet) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blueGrey,
                        child: Icon(Icons.code, color: Colors.blue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snippet.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Chip(label: Text(snippet.language)),
                                Chip(
                                    label: Text(
                                        _formatPublishedAt(snippet.timestamp))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Contenuto',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          snippet.code,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
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
    final snippetProvider = Provider.of<SnippetProvider>(context);
    final realSnippets = snippetProvider.snippets;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('La Mia Biblioteca'),
            Text(
              'UID: ${AuthService().currentUser?.uid ?? 'non autenticato'}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _showSnippetDetails(context, item),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.blueGrey,
                                child: Icon(Icons.code, color: Colors.blue),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        Chip(
                                          label: Text(item.language),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        Chip(
                                          label: Text(_formatPublishedAt(
                                              item.timestamp)),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  if (item.id != null) {
                                    await snippetProvider
                                        .deleteSnippet(item.id!);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('${item.title} rimosso.'),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white12,
                              ),
                            ),
                            child: Text(
                              item.code,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
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
