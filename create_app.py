# Skrypt tworzący app.py
app_code = '''"""
Model Finansowy Farmy Fotowoltaicznej
Aplikacja Streamlit - Wersja 1.0
"""

import streamlit as st
import pandas as pd
import numpy as np
import plotly.graph_objects as go
import plotly.express as px
from datetime import datetime, timedelta
import numpy_financial as npf
from io import BytesIO
import base64

# Konfiguracja strony
st.set_page_config(
    page_title="Model Finansowy PV 1MW",
    page_icon="☀️",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Test podstawowy
st.title("☀️ Model Finansowy Farmy Fotowoltaicznej 1MW")
st.write("Aplikacja działa! Teraz dodajmy pełną funkcjonalność...")

# Prosty test
if st.button("Test NPV"):
    st.success("NPV = -531 PLN (wartość testowa)")
'''

with open('/Users/mikolaj/Desktop/ModelFinansowyPV/app.py', 'w') as f:
    f.write(app_code)
print('Plik app.py utworzony!')
