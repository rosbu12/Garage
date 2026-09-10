# Garage

App per Android e iOS che tiene traccia delle scadenze di manutenzione dei tuoi veicoli: bollo, assicurazione, tagliando e inversione gomme.

## Cosa fa

- **Più veicoli.** Auto, moto, camper: ognuno con le sue scadenze.
- **Due modi di inserire una scadenza.** Se la conosci (bollo, assicurazione) la inserisci direttamente. Se invece sai solo quando hai fatto l'ultima manutenzione (tagliando, gomme), inserisci quella data e l'app calcola da sola la prossima scadenza. L'intervallo è modificabile: 3, 6, 12 o 24 mesi.
- **Colore per stato.** Verde quando è tutto a posto, giallo entro i 30 giorni, rosso quando è scaduto, grigio quando non hai ancora impostato nulla.
- **Calendario con un tocco.** Il pulsante apre direttamente Google Calendar o Calendario di Apple con l'evento già compilato e un promemoria una settimana prima. Nessun file da scaricare.
- **"Fatto".** Quando registri che una manutenzione è stata eseguita, l'app fa ripartire il conteggio e calcola la prossima scadenza senza doverla reinserire.
- **Tutto in locale.** I dati restano sul telefono. Nessun account, nessun server, nessuna raccolta dati.

## Come si usa

- Tocca una scheda per impostare la scadenza.
- Tieni premuto su un veicolo per rinominarlo, cambiarne la targa o eliminarlo.
- Tocca il segno di spunta su una scheda per registrare che la manutenzione è stata fatta oggi.

## Installazione per lo sviluppo

Serve [Flutter](https://docs.flutter.dev/get-started/install) 3.19 o successivo.

```bash
git clone https://github.com/<tuo-utente>/garage.git
cd garage
flutter pub get
flutter run
```

Per generare gli installabili:

```bash
flutter build apk --release     # Android
flutter build ipa --release     # iOS (richiede macOS e Xcode)
```

## Struttura del progetto

```
lib/
├── main.dart                       punto di ingresso
├── models/
│   ├── vehicle.dart                un veicolo
│   ├── deadline_category.dart      le quattro categorie e i loro intervalli
│   └── deadline_entry.dart         una scadenza, con il calcolo automatico
├── services/
│   ├── storage_service.dart        salvataggio locale
│   └── calendar_service.dart       integrazione con il calendario di sistema
├── screens/
│   └── home_screen.dart            schermata principale
├── widgets/
│   ├── vehicle_selector.dart       riga dei veicoli
│   ├── vehicle_editor_sheet.dart   aggiunta e modifica veicolo
│   ├── deadline_card.dart          scheda di una scadenza
│   └── deadline_editor_sheet.dart  compilazione di una scadenza
└── theme/
    └── app_theme.dart              colori e stile
```

## Idee per chi vuole contribuire

- Notifiche locali oltre agli eventi sul calendario
- Categorie personalizzate (revisione, catena di distribuzione, cambio olio)
- Storico delle manutenzioni fatte, con costi
- Backup ed esportazione dei dati
- Traduzioni in altre lingue
- Widget da mettere sulla schermata home

Pull request benvenute.

## Licenza

MIT — vedi [LICENSE](LICENSE).
