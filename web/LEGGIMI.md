# Garage — web app

Versione web dell'app: si apre nel browser, si installa sulla schermata Home del telefono e da lì si comporta come una normale app, a schermo intero e senza barra del browser.

## Metterla online (gratis, 5 minuti)

1. Su GitHub crea un repository pubblico, per esempio `garage-web`.
2. Carica il file `index.html` (Add file → Upload files → Commit changes).
3. Vai su **Settings → Pages**. Sotto "Branch" scegli `main`, cartella `/ (root)`, e salva.
4. Dopo un paio di minuti la pagina Pages ti mostra l'indirizzo, del tipo
   `https://tuo-utente.github.io/garage-web/`.

Quell'indirizzo funziona per chiunque, da qualsiasi telefono.

## Installarla sul telefono

**Android (Chrome):** apri l'indirizzo → menu ⋮ → *Installa app* (o *Aggiungi a schermata Home*).

**iPhone (Safari):** apri l'indirizzo → pulsante Condividi → *Aggiungi a Home*.

Comparirà un'icona come le altre app.

## Dove finiscono i dati

Restano nel browser del telefono, sul dispositivo. Nessun account, nessun server.

Due conseguenze da tenere a mente: i dati non si sincronizzano tra telefono e computer, e se cancelli i dati di navigazione del browser spariscono anche i veicoli. Per un uso personale su un solo telefono va benissimo.

## Il calendario

Il pulsante calendario offre due strade:

- **Google Calendar** — si apre direttamente con l'evento già compilato, basta confermare.
- **Calendario Apple o altro** — scarica un file `.ics`; su iPhone toccandolo si apre il Calendario con l'evento pronto.

L'evento include un promemoria una settimana prima.

## Provarla senza metterla online

Scarica `index.html` sul computer e aprilo con doppio clic: funziona identico, solo in locale.

---

## E la versione nativa?

Nella cartella `garage_app` c'è lo stesso progetto scritto in Flutter, che genera vere app Android e iOS. Rispetto a questa versione web guadagna le notifiche di sistema (che avvisano anche se non apri l'app) e la possibilità di finire sugli store, ma richiede di essere compilato su un computer.

Le due versioni possono convivere nello stesso repository: chi vuole provare subito usa il link web, chi vuole contribuire lavora sul codice Flutter.
