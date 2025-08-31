#!/bin/bash

echo '☀️ Instalacja Modelu Finansowego PV'
echo '=================================='
echo ''

# Przejście do folderu projektu
cd ~/Desktop/ModelFinansowyPV

# Instalacja bibliotek
echo '📦 Instalowanie bibliotek Python...'
pip3 install -r requirements.txt

echo ''
echo '✅ Instalacja zakończona!'
echo ''
echo '🚀 Uruchamianie aplikacji Streamlit...'
echo ''
echo '----------------------------------------'
echo 'Aplikacja otworzy się w przeglądarce'
echo 'Aby zatrzymać: naciśnij Ctrl+C'
echo '----------------------------------------'
echo ''

# Uruchomienie Streamlit
streamlit run app.py

