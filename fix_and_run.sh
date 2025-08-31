#!/bin/bash

echo '🔧 NAPRAWIANIE INSTALACJI'
echo '========================='
echo ''

cd ~/Desktop/ModelFinansowyPV

echo '1. Instaluję Streamlit...'
pip3 install streamlit --no-cache-dir

echo ''
echo '2. Instaluję Pandas...'
pip3 install pandas --no-cache-dir

echo ''
echo '3. Instaluję NumPy...'
pip3 install numpy --no-cache-dir

echo ''
echo '4. Instaluję Plotly...'
pip3 install plotly --no-cache-dir

echo ''
echo '5. Instaluję numpy-financial...'
pip3 install numpy-financial --no-cache-dir

echo ''
echo '✅ Instalacja naprawiona!'
echo ''
echo '🚀 Uruchamiam aplikację...'
streamlit run app.py

