# Mettere Garage su GitHub e farne un APK

Guida passo passo, pensata per chi non ha mai usato GitHub. Non serve saper programmare.
Alla fine avrai due cose:

- un **link web** dell'app (si apre sul telefono e si installa sulla Home)
- un **APK** Android, ricompilato da GitHub a ogni modifica

---

## 1. Crea l'account GitHub

Vai su [github.com](https://github.com) e registrati. È gratuito.

## 2. Crea il repository

Dalla tua pagina GitHub, clicca il `+` in alto a destra → **New repository**.

- **Repository name**: `garage`
- **Description**: "App per le scadenze di manutenzione dei veicoli"
- Scegli **Public** o **Private**, come preferisci (l'APK si genera comunque)
- **Non** spuntare "Add a README file"

Clicca **Create repository**.

## 3. Carica i file

Nella pagina che si apre clicca **uploading an existing file**.

Trascina dentro **tutto il contenuto della cartella `Garage`**: le cartelle `web`, `app`,
`.github`, e i file `capacitor.config.json`, `package.json`, `.gitignore`, `README.md`,
`LICENSE`, `COME_PUBBLICARE.md`.

> Se il trascinamento delle cartelle non funziona dal browser, installa
> [GitHub Desktop](https://desktop.github.com): "Add" → "Add existing repository",
> scegli la cartella, poi "Publish repository".

In fondo alla pagina scrivi un messaggio breve ("Primo caricamento") e clicca **Commit changes**.

## 4. GitHub compila l'APK da solo

Appena i file sono caricati, GitHub avvia la compilazione.

1. Apri il tab **Actions** del repository.
2. Vedi un processo chiamato **"Build APK"** in corso (pallino giallo). Dura circa 5–10 minuti.
3. Quando diventa verde, cliccaci sopra.
4. In fondo alla pagina, sezione **Artifacts**, trovi **`garage-apk`**: scaricalo.
   È uno zip che contiene `garage.apk`.

Se il pallino diventa rosso: aprilo, guarda quale passo è fallito e incolla il messaggio,
si sistema.

## 5. Installa l'APK sul telefono

1. Passa `garage.apk` sul telefono (email a te stesso, cavo, Google Drive…).
2. Aprilo. Android chiederà di consentire l'installazione da questa fonte: accetta
   (**Impostazioni → App → Accesso speciale → Installa app sconosciute**).
3. Installa. L'icona compare tra le app.

> Ogni nuova build usa la stessa firma di test, quindi gli aggiornamenti si installano
> sopra il precedente senza disinstallare. Se un giorno dovesse dare errore di firma,
> disinstalla prima la vecchia versione.

## 6. Attiva il link web (una volta sola)

**Settings → Pages → Source: "GitHub Actions"** → salva.
Dopo qualche minuto, il processo **"Deploy web"** (già presente) pubblica la web app su un
indirizzo tipo `https://tuo-utente.github.io/garage/`. Da lì si installa sulla Home:
Chrome → menu → *Installa app*; Safari (iPhone) → Condividi → *Aggiungi a Home*.

Questo passo va fatto una volta sola: da qui in avanti resta attivo.

## 7. Pubblicare una versione "ufficiale" (Release)

Quando vuoi distribuire una versione precisa — anche a chi non sa nulla di GitHub —
crea un **tag**:

**tab Releases → Draft a new release → Choose a tag → scrivi `v1.0.0` → Publish**.

GitHub ricompila l'APK e crea la Release con, **già scritti nella descrizione**, i due
link pronti da girare a chiunque:

- 🤖 **Android** → l'APK allegato sotto "Assets"
- 🍎 **iPhone e altri** → il link della web app (punto 6)

Basta mandare l'indirizzo della Release (o di `.../releases/latest`, che punta sempre
all'ultima pubblicata): chi la apre sceglie da solo il link giusto per il suo telefono.

## 8. Aggiornare l'app in futuro

Modifica i file (anche solo `web/index.html`) e ricaricali su GitHub
(**Add file → Upload files**, oppure con GitHub Desktop). Ogni caricamento su `main`
rifà partire "Build APK": scarichi il nuovo APK da Actions come al punto 4.
Per una nuova versione ufficiale, ripeti il punto 7 con un tag successivo (`v1.0.1`…).

---

## Note

- **Dati e file** restano sul telefono. Nell'APK valgono gli stessi limiti di spazio del
  browser: tieni foto e allegati leggeri.
- **Aprire un allegato** dall'APK potrebbe non funzionare in questa prima versione:
  serve un componente nativo in più, da aggiungere in un secondo momento.
- **La cartella `app/`** (Flutter) non viene usata per questo APK: è una versione
  separata, tenuta come base per un'eventuale app nativa futura.
- **Icona dell'app**: per ora è quella predefinita di Capacitor. Si può personalizzare
  più avanti.
