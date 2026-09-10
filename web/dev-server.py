#!/usr/bin/env python3
"""
Server di sviluppo per la web app Garage.

A cosa serve
------------
Apre `index.html` nel browser e lo ricarica DA SOLO ogni volta che salvi
il file. Così puoi vedere ogni modifica in tempo reale mentre lavori
all'estetica e alle funzionalità.

Come si usa
-----------
    python web/dev-server.py

Poi apri http://localhost:4173 nel browser. Lascia la finestra del
terminale aperta: finché gira, il browser si aggiorna a ogni salvataggio.
Per fermarlo: Ctrl+C.

Vedere l'anteprima dal telefono
-------------------------------
All'avvio il server stampa anche un indirizzo tipo http://192.168.x.x:4173
Aprilo dal telefono: deve essere sulla stessa rete Wi-Fi del computer.
La prima volta Windows chiede se consentire l'accesso: spunta "Reti private"
e conferma. Anche il telefono si ricarica da solo a ogni salvataggio.

Il codice qui sotto NON fa parte dell'app: serve solo durante lo sviluppo.
Il file che finisce online resta `index.html` e basta.
"""

import http.server
import os
import queue
import socket
import socketserver
import threading
import time

HOST = os.environ.get("HOST", "0.0.0.0")
PORT = int(os.environ.get("PORT", "4173"))
ROOT = os.path.dirname(os.path.abspath(__file__))
WATCH = [os.path.join(ROOT, "index.html")]

# Script iniettato in index.html solo quando viene servito da questo server.
# Apre un canale con il server e ricarica la pagina quando un file cambia.
LIVE_RELOAD = b"""
<script>
(function () {
  var es = new EventSource("/__livereload");
  es.onmessage = function () { location.reload(); };
  es.onerror = function () { es.close(); setTimeout(function () { location.reload(); }, 1000); };
})();
</script>
"""

# Ogni browser connesso ha la sua coda; quando un file cambia mettiamo
# un segnale in tutte le code e ogni pagina si ricarica.
clients = []
clients_lock = threading.Lock()


def watch_files():
    last = {}
    for path in WATCH:
        try:
            last[path] = os.path.getmtime(path)
        except OSError:
            last[path] = 0
    while True:
        time.sleep(0.4)
        changed = False
        for path in WATCH:
            try:
                mtime = os.path.getmtime(path)
            except OSError:
                continue
            if last.get(path) != mtime:
                last[path] = mtime
                changed = True
        if changed:
            with clients_lock:
                for q in list(clients):
                    q.put(b"data: reload\n\n")


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def log_message(self, fmt, *args):
        # Tiene pulito il terminale: mostra solo le richieste di pagina.
        if "__livereload" in (self.path or ""):
            return
        super().log_message(fmt, *args)

    def do_GET(self):
        if self.path == "/__livereload":
            self.handle_livereload()
            return

        path = self.path.split("?", 1)[0]
        if path in ("/", "/index.html"):
            self.serve_index()
            return

        super().do_GET()

    def serve_index(self):
        try:
            with open(os.path.join(ROOT, "index.html"), "rb") as f:
                html = f.read()
        except OSError:
            self.send_error(404, "index.html non trovato")
            return

        if b"</body>" in html:
            html = html.replace(b"</body>", LIVE_RELOAD + b"</body>", 1)
        else:
            html += LIVE_RELOAD

        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(html)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(html)

    def handle_livereload(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Connection", "keep-alive")
        self.end_headers()

        q = queue.Queue()
        with clients_lock:
            clients.append(q)
        try:
            self.wfile.write(b": connesso\n\n")
            self.wfile.flush()
            while True:
                try:
                    msg = q.get(timeout=15)
                except queue.Empty:
                    msg = b": ping\n\n"  # tiene viva la connessione
                self.wfile.write(msg)
                self.wfile.flush()
        except (BrokenPipeError, ConnectionResetError):
            pass
        finally:
            with clients_lock:
                if q in clients:
                    clients.remove(q)


class Server(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True
    allow_reuse_address = True


def lan_ip():
    """Indirizzo del computer sulla rete locale (per aprirlo dal telefono)."""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("8.8.8.8", 80))
        return s.getsockname()[0]
    except OSError:
        return None
    finally:
        s.close()


def main():
    threading.Thread(target=watch_files, daemon=True).start()
    with Server((HOST, PORT), Handler) as httpd:
        print("Garage dev server")
        print(f"  sul computer:  http://localhost:{PORT}")
        ip = lan_ip()
        if ip:
            print(f"  dal telefono:  http://{ip}:{PORT}   (stessa rete Wi-Fi)")
        print("Salva index.html e la pagina si ricarica da sola. Ctrl+C per fermare.")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nFermato.")


if __name__ == "__main__":
    main()
