# SerialX Template

Un template completo e preconfigurato per accelerare lo sviluppo di progetti basati sulla comunicazione seriale tra Arduino e computer desktop tramite **SerialX**.

---

## Struttura del Progetto

* `firmware/`: Contiene il codice firmware (`driver-arduino.ino`) da caricare su Arduino.
* `dashboard/`: Applicazione client per la gestione della comunicazione, la generazione di script Python su misura e l'interfaccia grafica personalizzabile.

---

## Caratteristiche Principali

* **GUI Moderna in QML & PySide:** Interfaccia grafica fluida e facilmente personalizzabile, con supporto nativo integrato per i temi **Light** e **Dark**.
* **Generazione di Script su Misura:** Il codice Python include una sezione dedicata alla creazione dinamica di script di comunicazione basati sui parametri selezionati nell'interfaccia utente.
* **Sistema di Aggiornamento (In Sviluppo):** Predisposto sia per ricevere aggiornamenti del template (lato sviluppatore), sia per aggiornare la tua applicazione finale una volta distribuita.
* **Licenza GNU:** Questo template è rilasciato sotto licenza GNU. Se lo modifichi o lo distribuisci, ricordati di mantenere il codice open-source!

---

## Per Iniziare

1. Esegui lo script di inizializzazione `initialize_serialx_project.ps1`.
2. Scegli la directory in cui creare il nuovo progetto.
3. Inserisci le informazioni richieste per configurare il template.
4. Carica il firmware presente nella cartella `firmware/` su Arduino utilizzando l'Arduino IDE.
5. Installa la libreria dedicata seguendo le istruzioni nel repository ufficiale [SerialX per Arduino IDE](http://github.com/SerialXProject/serialx-arduino).
6. Spostati nella cartella `dashboard/` e avvia l'applicazione cross-platform eseguendo:
```powershell
pwsh run_ui.ps1

```



---

## Requisiti di Sistema

* **Arduino IDE:** Necessario per la compilazione e il caricamento del firmware.
* **Python 3.14:** Richiesto per l'esecuzione degli script di comunicazione runtime generati dal client. 
