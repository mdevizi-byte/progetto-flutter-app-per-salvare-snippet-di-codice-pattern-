# DevSnippet — guida per completare l'unione front-end/back-end

Ho sistemato la struttura del progetto e i bug che impedivano al front-end
(schermate) di parlare col back-end (Firebase). Restano 2 cose che **devi
fare tu**, perché richiedono le credenziali del vostro progetto Firebase:

## 1. Genera il vero `firebase_options.dart`

Il file che avevate era solo un segnaposto vuoto. Nel terminale, dentro la
cartella del progetto:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Questo comando chiede a quale progetto Firebase collegare l'app (createlo su
console.firebase.google.com se non esiste ancora) e genera in automatico
`lib/firebase_options.dart` con le chiavi corrette. **Sostituisci** il file
segnaposto con quello vero generato dal comando.

## 2. Attiva Authentication e Firestore sulla console Firebase

- Firebase Console → Authentication → Sign-in method → attiva "Email/Password".
- Firebase Console → Firestore Database → crea il database (modalità test
  va bene per iniziare).

Regole di sicurezza minime consigliate per Firestore (Firestore → Regole):

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /snippets/{snippetId} {
      allow read, write: if request.auth != null
        && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null
        && request.auth.uid == request.resource.data.userId;
    }
  }
}
```

## 3. Installa le dipendenze

```bash
flutter pub get
```

## Cosa ho cambiato rispetto ai file originali

- **Rimosso `Homeproget.dart`**: era un prototipo standalone (con dati
  finti e un proprio `main()`) del vostro primo esperimento, non collegato
  al resto. Tenerlo dentro `lib/` avrebbe solo creato confusione.
- **Unificato il modello `Snippet`**: prima ce n'erano due diversi (uno in
  `snippet_provider.dart`, uno in `snippet.dart`) e non combaciavano. Ora
  esiste solo `lib/models/snippet.dart`, con `id`, `title`, `code`,
  `language`, `userId`, `timestamp` e i metodi per Firestore.
- **Aggiunta `addSnippet()`** al provider: la home la chiamava ma non
  esisteva.
- **Corretta la query Firestore**: `.where('userId', ==: userId)` non è
  sintassi Dart valida, ora è `.where('userId', isEqualTo: userId)`.
- **`auth_service.dart` ora usa davvero Firebase Auth** (prima era un
  finto login solo in memoria, quindi login/registrazione non erano
  collegati a nulla di reale).
- **Aggiunte `firebase_auth` e `cloud_firestore` a `pubspec.yaml`**: erano
  usate nel codice ma mai dichiarate come dipendenze.
- Piccoli fix di compatibilità (es. `DropdownButtonFormField` usa `value`
  invece di `initialValue`) e controlli `mounted` prima di usare il
  `context` dopo un `await`, come richiesto dai linter più recenti.

## Struttura finale

```
lib/
  main.dart
  firebase_options.dart      ← da rigenerare con flutterfire configure
  models/
    snippet.dart
  providers/
    snippet_provider.dart
  services/
    auth_service.dart
  screens/
    login_screen.dart
    register_screen.dart
    home_screen.dart
```
