#!pwsh

pyinstaller --noconsole --onefile --add-data "ui\pages;pages" ui\app.py

Remove-Item app.spec
