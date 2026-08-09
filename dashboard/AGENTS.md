SerialX è un'applicazione desktop Python che consente di comunicare con dispositivi Arduino via porta seriale. Si tratta di una GUI costruita con PySide6 e QML che permette di gestire allarmi, date, ore e valori di sensori. L'applicazione segue il pattern MVVM dove la logica risiede nei ViewModel Python e l'interfaccia utente è definita in QML.

La struttura del progetto è organizzata in src/app per il codice applicativo e qt/qml per l'interfaccia. Il file main.py in src/app/main.py è il punto di ingresso che inizializza l'applicazione PySide6 e carica il file main.qml. I ViewModel come HomeViewModel e LoadingViewModel contengono la logica di business e vengono esposti a QML tramite context properties.

Il cuore dell'applicazione è la funzione generate_script in src/app/helpers/script_generator.py che prende un oggetto SerialXData contenente informazioni come orario, data, formato 24h, giorno della settimana, allarmi giornalieri, allarmi settimanali, valore di luce notturna e errore di temperatura, e lo converte in uno script compatibile con Arduino.

L'interfaccia grafica è costruita con una finestra principale di 1280x800 pixel con tema scuro che dispone gli elementi usando uno StackView per navigare tra le diverse schermate. Ci sono viste per la home, il caricamento, le impostazioni e un editor di variabili. I componenti riutilizzabili come StatusRow, SystemCard e ThemeCard permettono di costruire l'interfaccia in modo modulare.

Per eseguire l'applicazione basta lanciare python -m src.app.main o eseguire run_ui.ps1. Per compilare l'eseguibile standalone si usa build.ps1. L'applicazione comunica direttamente con Arduino via seriale senza utilizzare alcun database.
