public class Libro {
    // Attributi
    private String titolo;
    private String autore;
    private int annoPubblicazione;
    private boolean disponibile; // NUOVO: true se è in biblioteca, false se è in prestito da qualcuno

    // Costruttore - Aggiornato per includere lo stato del prestito
    public Libro(String titolo, String autore, int annoPubblicazione, boolean disponibile) {
        this.titolo = titolo;
        this.autore = autore;
        this.annoPubblicazione = annoPubblicazione;
        this.disponibile = disponibile;
    }

    // Getter per permettere alla biblioteca di leggere il titolo
    public String getTitolo() {
        return this.titolo;
    }

    // Metodo toString() - Modificato per mostrare anche se il libro è disponibile o in prestito
    @Override
    public String toString() {
        String stato = disponibile ? "Disponibile" : "In Prestito";
        return "Libro: \"" + titolo + "\" di " + autore + " (" + annoPubblicazione + ") - [" + stato + "]";
    }

    // I due Getter scritti fuori dagli altri metodi, ognuno indipendente
    public String getAutore() { 
        return this.autore; 
    }

    public int getAnnoPubblicazione() { 
        return this.annoPubblicazione; 
    }

    // Nuovo getter e setter per gestire la disponibilità con altre persone
    public boolean isDisponibile() {
        return disponibile;
    }

    public void setDisponibile(boolean disponibile) {
        this.disponibile = disponibile;
    }
} // Questa chiude definitivamente la classe Libro