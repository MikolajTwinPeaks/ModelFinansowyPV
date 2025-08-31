#!/bin/bash

echo '🔄 ALTERNATYWNA INSTALACJA STREAMLIT'
echo '====================================='
echo ''

cd ~/Desktop/ModelFinansowyPV

echo '📦 Instaluję Streamlit używając python3 -m pip...'
python3 -m pip install --user streamlit

echo ''
echo '🔍 Szukam zainstalowanego Streamlit...'
export PATH="$HOME/Library/Python/3.8/bin:$PATH"

echo ''
echo '✅ Sprawdzam instalację...'
python3 -c "import streamlit; print('Streamlit zainstalowany!')"

echo ''
echo '🚀 Uruchamiam aplikację przez Python...'
python3 -m streamlit run app.py

