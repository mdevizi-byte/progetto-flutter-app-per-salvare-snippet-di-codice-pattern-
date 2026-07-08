import java.sql.*;

public class Biblioteca {
    // Stringa di connessione a SQLite: creerà un file sul tuo PC chiamato biblioteca.db
    private static final String URL_DB = "jdbc:sqlite:biblioteca.db";

    public Biblioteca() {
        // Al costruttore chiediamo di creare la tabella nel database se non esiste già
        inizializzaDatabase();
    }

    // Metodo interno per connettersi al database
    private Connection connetti() throws SQLException {
        return DriverManager.getConnection(URL_DB);
    }

    // Crea la tabella dei libri nel database al primo avvio
    private void inizializzaDatabase() {
        String sql = "CREATE TABLE IF NOT EXISTS libri (" +
                     "titolo TEXT PRIMARY KEY, " +
                     "autore TEXT NOT NULL, " +
                     "anno INTEGER NOT NULL, " +
                     "disponibile INTEGER DEFAULT 1);"; // 1 = disponibile, 0 = in prestito

        try (Connection conn = this.connetti(); Statement stmt = conn.createStatement()) {
            stmt.execute(sql);
        } catch (SQLException e) {
            System.out.println("Errore nell'inizializzazione del database: " + e.getMessage());
        }
    }

    // MODIFICATO: Ora inserisce il libro direttamente nel Database permanente
    public void aggiungiLibro(Libro libro) {
        String sql = "INSERT INTO libri(titolo, autore, anno, disponibile) VALUES(?,?,?,?)";

        try (Connection conn = this.connetti(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, libro.getTitolo());
            pstmt.setString(2, libro.getAutore());
            pstmt.setInt(3, libro.getAnnoPubblicazione());
            pstmt.setInt(4, libro.isDisponibile() ? 1 : 0);
            pstmt.executeUpdate();
            System.out.println("Libro aggiunto con successo nel Database: " + libro.getTitolo());
        } catch (SQLException e) {
            // Se il titolo esiste già, il Database blocca l'inserimento (PRIMARY KEY) evitando i duplicati
            System.out.println("Errore: Il libro \"" + libro.getTitolo() + "\" è già presente nel catalogo (Duplicato).");
        }
    }

    // Legge tutti i libri salvati nel database e li stampa a schermo
    public void stampaCatalogo() {
        String sql = "SELECT * FROM libri";
        boolean vuoto = true;

        try (Connection conn = this.connetti();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                vuoto = false;
                Libro l = new Libro(
                    rs.getString("titolo"),
                    rs.getString("autore"),
                    rs.getInt("anno"),
                    rs.getInt("disponibile") == 1
                );
                System.out.println(l);
            }
            if (vuoto) {
                System.out.println("La biblioteca è vuota.");
            }

        } catch (SQLException e) {
            System.out.println("Errore nel caricamento del catalogo: " + e.getMessage());
        }
    }

    // Cerca un libro nel Database filtrando per titolo (senza fare caso a maiuscole/minuscole)
    public Libro cercaPerTitolo(String titolo) {
        String sql = "SELECT * FROM libri WHERE LOWER(titolo) = LOWER(?)";

        try (Connection conn = this.connetti(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, titolo);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return new Libro(
                    rs.getString("titolo"),
                    rs.getString("autore"),
                    rs.getInt("anno"),
                    rs.getInt("disponibile") == 1
                );
            }
        } catch (SQLException e) {
            System.out.println("Errore nella ricerca: " + e.getMessage());
        }
        return null; 
    }

    // Rimuove definitivamente un libro dal Database tramite il titolo
    public void rimuoviLibro(String titolo) {
        String sql = "DELETE FROM libri WHERE LOWER(titolo) = LOWER(?)";

        try (Connection conn = this.connetti(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, titolo);
            int righeModificate = pstmt.executeUpdate(); // Restituisce quante righe ha cancellato
            
            if (righeModificate > 0) {
                System.out.println("Libro \"" + titolo + "\" rimosso dal Database con successo.");
            } else {
                System.out.println("Impossibile rimuovere: il libro \"" + titolo + "\" non è in catalogo.");
            }
        } catch (SQLException e) {
            System.out.println("Errore nella rimozione: " + e.getMessage());
        }
    }

    // NUOVO: Permette alle altre persone di interagire prendendo o restituendo un libro
    public void gestisciPrestito(String titolo, boolean prendi) {
        Libro libro = cercaPerTitolo(titolo);
        if (libro == null) {
            System.out.println("Impossibile procedere: libro non trovato.");
            return;
        }

        if (prendi && !libro.isDisponibile()) {
            System.out.println("Ci dispiace, il libro è già stato preso in prestito da un'altra persona!");
            return;
        } else if (!prendi && libro.isDisponibile()) {
            System.out.println("Questo libro risulta già presente in biblioteca, non occorre restituirlo.");
            return;
        }

        // Cambia lo stato nel database (0 se preso, 1 se restituito)
        String sql = "UPDATE libri SET disponibile = ? WHERE LOWER(titolo) = LOWER(?)";
        try (Connection conn = this.connetti(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, prendi ? 0 : 1);
            pstmt.setString(2, titolo);
            pstmt.executeUpdate();
            
            if (prendi) {
                System.out.println("Prestito registrato con successo! Buona lettura.");
            } else {
                System.out.println("Libro restituito correttamente. Grazie!");
            }
        } catch (SQLException e) {
            System.out.println("Errore nella gestione del prestito: " + e.getMessage());
        }
    }

    // Chiede al database di fare l'ordinamento (molto più veloce rispetto a prima!)
    public void stampaOrdinato(String criterio) {
        String sql = "SELECT * FROM libri ORDER BY " + criterio;
        
        try (Connection conn = this.connetti();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            System.out.println("--- CATALOGO ORDINATO PER " + criterio.toUpperCase() + " ---");
            while (rs.next()) {
                Libro l = new Libro(
                    rs.getString("titolo"),
                    rs.getString("autore"),
                    rs.getInt("anno"),
                    rs.getInt("disponibile") == 1
                );
                System.out.println(l);
            }
        } catch (SQLException e) {
            System.out.println("Errore nell'ordinamento: " + e.getMessage());
        }
    }
}