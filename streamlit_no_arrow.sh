#!/bin/bash

echo '🔧 INSTALACJA STREAMLIT BEZ PYARROW'
echo '===================================='
echo ''

cd ~/Desktop/ModelFinansowyPV

echo '1. Instaluję podstawowe biblioteki...'
pip3 install --user numpy pandas plotly

echo ''
echo '2. Instaluję Streamlit bez pyarrow...'
pip3 install --user streamlit --no-deps
pip3 install --user altair toolz jinja2 rich click toml validators gitpython watchdog protobuf pydeck tornado

echo ''
echo '3. Uruchamiam aplikację...'
python3 -m streamlit run app.py

