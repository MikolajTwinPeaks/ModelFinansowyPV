"""
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

# Inicjalizacja session state
if 'parameters' not in st.session_state:
    st.session_state.parameters = {
        # Parametry finansowe
        'eur_rate': 4.25,
        'wibor_3m': 4.99,
        'tax_rate': 19,
        
        # Parametry techniczne
        'power_mw': 1.0,
        'annual_production_mwh': 5324.58,
        'degradation_rate': 0.5,
        'energy_price_pln_mwh': 459.40,
        
        # Parametry czasowe
        'project_start_date': datetime(2026, 1, 1),
        'lease_period_years': 29,
        'sales_start_months': 15,
        
        # Koszty operacyjne miesięczne (PLN)
        'service_cost': 1150.49,
        'lease_cost': 750.00,
        'management_cost': 3000.00,
        'security_cost': 872.00,
        'accounting_cost': 650.00,
        'admin_cost': 500.00,
        'bank_cost': 80.00,
        'property_insurance': 185.80,
        'business_insurance': 221.00,
        
        # Koszty roczne
        'property_tax_per_ha': 1000.00,
        'building_tax_rate': 2.0,
        
        # Inwestycja
        'capex': 1800000.00,
        
        # Finansowanie
        'equity': 970000.00,
        'debt': 830000.00,
        'interest_rate': 7.2,
        
        # Kapitał obrotowy
        'receivables_days': 60,
        'payables_days': 14,
    }

# Funkcje kalkulacyjne
@st.cache_data
def calculate_cash_flows(params, years=30):
    """Kalkulacja przepływów pieniężnych"""
    cf = []
    
    # Degradacja mocy
    degradation = [(1 - params['degradation_rate']/100) ** i for i in range(years)]
    
    for year in range(years):
        # Przychody
        if year == 0:
            # Pierwszy rok - tylko część roku (po okresie budowy)
            production = params['annual_production_mwh'] * degradation[year] * (12 - params['sales_start_months']) / 12
        else:
            production = params['annual_production_mwh'] * degradation[year]
        
        revenue = production * params['energy_price_pln_mwh']
        
        # Koszty operacyjne
        monthly_costs = (
            params['service_cost'] +
            params['lease_cost'] +
            params['management_cost'] +
            params['security_cost'] +
            params['accounting_cost'] +
            params['admin_cost'] +
            params['bank_cost'] +
            params['property_insurance'] +
            params['business_insurance']
        )
        
        annual_costs = monthly_costs * 12
        
        # Podatek od nieruchomości
        property_tax = params['property_tax_per_ha']
        building_tax = params['capex'] * params['building_tax_rate'] / 100
        
        total_costs = annual_costs + property_tax + building_tax
        
        # EBITDA
        ebitda = revenue - total_costs
        
        # Amortyzacja (liniowa, 25 lat)
        depreciation = params['capex'] / 25 if year < 25 else 0
        
        # EBIT
        ebit = ebitda - depreciation
        
        # Podatek
        tax = max(0, ebit * params['tax_rate'] / 100)
        
        # Cash flow operacyjny
        operating_cf = ebit - tax + depreciation
        
        cf.append(operating_cf)
    
    return np.array(cf)

@st.cache_data
def calculate_npv(cash_flows, wacc, initial_investment):
    """Kalkulacja NPV"""
    return npf.npv(wacc/100, np.concatenate([[-initial_investment], cash_flows]))

@st.cache_data
def calculate_irr(cash_flows, initial_investment):
    """Kalkulacja IRR"""
    try:
        all_cf = np.concatenate([[-initial_investment], cash_flows])
        return npf.irr(all_cf) * 100
    except:
        return np.nan

@st.cache_data
def calculate_wacc(params):
    """Kalkulacja WACC"""
    total_capital = params['equity'] + params['debt']
    equity_weight = params['equity'] / total_capital
    debt_weight = params['debt'] / total_capital
    
    # Koszt kapitału własnego (uproszczony)
    risk_free_rate = 5.24
    market_premium = 1.24
    beta = 0.88
    specific_risk_premium = 2.0
    
    cost_of_equity = risk_free_rate + beta * market_premium + specific_risk_premium
    
    # Koszt długu po opodatkowaniu
    after_tax_cost_of_debt = params['interest_rate'] * (1 - params['tax_rate']/100)
    
    # WACC
    wacc = equity_weight * cost_of_equity + debt_weight * after_tax_cost_of_debt
    
    return wacc

# Sidebar z parametrami
with st.sidebar:
    st.header("⚙️ Parametry Modelu")
    
    # Parametry finansowe
    with st.expander("💰 Parametry Finansowe", expanded=True):
        st.session_state.parameters['eur_rate'] = st.number_input(
            "Kurs EUR (PLN)",
            min_value=3.0,
            max_value=6.0,
            value=st.session_state.parameters['eur_rate'],
            step=0.01,
            help="Kurs wymiany EUR/PLN"
        )
        
        st.session_state.parameters['wibor_3m'] = st.slider(
            "WIBOR 3M (%)",
            min_value=0.0,
            max_value=10.0,
            value=st.session_state.parameters['wibor_3m'],
            step=0.01
        )
        
        st.session_state.parameters['tax_rate'] = st.selectbox(
            "Stopa podatku CIT (%)",
            options=[9, 19, 23],
            index=1
        )
    
    # Parametry techniczne
    with st.expander("⚡ Parametry Techniczne"):
        st.session_state.parameters['power_mw'] = st.number_input(
            "Moc instalacji (MW)",
            min_value=0.1,
            max_value=10.0,
            value=st.session_state.parameters['power_mw'],
            step=0.1
        )
        
        st.session_state.parameters['annual_production_mwh'] = st.number_input(
            "Produkcja roczna (MWh)",
            min_value=1000.0,
            max_value=20000.0,
            value=st.session_state.parameters['annual_production_mwh'],
            step=10.0
        )
        
        st.session_state.parameters['degradation_rate'] = st.slider(
            "Degradacja roczna (%)",
            min_value=0.0,
            max_value=2.0,
            value=st.session_state.parameters['degradation_rate'],
            step=0.1
        )
        
        st.session_state.parameters['energy_price_pln_mwh'] = st.number_input(
            "Cena energii (PLN/MWh)",
            min_value=100.0,
            max_value=1000.0,
            value=st.session_state.parameters['energy_price_pln_mwh'],
            step=10.0
        )
    
    # Koszty operacyjne
    with st.expander("💸 Koszty Operacyjne (miesięczne)"):
        st.session_state.parameters['service_cost'] = st.number_input(
            "Serwis instalacji (PLN)",
            value=st.session_state.parameters['service_cost'],
            step=10.0
        )
        
        st.session_state.parameters['lease_cost'] = st.number_input(
            "Dzierżawa (PLN)",
            value=st.session_state.parameters['lease_cost'],
            step=10.0
        )
        
        st.session_state.parameters['management_cost'] = st.number_input(
            "Zarządzanie (PLN)",
            value=st.session_state.parameters['management_cost'],
            step=10.0
        )
        
        st.session_state.parameters['security_cost'] = st.number_input(
            "Ochrona (PLN)",
            value=st.session_state.parameters['security_cost'],
            step=10.0
        )
    
    # Inwestycja i finansowanie
    with st.expander("🏗️ Inwestycja i Finansowanie"):
        st.session_state.parameters['capex'] = st.number_input(
            "CAPEX - koszt inwestycji (PLN)",
            min_value=100000.0,
            max_value=10000000.0,
            value=st.session_state.parameters['capex'],
            step=10000.0
        )
        
        st.session_state.parameters['equity'] = st.number_input(
            "Kapitał własny (PLN)",
            min_value=0.0,
            max_value=st.session_state.parameters['capex'],
            value=st.session_state.parameters['equity'],
            step=10000.0
        )
        
        # Automatyczne obliczenie długu
        st.session_state.parameters['debt'] = st.session_state.parameters['capex'] - st.session_state.parameters['equity']
        
        st.metric("Dług (PLN)", f"{st.session_state.parameters['debt']:,.0f}")
        
        st.session_state.parameters['interest_rate'] = st.slider(
            "Oprocentowanie kredytu (%)",
            min_value=0.0,
            max_value=15.0,
            value=st.session_state.parameters['interest_rate'],
            step=0.1
        )

# Główny obszar aplikacji
st.title("☀️ Model Finansowy Farmy Fotowoltaicznej 1 MW")
st.markdown("---")

# Obliczenia
with st.spinner("Obliczanie..."):
    cash_flows = calculate_cash_flows(st.session_state.parameters)
    wacc = calculate_wacc(st.session_state.parameters)
    npv = calculate_npv(cash_flows, wacc, st.session_state.parameters['capex'])
    irr = calculate_irr(cash_flows, st.session_state.parameters['capex'])
    
    # Prosty okres zwrotu
    cumulative_cf = np.cumsum(cash_flows)
    payback_idx = np.where(cumulative_cf > st.session_state.parameters['capex'])[0]
    payback_period = payback_idx[0] if len(payback_idx) > 0 else None

# Tabs
tab1, tab2, tab3, tab4, tab5 = st.tabs(
    ["📊 Dashboard", "📈 Analiza CF", "🎯 Wrażliwość", "📑 Raporty", "💾 Scenariusze"]
)

with tab1:
    # KPI Metrics
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        st.metric(
            "NPV",
            f"{npv:,.0f} PLN",
            delta=None,
            delta_color="normal" if npv > 0 else "inverse"
        )
        if npv > 0:
            st.success("Projekt rentowny")
        else:
            st.error("Projekt nierentowny")
    
    with col2:
        st.metric(
            "IRR",
            f"{irr:.1f}%" if not np.isnan(irr) else "N/A",
            delta=f"{(irr - wacc):.1f}pp" if not np.isnan(irr) else None,
            delta_color="normal" if irr > wacc else "inverse"
        )
    
    with col3:
        st.metric(
            "WACC",
            f"{wacc:.1f}%",
            help="Średnioważony koszt kapitału"
        )
    
    with col4:
        st.metric(
            "Okres zwrotu",
            f"{payback_period} lat" if payback_period else "> 30 lat",
            help="Prosty okres zwrotu"
        )
    
    st.markdown("---")
    
    # Wykresy
    col1, col2 = st.columns(2)
    
    with col1:
        # Wykres Cash Flow
        fig_cf = go.Figure()
        
        years = list(range(1, len(cash_flows) + 1))
        
        fig_cf.add_trace(go.Bar(
            x=years,
            y=cash_flows,
            name='Cash Flow',
            marker_color=['green' if cf > 0 else 'red' for cf in cash_flows]
        ))
        
        fig_cf.add_trace(go.Scatter(
            x=years,
            y=np.cumsum(cash_flows),
            name='Skumulowany CF',
            mode='lines+markers',
            yaxis='y2',
            line=dict(color='blue', width=2)
        ))
        
        fig_cf.add_hline(
            y=st.session_state.parameters['capex'],
            line_dash="dash",
            annotation_text="CAPEX",
            yaxis='y2'
        )
        
        fig_cf.update_layout(
            title="Przepływy Pieniężne",
            xaxis_title="Rok",
            yaxis_title="Cash Flow (PLN)",
            yaxis2=dict(
                title="Skumulowany CF (PLN)",
                overlaying='y',
                side='right'
            ),
            hovermode='x unified',
            height=400
        )
        
        st.plotly_chart(fig_cf, use_container_width=True)
    
    with col2:
        # Struktura finansowania
        fig_financing = go.Figure(data=[
            go.Pie(
                labels=['Kapitał własny', 'Dług'],
                values=[
                    st.session_state.parameters['equity'],
                    st.session_state.parameters['debt']
                ],
                hole=.3,
                marker_colors=['#2E7D32', '#C62828']
            )
        ])
        
        fig_financing.update_layout(
            title="Struktura Finansowania",
            height=400
        )
        
        st.plotly_chart(fig_financing, use_container_width=True)
    
    # Tabela przepływów
    st.subheader("📋 Projekcja Przepływów (pierwsze 10 lat)")
    
    # Przygotowanie danych do tabeli
    df_projection = pd.DataFrame({
        'Rok': range(1, min(11, len(cash_flows) + 1)),
        'Produkcja (MWh)': [
            st.session_state.parameters['annual_production_mwh'] * 
            (1 - st.session_state.parameters['degradation_rate']/100) ** i 
            for i in range(min(10, len(cash_flows)))
        ],
        'Przychody (PLN)': [
            st.session_state.parameters['annual_production_mwh'] * 
            (1 - st.session_state.parameters['degradation_rate']/100) ** i *
            st.session_state.parameters['energy_price_pln_mwh']
            for i in range(min(10, len(cash_flows)))
        ],
        'Cash Flow (PLN)': cash_flows[:10]
    })
    
    # Formatowanie
    df_projection['Produkcja (MWh)'] = df_projection['Produkcja (MWh)'].round(0)
    df_projection['Przychody (PLN)'] = df_projection['Przychody (PLN)'].round(0)
    df_projection['Cash Flow (PLN)'] = df_projection['Cash Flow (PLN)'].round(0)
    
    st.dataframe(
        df_projection.style.format({
            'Produkcja (MWh)': '{:,.0f}',
            'Przychody (PLN)': '{:,.0f}',
            'Cash Flow (PLN)': '{:,.0f}'
        }).applymap(
            lambda x: 'color: red' if x < 0 else 'color: green',
            subset=['Cash Flow (PLN)']
        ),
        use_container_width=True
    )

with tab2:
    st.header("📈 Szczegółowa Analiza Cash Flow")
    
    # Wybór zakresu lat
    year_range = st.slider(
        "Wybierz zakres lat do analizy",
        min_value=1,
        max_value=30,
        value=(1, 30)
    )
    
    # Wykres wodospadowy
    fig_waterfall = go.Figure(go.Waterfall(
        name="Cash Flow",
        orientation="v",
        measure=["relative"] * len(cash_flows[year_range[0]-1:year_range[1]]),
        x=list(range(year_range[0], year_range[1]+1)),
        y=cash_flows[year_range[0]-1:year_range[1]],
        connector={"line": {"color": "rgb(63, 63, 63)"}},
    ))
    
    fig_waterfall.update_layout(
        title="Wodospad Cash Flow",
        xaxis_title="Rok",
        yaxis_title="Cash Flow (PLN)",
        height=500
    )
    
    st.plotly_chart(fig_waterfall, use_container_width=True)

with tab3:
    st.header("🎯 Analiza Wrażliwości")
    
    # Wybór parametru do analizy
    sensitivity_param = st.selectbox(
        "Wybierz parametr do analizy wrażliwości",
        options=[
            'energy_price_pln_mwh',
            'annual_production_mwh',
            'capex',
            'service_cost',
            'interest_rate'
        ],
        format_func=lambda x: {
            'energy_price_pln_mwh': 'Cena energii',
            'annual_production_mwh': 'Produkcja roczna',
            'capex': 'CAPEX',
            'service_cost': 'Koszty serwisu',
            'interest_rate': 'Oprocentowanie'
        }[x]
    )
    
    # Zakres zmienności
    variation_range = st.slider(
        "Zakres zmienności (%)",
        min_value=-50,
        max_value=50,
        value=(-30, 30),
        step=5
    )
    
    # Obliczenia wrażliwości
    base_value = st.session_state.parameters[sensitivity_param]
    variations = np.linspace(
        base_value * (1 + variation_range[0]/100),
        base_value * (1 + variation_range[1]/100),
        21
    )
    
    npv_results = []
    irr_results = []
    
    for var_value in variations:
        temp_params = st.session_state.parameters.copy()
        temp_params[sensitivity_param] = var_value
        
        temp_cf = calculate_cash_flows(temp_params)
        temp_wacc = calculate_wacc(temp_params)
        temp_npv = calculate_npv(temp_cf, temp_wacc, temp_params['capex'])
        temp_irr = calculate_irr(temp_cf, temp_params['capex'])
        
        npv_results.append(temp_npv)
        irr_results.append(temp_irr)
    
    # Wykres wrażliwości
    fig_sensitivity = go.Figure()
    
    fig_sensitivity.add_trace(go.Scatter(
        x=variations,
        y=npv_results,
        mode='lines+markers',
        name='NPV',
        yaxis='y'
    ))
    
    fig_sensitivity.add_trace(go.Scatter(
        x=variations,
        y=irr_results,
        mode='lines+markers',
        name='IRR (%)',
        yaxis='y2'
    ))
    
    fig_sensitivity.add_vline(
        x=base_value,
        line_dash="dash",
        annotation_text="Wartość bazowa"
    )
    
    fig_sensitivity.add_hline(
        y=0,
        line_dash="dash",
        line_color="red",
        yaxis='y'
    )
    
    fig_sensitivity.update_layout(
        title=f"Wrażliwość NPV i IRR na zmiany {sensitivity_param}",
        xaxis_title="Wartość parametru",
        yaxis_title="NPV (PLN)",
        yaxis2=dict(
            title="IRR (%)",
            overlaying='y',
            side='right'
        ),
        hovermode='x unified',
        height=500
    )
    
    st.plotly_chart(fig_sensitivity, use_container_width=True)

with tab4:
    st.header("📑 Generowanie Raportów")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("📄 Eksport do Excel")
        
        if st.button("Generuj plik Excel", type="primary"):
            # Przygotowanie danych
            output = BytesIO()
            
            with pd.ExcelWriter(output, engine='openpyxl') as writer:
                # Arkusz z parametrami
                df_params = pd.DataFrame([st.session_state.parameters]).T
                df_params.columns = ['Wartość']
                df_params.to_excel(writer, sheet_name='Parametry')
                
                # Arkusz z cash flow
                df_cf = pd.DataFrame({
                    'Rok': range(1, len(cash_flows) + 1),
                    'Cash Flow': cash_flows
                })
                df_cf.to_excel(writer, sheet_name='Cash Flow', index=False)
                
                # Arkusz z KPI
                df_kpi = pd.DataFrame({
                    'Wskaźnik': ['NPV', 'IRR', 'WACC', 'Okres zwrotu'],
                    'Wartość': [
                        f"{npv:,.0f} PLN",
                        f"{irr:.1f}%",
                        f"{wacc:.1f}%",
                        f"{payback_period} lat" if payback_period else "> 30 lat"
                    ]
                })
                df_kpi.to_excel(writer, sheet_name='KPI', index=False)
            
            excel_data = output.getvalue()
            b64 = base64.b64encode(excel_data).decode()
            
            href = f'<a href="data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,{b64}" download="model_pv_{datetime.now():%Y%m%d_%H%M}.xlsx">📥 Pobierz plik Excel</a>'
            st.markdown(href, unsafe_allow_html=True)
            st.success("Plik Excel wygenerowany!")
    
    with col2:
        st.subheader("📊 Podsumowanie Projektu")
        
        st.info(f"""
        **Projekt:** Farma PV {st.session_state.parameters['power_mw']} MW
        
        **Lokalizacja:** Polska
        
        **Okres analizy:** {st.session_state.parameters['lease_period_years']} lat
        
        **Data rozpoczęcia:** {st.session_state.parameters['project_start_date'].strftime('%Y-%m-%d')}
        
        **Główne wskaźniki:**
        - NPV: {npv:,.0f} PLN
        - IRR: {irr:.1f}%
        - WACC: {wacc:.1f}%
        - Okres zwrotu: {payback_period if payback_period else '>30'} lat
        
        **Status:** {'✅ Rentowny' if npv > 0 else '❌ Nierentowny'}
        """)

with tab5:
    st.header("💾 Zarządzanie Scenariuszami")
    
    col1, col2 = st.columns([1, 2])
    
    with col1:
        st.subheader("Zapisz scenariusz")
        
        scenario_name = st.text_input("Nazwa scenariusza")
        scenario_desc = st.text_area("Opis scenariusza")
        
        if st.button("💾 Zapisz", type="primary"):
            if scenario_name:
                if 'scenarios' not in st.session_state:
                    st.session_state.scenarios = {}
                
                st.session_state.scenarios[scenario_name] = {
                    'parameters': st.session_state.parameters.copy(),
                    'description': scenario_desc,
                    'npv': npv,
                    'irr': irr,
                    'timestamp': datetime.now()
                }
                st.success(f"Scenariusz '{scenario_name}' zapisany!")
                st.experimental_rerun()
    
    with col2:
        st.subheader("Porównanie scenariuszy")
        
        if 'scenarios' in st.session_state and len(st.session_state.scenarios) > 0:
            scenarios_df = pd.DataFrame([
                {
                    'Nazwa': name,
                    'NPV (PLN)': data['npv'],
                    'IRR (%)': data['irr'],
                    'Data': data['timestamp'].strftime('%Y-%m-%d %H:%M')
                }
                for name, data in st.session_state.scenarios.items()
            ])
            
            st.dataframe(
                scenarios_df.style.format({
                    'NPV (PLN)': '{:,.0f}',
                    'IRR (%)': '{:.1f}'
                }).applymap(
                    lambda x: 'background-color: lightgreen' if x == scenarios_df['NPV (PLN)'].max() else '',
                    subset=['NPV (PLN)']
                ),
                use_container_width=True
            )
            
            # Wykres porównawczy
            fig_comparison = go.Figure()
            
            fig_comparison.add_trace(go.Bar(
                x=scenarios_df['Nazwa'],
                y=scenarios_df['NPV (PLN)'],
                name='NPV',
                marker_color='lightblue'
            ))
            
            fig_comparison.update_layout(
                title="Porównanie NPV scenariuszy",
                xaxis_title="Scenariusz",
                yaxis_title="NPV (PLN)",
                height=400
            )
            
            st.plotly_chart(fig_comparison, use_container_width=True)
        else:
            st.info("Brak zapisanych scenariuszy")

# Footer
st.markdown("---")
st.markdown("""
<div style='text-align: center; color: gray;'>
    Model Finansowy PV v1.0 | Utworzony przy pomocy Streamlit | 
    Data: {:%Y-%m-%d %H:%M}
</div>
""".format(datetime.now()), unsafe_allow_html=True)