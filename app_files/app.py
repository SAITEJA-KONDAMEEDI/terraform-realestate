from flask import Flask, jsonify, Response
import folium
from database import DataTier

app = Flask(__name__)
db = DataTier()


@app.route('/')
def home():
    states = db.get_states()
    options = ''.join(f'<option value="{s}">{s}</option>' for s in states)
    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Real Estate Land Rates</title>
<style>
    :root {{
        --primary: #2563eb;
        --primary-dark: #1d4ed8;
        --success: #16a34a;
        --error: #dc2626;
        --bg: #f1f5f9;
        --card: #ffffff;
        --border: #e2e8f0;
        --text: #1e293b;
        --text-muted: #64748b;
    }}
    * {{ box-sizing: border-box; }}
    body {{
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif;
        margin: 0;
        padding: 24px 16px;
        background: var(--bg);
        color: var(--text);
        min-height: 100vh;
    }}
    .container {{
        max-width: 720px;
        margin: 0 auto;
    }}
    h1 {{
        font-size: 1.6rem;
        text-align: center;
        margin: 0 0 8px;
    }}
    .subtitle {{
        text-align: center;
        color: var(--text-muted);
        font-size: 0.95rem;
        margin-bottom: 28px;
    }}
    .card {{
        background: var(--card);
        border-radius: 14px;
        padding: 24px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
        border: 1px solid var(--border);
    }}
    .form-group {{
        margin-bottom: 18px;
    }}
    .form-group:last-child {{
        margin-bottom: 0;
    }}
    label {{
        display: block;
        font-weight: 600;
        font-size: 0.85rem;
        margin-bottom: 6px;
        color: var(--text-muted);
        text-transform: uppercase;
        letter-spacing: 0.03em;
    }}
    select {{
        width: 100%;
        padding: 12px 14px;
        border: 1.5px solid var(--border);
        border-radius: 8px;
        font-size: 16px;
        background: var(--card);
        color: var(--text);
        appearance: none;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8'%3E%3Cpath d='M1 1l5 5 5-5' stroke='%2364748b' stroke-width='1.5' fill='none' fill-rule='evenodd'/%3E%3C/svg%3E");
        background-repeat: no-repeat;
        background-position: right 14px center;
        transition: border-color 0.15s;
    }}
    select:focus {{
        outline: none;
        border-color: var(--primary);
    }}
    select:disabled {{
        background-color: #f8fafc;
        color: var(--text-muted);
        cursor: not-allowed;
    }}
    .spinner {{
        display: none;
        width: 16px;
        height: 16px;
        border: 2px solid var(--border);
        border-top-color: var(--primary);
        border-radius: 50%;
        margin-left: 8px;
        animation: spin 0.6s linear infinite;
        vertical-align: middle;
    }}
    .spinner.active {{
        display: inline-block;
    }}
    .label-row {{
        display: flex;
        align-items: center;
    }}
    @keyframes spin {{
        to {{ transform: rotate(360deg); }}
    }}
    #result {{
        margin-top: 20px;
        display: none;
    }}
    #result.visible {{
        display: block;
        animation: fadeIn 0.25s ease;
    }}
    @keyframes fadeIn {{
        from {{ opacity: 0; transform: translateY(4px); }}
        to {{ opacity: 1; transform: translateY(0); }}
    }}
    .rate-card {{
        background: linear-gradient(135deg, var(--success), #15803d);
        color: white;
        border-radius: 12px;
        padding: 20px;
        text-align: center;
        margin-bottom: 16px;
    }}
    .rate-label {{
        font-size: 0.8rem;
        opacity: 0.85;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        margin-bottom: 4px;
    }}
    .rate-value {{
        font-size: 1.8rem;
        font-weight: 700;
    }}
    #map-container {{
        border-radius: 12px;
        overflow: hidden;
        border: 1px solid var(--border);
    }}
    #map-container iframe {{
        display: block;
        width: 100%;
        border: none;
    }}
    .error-banner {{
        display: none;
        background: #fef2f2;
        border: 1px solid #fecaca;
        color: var(--error);
        border-radius: 10px;
        padding: 14px 16px;
        margin-top: 20px;
        font-size: 0.92rem;
    }}
    .error-banner.visible {{
        display: block;
        animation: fadeIn 0.25s ease;
    }}
    @media (max-width: 480px) {{
        body {{ padding: 16px 12px; }}
        .card {{ padding: 18px; border-radius: 12px; }}
        h1 {{ font-size: 1.35rem; }}
        .rate-value {{ font-size: 1.5rem; }}
    }}
</style>
</head>
<body>
<div class="container">
    <h1>🏡 Real Estate Land Rates</h1>
    <p class="subtitle">Select a location to look up land prices</p>

    <div class="card">
        <div class="form-group">
            <div class="label-row">
                <label>State</label>
            </div>
            <select id="state" onchange="loadDistricts()">
                <option value="">-- Select State --</option>
                {options}
            </select>
        </div>

        <div class="form-group">
            <div class="label-row">
                <label>District</label>
                <span class="spinner" id="spinner-district"></span>
            </div>
            <select id="district" onchange="loadMandals()" disabled>
                <option value="">-- Select District --</option>
            </select>
        </div>

        <div class="form-group">
            <div class="label-row">
                <label>Mandal</label>
                <span class="spinner" id="spinner-mandal"></span>
            </div>
            <select id="mandal" onchange="loadInfo()" disabled>
                <option value="">-- Select Mandal --</option>
            </select>
        </div>
    </div>

    <div id="result">
        <div class="rate-card">
            <div class="rate-label">Land Rate</div>
            <div class="rate-value" id="rate"></div>
        </div>
        <div id="map-container"></div>
    </div>

    <div class="error-banner" id="error-banner"></div>
</div>

<script>
    function showSpinner(id, on) {{
        document.getElementById(id).classList.toggle('active', on);
    }}

    function showError(message) {{
        const banner = document.getElementById('error-banner');
        banner.textContent = message;
        banner.classList.add('visible');
        document.getElementById('result').classList.remove('visible');
    }}

    function clearError() {{
        document.getElementById('error-banner').classList.remove('visible');
    }}

    function resetSelect(id, placeholder) {{
        const el = document.getElementById(id);
        el.innerHTML = `<option value="">${{placeholder}}</option>`;
        el.disabled = true;
    }}

    async function loadDistricts() {{
        const state = document.getElementById('state').value;
        resetSelect('district', '-- Select District --');
        resetSelect('mandal', '-- Select Mandal --');
        document.getElementById('result').classList.remove('visible');
        clearError();
        if (!state) return;

        showSpinner('spinner-district', true);
        try {{
            const res = await fetch(`/api/districts/${{encodeURIComponent(state)}}`);
            if (!res.ok) throw new Error('Could not load districts');
            const data = await res.json();
            const sel = document.getElementById('district');
            data.forEach(x => sel.innerHTML += `<option value="${{x}}">${{x}}</option>`);
            sel.disabled = false;
        }} catch (err) {{
            showError('Something went wrong loading districts. Please try again.');
        }} finally {{
            showSpinner('spinner-district', false);
        }}
    }}

    async function loadMandals() {{
        const state = document.getElementById('state').value;
        const district = document.getElementById('district').value;
        resetSelect('mandal', '-- Select Mandal --');
        document.getElementById('result').classList.remove('visible');
        clearError();
        if (!district) return;

        showSpinner('spinner-mandal', true);
        try {{
            const res = await fetch(`/api/mandals/${{encodeURIComponent(state)}}/${{encodeURIComponent(district)}}`);
            if (!res.ok) throw new Error('Could not load mandals');
            const data = await res.json();
            const sel = document.getElementById('mandal');
            data.forEach(x => sel.innerHTML += `<option value="${{x}}">${{x}}</option>`);
            sel.disabled = false;
        }} catch (err) {{
            showError('Something went wrong loading mandals. Please try again.');
        }} finally {{
            showSpinner('spinner-mandal', false);
        }}
    }}

    async function loadInfo() {{
        const state = document.getElementById('state').value;
        const district = document.getElementById('district').value;
        const mandal = document.getElementById('mandal').value;
        clearError();
        if (!mandal) return;

        try {{
            const res = await fetch(`/api/info/${{encodeURIComponent(state)}}/${{encodeURIComponent(district)}}/${{encodeURIComponent(mandal)}}`);
            const data = await res.json();
            if (!res.ok || data.error) {{
                showError(data.error || 'No data found for this location.');
                return;
            }}
            document.getElementById('rate').textContent = `${{data.rate}} / sq.yd`;
            document.getElementById('map-container').innerHTML = data.map_html;
            document.getElementById('result').classList.add('visible');
        }} catch (err) {{
            showError('Something went wrong loading the map. Please try again.');
        }}
    }}
</script>
</body>
</html>"""
    return Response(html, mimetype='text/html')


@app.route('/api/districts/<state>')
def get_districts(state):
    return jsonify(db.get_districts(state))


@app.route('/api/mandals/<state>/<district>')
def get_mandals(state, district):
    return jsonify(db.get_mandals(state, district))


@app.route('/api/info/<state>/<district>/<mandal>')
def get_info(state, district, mandal):
    result = db.get_mandal_info(state, district, mandal)
    if result is None:
        return jsonify({'error': 'No data found for this location'}), 404

    rate, lat, lon = result
    m = folium.Map(location=[lat, lon], zoom_start=14)
    folium.Marker(
        [lat, lon],
        popup=f"<b>{mandal}</b><br>Rate: ₹{rate:,}/sq.yd",
        icon=folium.Icon(color="green", icon="info-sign")
    ).add_to(m)
    return jsonify({
        'rate': f"₹ {rate:,}",
        'map_html': m._repr_html_()
    })


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
