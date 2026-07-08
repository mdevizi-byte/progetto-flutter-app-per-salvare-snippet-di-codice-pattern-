document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('code-form');
    const snippetsGrid = document.getElementById('snippets-grid');

    // Carica i codici già salvati altrimenti crea un array vuoto
    let mySnippets = JSON.parse(localStorage.getItem('snippets')) || [];

    // Funzione per mostrare i codici a schermo
    function displaySnippets() {
        snippetsGrid.innerHTML = '';
        
        if (mySnippets.length === 0) {
            snippetsGrid.innerHTML = '<p style="color: #a6adc8; font-style: italic;">Nessun codice salvato. Aggiungine uno a sinistra!</p>';
            return;
        }

        mySnippets.forEach((snippet, index) => {
            const card = document.createElement('div');
            card.classList.add('snippet-card');

            // Protezione base contro attacchi XSS convertendo i simboli < e >
            const safeCode = snippet.code.replace(/</g, "&lt;").replace(/>/g, "&gt;");

            card.innerHTML = `
                <div class="snippet-header">
                    <h3>${snippet.title}</h3>
                    <span class="badge">${snippet.language}</span>
                </div>
                <pre><code>${safeCode}</code></pre>
                <div style="text-align: right; margin-top: 15px;">
                    <button class="btn-delete" onclick="deleteSnippet(${index})">Elimina</button>
                </div>
            `;
            snippetsGrid.appendChild(card);
        });
    }

    // Gestione dell'invio del form
    form.addEventListener('submit', (e) => {
        e.preventDefault();

        const title = document.getElementById('title').value;
        const language = document.getElementById('language').value;
        const code = document.getElementById('code').value;

        const newSnippet = { title, language, code };

        mySnippets.push(newSnippet);
        localStorage.setItem('snippets', JSON.stringify(mySnippets));
        
        displaySnippets();
        form.reset(); // Svuota il form dopo il salvataggio
    });

    // Funzione globale per eliminare un codice
    window.deleteSnippet = function(index) {
        if(confirm("Sei sicuro di voler eliminare questo snippet?")) {
            mySnippets.splice(index, 1);
            localStorage.setItem('snippets', JSON.stringify(mySnippets));
            displaySnippets();
        }
    }

    // Mostra i codici all'avvio
    displaySnippets();
});