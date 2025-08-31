# ☀️ Model Finansowy Farmy Fotowoltaicznej 1MW

## 📊 Demo Online
- **🌐 Wersja HTML:** [Otwórz w przeglądarce](https://twoj-username.github.io/ModelFinansowyPV/model_pv.html)
- **🚀 Wersja Streamlit:** [Uruchom na Streamlit Cloud](https://share.streamlit.io)

## 📋 Opis Projektu
Interaktywny model finansowy dla farmy fotowoltaicznej o mocy 1 MW. Aplikacja umożliwia analizę opłacalności inwestycji w energię słoneczną z uwzględnieniem wszystkich kluczowych parametrów finansowych i technicznych.

## 🎯 Funkcjonalności
- ✅ Kalkulacja NPV, IRR, MIRR, WACC
- ✅ 30-letnia projekcja Cash Flow
- ✅ Analiza wrażliwości
- ✅ Interaktywne wykresy
- ✅ Zarządzanie scenariuszami
- ✅ Eksport do Excel/CSV

## 🚀 Uruchomienie

### Opcja 1: Wersja HTML (bez instalacji)
```bash
# Po prostu otwórz plik w przeglądarce
open model_pv.html
```

### Opcja 2: Streamlit (Python)
```bash
# Instalacja
pip install -r requirements.txt

# Uruchomienie
streamlit run app.py
```

### Opcja 3: Streamlit Cloud (online)
1. Fork tego repozytorium
2. Idź na [share.streamlit.io](https://share.streamlit.io)
3. Połącz z GitHub i wybierz to repo
4. Deploy!

## 📁 Struktura Projektu
```
ModelFinansowyPV/
├── app.py                 # Główna aplikacja Streamlit
├── model_pv.html         # Wersja HTML (standalone)
├── requirements.txt      # Zależności Python
├── README.md            # Dokumentacja
└── data/
    └── (pliki danych)
```

## 📈 Parametry Modelu

### Parametry Finansowe
- Kurs EUR: 4.25 PLN
- WIBOR 3M: 4.99%
- Stopa podatku CIT: 19%

### Parametry Techniczne
- Moc instalacji: 1.0 MW
- Produkcja roczna: 5,324.58 MWh
- Degradacja: 0.5% rocznie
- Cena energii: 459.40 PLN/MWh

### Struktura Finansowania
- CAPEX: 1,800,000 PLN
- Kapitał własny: 970,000 PLN (54%)
- Dług: 830,000 PLN (46%)
- Oprocentowanie: 7.2%

## 📊 Wyniki Bazowe
- **NPV:** -531 PLN
- **IRR:** 4.0%
- **WACC:** 7.0%
- **Okres zwrotu:** 16.8 lat

## 🛠️ Technologie
- Python 3.8+
- Streamlit
- Plotly
- Pandas
- NumPy
- HTML5/JavaScript (wersja standalone)

## 📝 Licencja
MIT License

## 👥 Autor
Model wygenerowany automatycznie przy pomocy Claude AI

## 🤝 Kontakt
[Twój Email](mailto:twoj.email@example.com)

---
⭐ Jeśli projekt Ci się podoba, zostaw gwiazdkę!

