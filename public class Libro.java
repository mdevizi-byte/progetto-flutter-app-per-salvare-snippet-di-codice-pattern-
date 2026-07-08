public class Libro {
    // 1. Attributi (incapsulati usando 'private' per buona pratica)
    private String titolo;
    private String autore;
    private int annoPubblicazione;

    // 2. Metodo Costruttore
    // Ha lo stesso identico nome della classe e non ha tipo di ritorno (nemmeno void)
    public Libro(String titolo, String autore, int annoPubblicazione) {
        this.titolo = titolo;             // 'this.titolo' si riferisce all'attributo in alto
        this.autore = autore;             // 'autore' senza this è il parametro che passa l'utente
        this.annoPubblicazione = annoPubblicazione;
    }

    // 3. Metodo toString()
    // Sovrascrive il metodo standard di Java per restituire una frase personalizzata
    @Override
    public String toString() {
        return "Libro: \"" + titolo + "\" di " + autore + " (" + annoPubblicazione + ")";
    }
}