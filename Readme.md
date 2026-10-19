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

---

## Aggiornamenti della dashboard

**Per una migliore gestione degli aggiornamenti puoi modificare solo i seguenti files:**
- contenuto della cartella helpers (mantieni la stessa interfaccia delle funzioni e classi)
- Components (aggiungene solo se ne li usi nella customView)
- qml/views/CustomView.qml
- viewmodels/custom_viewmodel.py

Procedura di aggiornamento

- Prima di procedere all'aggiornamento di una dashboard al nuovo template crea una copia di backup.
- Successivamente elimina tutto il contenuto della dashboard ad eccezione:
    - contenuto della cartella helpers
    - Components (solo se hai fatto modifiche)
    - qml/views/CustomView.qml
    - viewmodels/custom_viewmodel.py
- Copia i file del nuovo template nella deshboard
- Verifica che i file citati prima (che non hai eliminato) abbiamo tenuto la stessa interfaccia in modo che continiuno a comunicare con il resto del programma