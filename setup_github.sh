#!/bin/bash

echo '🚀 PRZYGOTOWANIE DO GITHUB'
echo '=========================='
echo ''

cd ~/Desktop/ModelFinansowyPV

# Inicjalizacja Git
echo '1. Inicjalizuję repozytorium Git...'
git init

# Dodanie plików
echo '2. Dodaję pliki do repozytorium...'
git add .

# Pierwszy commit
echo '3. Tworzę pierwszy commit...'
git commit -m '🚀 Initial commit - Model Finansowy PV 1MW'

echo ''
echo '✅ Repozytorium Git gotowe!'
echo ''
echo '📋 NASTĘPNE KROKI:'
echo '1. Utwórz nowe repozytorium na GitHub.com'
echo '2. Skopiuj URL repozytorium (np. https://github.com/twoj-username/ModelFinansowyPV.git)'
echo '3. Wpisz poniższe komendy:'
echo ''
echo 'git remote add origin URL_TWOJEGO_REPO'
echo 'git branch -M main'
echo 'git push -u origin main'
echo ''
echo '🌐 DLA WERSJI HTML (GitHub Pages):'
echo '1. Idź do Settings → Pages w swoim repo na GitHub'
echo '2. Source: Deploy from branch'
echo '3. Branch: main, folder: / (root)'
echo '4. Save'
echo '5. Twoja strona będzie dostępna pod: https://twoj-username.github.io/ModelFinansowyPV/model_pv.html'
echo ''
echo '☁️ DLA STREAMLIT CLOUD:'
echo '1. Idź na https://share.streamlit.io'
echo '2. New app → Use existing repo'
echo '3. Wybierz swoje repo'
echo '4. Main file: app.py'
echo '5. Deploy!'

