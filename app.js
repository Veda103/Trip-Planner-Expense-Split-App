// ══════════════════════════════════════════════════════════════════════
//  app.js — Trip Planner & Expense Splitter (Logic Layer)
// ══════════════════════════════════════════════════════════════════════

// ── State ────────────────────────────────────────────────────────────
let state = JSON.parse(
  localStorage.getItem('tp_state') || '{"trips":[],"currentTripId":null}'
);
let tempParticipants = [];

function save() {
  localStorage.setItem('tp_state', JSON.stringify(state));
}

function currentTrip() {
  return state.trips.find((t) => t.id === state.currentTripId) || null;
}

// ── Helpers ──────────────────────────────────────────────────────────
function fmt(d) {
  if (!d) return '';
  const [y, m, day] = d.split('-');
  return `${day}/${m}/${y}`;
}

// ══════════════════════════════════════════════════════════════════════
//  Navigation
// ══════════════════════════════════════════════════════════════════════
function showSection(name) {
  document.querySelectorAll('.section').forEach((s) => s.classList.remove('active'));
  document.getElementById('sec-' + name).classList.add('active');
  document.querySelectorAll('nav button').forEach((b) => {
    b.classList.toggle('active', b.getAttribute('onclick').includes("'" + name + "'"));
  });
  if (name === 'itinerary') renderItinerary();
  if (name === 'expenses') renderExpenses();
  if (name === 'balances') renderBalances();
  if (name === 'dashboard') renderDashboard();
}

// ══════════════════════════════════════════════════════════════════════
//  Trip Management
// ══════════════════════════════════════════════════════════════════════
function addTempParticipant() {
  const v = document.getElementById('t-part').value.trim();
  if (!v) return;
  if (tempParticipants.includes(v)) {
    alert('Already added');
    return;
  }
  tempParticipants.push(v);
  document.getElementById('t-part').value = '';
  renderTempParts();
}

function removeTempParticipant(p) {
  tempParticipants = tempParticipants.filter((x) => x !== p);
  renderTempParts();
}

function renderTempParts() {
  document.getElementById('temp-parts').innerHTML = tempParticipants
    .map(
      (p) =>
        `<span class="tag">${p}<button onclick="removeTempParticipant('${p}')">×</button></span>`
    )
    .join('');
}

function createTrip() {
  const name = document.getElementById('t-name').value.trim();
  const dest = document.getElementById('t-dest').value.trim();
  const start = document.getElementById('t-start').value;
  const end = document.getElementById('t-end').value;
  if (!name || !dest || !start || !end) {
    alert('Fill all trip details');
    return;
  }
  if (tempParticipants.length < 1) {
    alert('Add at least one participant');
    return;
  }
  const trip = {
    id: Date.now().toString(),
    name,
    dest,
    start,
    end,
    participants: [...tempParticipants],
    itinerary: [],
    expenses: [],
  };
  state.trips.unshift(trip);
  state.currentTripId = trip.id;
  tempParticipants = [];
  renderTempParts();
  ['t-name', 't-dest', 't-start', 't-end'].forEach(
    (id) => (document.getElementById(id).value = '')
  );
  save();
  renderTrips();
}

function renderTrips() {
  const q = document.getElementById('trip-search').value.toLowerCase();
  const filtered = state.trips.filter((t) => t.name.toLowerCase().includes(q));
  const el = document.getElementById('trips-list');
  if (!filtered.length) {
    el.innerHTML =
      '<div class="empty">No trips yet. Create your first trip above!</div>';
    return;
  }
  el.innerHTML = filtered
    .map(
      (t) => `
    <div class="trip-card ${t.id === state.currentTripId ? 'selected' : ''}" onclick="selectTrip('${t.id}')">
      <div style="display:flex;justify-content:space-between;align-items:start">
        <div>
          <h3>${t.name} ${t.id === state.currentTripId ? '<span class="badge badge-green">Active</span>' : ''}</h3>
          <p>📍 ${t.dest} &nbsp;|&nbsp; 📅 ${fmt(t.start)} – ${fmt(t.end)}</p>
          <p>👥 ${t.participants.join(', ')}</p>
        </div>
        <button class="btn btn-danger btn-sm" onclick="deleteTrip(event,'${t.id}')">Delete</button>
      </div>
    </div>
  `
    )
    .join('');
}

function selectTrip(id) {
  state.currentTripId = id;
  save();
  renderTrips();
  alert('Trip selected: ' + state.trips.find((t) => t.id === id).name);
}

function deleteTrip(e, id) {
  e.stopPropagation();
  if (!confirm('Delete this trip?')) return;
  state.trips = state.trips.filter((t) => t.id !== id);
  if (state.currentTripId === id)
    state.currentTripId = state.trips[0]?.id || null;
  save();
  renderTrips();
}

// ══════════════════════════════════════════════════════════════════════
//  Itinerary
// ══════════════════════════════════════════════════════════════════════
function addItinerary() {
  const trip = currentTrip();
  if (!trip) return;
  const date = document.getElementById('i-date').value;
  const time = document.getElementById('i-time').value;
  const desc = document.getElementById('i-desc').value.trim();
  if (!date || !desc) {
    alert('Fill date and description');
    return;
  }
  trip.itinerary.push({ id: Date.now().toString(), date, time, desc });
  trip.itinerary.sort(
    (a, b) =>
      a.date.localeCompare(b.date) || (a.time || '').localeCompare(b.time || '')
  );
  save();
  renderItinerary();
  document.getElementById('i-date').value = '';
  document.getElementById('i-time').value = '';
  document.getElementById('i-desc').value = '';
}

function renderItinerary() {
  const hasTrip = !!currentTrip();
  document.getElementById('no-trip-it').style.display = hasTrip ? 'none' : 'block';
  document.getElementById('itin-content').style.display = hasTrip ? 'block' : 'none';
  if (!hasTrip) return;
  const trip = currentTrip();
  const el = document.getElementById('itin-list');
  if (!trip.itinerary.length) {
    el.innerHTML = '<div class="empty">No activities added yet.</div>';
    return;
  }
  const groups = {};
  trip.itinerary.forEach((item) => {
    (groups[item.date] = groups[item.date] || []).push(item);
  });
  el.innerHTML = Object.keys(groups)
    .sort()
    .map(
      (date) => `
    <div class="day-group">
      <h4>📅 ${fmt(date)}</h4>
      ${groups[date]
        .map(
          (item) => `
        <div class="itinerary-item">
          <span class="time-badge">${item.time || '–'}</span>
          <span style="flex:1">${item.desc}</span>
          <button class="btn btn-danger btn-sm" onclick="deleteItinerary('${item.id}')">✕</button>
        </div>
      `
        )
        .join('')}
    </div>
  `
    )
    .join('');
}

function deleteItinerary(id) {
  const trip = currentTrip();
  if (!trip) return;
  trip.itinerary = trip.itinerary.filter((i) => i.id !== id);
  save();
  renderItinerary();
}

// ══════════════════════════════════════════════════════════════════════
//  Expenses
// ══════════════════════════════════════════════════════════════════════
function renderExpenses() {
  const hasTrip = !!currentTrip();
  document.getElementById('no-trip-ex').style.display = hasTrip ? 'none' : 'block';
  document.getElementById('exp-content').style.display = hasTrip ? 'block' : 'none';
  if (!hasTrip) return;
  const trip = currentTrip();

  // populate paid-by select
  const sel = document.getElementById('e-paid');
  sel.innerHTML = trip.participants
    .map((p) => `<option value="${p}">${p}</option>`)
    .join('');

  // populate filter
  const fSel = document.getElementById('exp-filter-part');
  const fVal = fSel.value;
  fSel.innerHTML =
    '<option value="">All</option>' +
    trip.participants.map((p) => `<option value="${p}">${p}</option>`).join('');
  fSel.value = fVal;

  const filterPart = document.getElementById('exp-filter-part').value;
  const filterDate = document.getElementById('exp-filter-date').value;
  let list = [...trip.expenses];
  if (filterPart) list = list.filter((e) => e.paidBy === filterPart);
  if (filterDate) list = list.filter((e) => e.date === filterDate);

  const el = document.getElementById('exp-list');
  if (!list.length) {
    el.innerHTML = '<div class="empty">No expenses found.</div>';
    return;
  }
  el.innerHTML = `<table>
    <tr><th>Date</th><th>Description</th><th>Paid By</th><th>Amount</th><th></th></tr>
    ${list
      .map(
        (e) => `
      <tr>
        <td>${e.date ? fmt(e.date) : '–'}</td>
        <td>${e.desc}</td>
        <td><span class="badge">${e.paidBy}</span></td>
        <td>₹${Number(e.amount).toFixed(2)}</td>
        <td><button class="btn btn-danger btn-sm" onclick="deleteExpense('${e.id}')">✕</button></td>
      </tr>
    `
      )
      .join('')}
  </table>`;
}

function addExpense() {
  const trip = currentTrip();
  if (!trip) return;
  const amount = parseFloat(document.getElementById('e-amt').value);
  const paidBy = document.getElementById('e-paid').value;
  const desc = document.getElementById('e-desc').value.trim();
  const date = document.getElementById('e-date').value;
  if (!amount || amount <= 0 || !desc) {
    alert('Fill amount and description');
    return;
  }
  trip.expenses.push({ id: Date.now().toString(), amount, paidBy, desc, date });
  save();
  renderExpenses();
  document.getElementById('e-amt').value = '';
  document.getElementById('e-desc').value = '';
  document.getElementById('e-date').value = '';
}

function deleteExpense(id) {
  const trip = currentTrip();
  if (!trip) return;
  trip.expenses = trip.expenses.filter((e) => e.id !== id);
  save();
  renderExpenses();
}

function clearExpFilter() {
  document.getElementById('exp-filter-part').value = '';
  document.getElementById('exp-filter-date').value = '';
  renderExpenses();
}

// ══════════════════════════════════════════════════════════════════════
//  Balances & Splitting Logic
// ══════════════════════════════════════════════════════════════════════
function renderBalances() {
  const hasTrip = !!currentTrip();
  document.getElementById('no-trip-bal').style.display = hasTrip ? 'none' : 'block';
  document.getElementById('bal-content').style.display = hasTrip ? 'block' : 'none';
  if (!hasTrip) return;
  const trip = currentTrip();
  const n = trip.participants.length;
  const total = trip.expenses.reduce((s, e) => s + Number(e.amount), 0);
  const share = n ? total / n : 0;

  // net[person] = paid - share
  const paid = {};
  const net = {};
  trip.participants.forEach((p) => {
    paid[p] = 0;
    net[p] = 0;
  });
  trip.expenses.forEach((e) => {
    paid[e.paidBy] = (paid[e.paidBy] || 0) + Number(e.amount);
  });
  trip.participants.forEach((p) => {
    net[p] = (paid[p] || 0) - share;
  });

  document.getElementById('per-person').innerHTML = `<table>
    <tr><th>Participant</th><th>Paid</th><th>Fair Share</th><th>Net</th></tr>
    ${trip.participants
      .map(
        (p) => `
      <tr>
        <td>${p}</td>
        <td>₹${(paid[p] || 0).toFixed(2)}</td>
        <td>₹${share.toFixed(2)}</td>
        <td class="${net[p] >= 0 ? 'get' : 'owe'}">${net[p] >= 0 ? '+' : ''}₹${net[p].toFixed(2)}</td>
      </tr>
    `
      )
      .join('')}
    <tr style="font-weight:700;background:#f7fafc">
      <td>Total</td><td>₹${total.toFixed(2)}</td><td colspan="2"></td>
    </tr>
  </table>`;

  // Simplified settlement
  const debtors = trip.participants
    .filter((p) => net[p] < -0.01)
    .map((p) => ({ name: p, amt: -net[p] }));
  const creditors = trip.participants
    .filter((p) => net[p] > 0.01)
    .map((p) => ({ name: p, amt: net[p] }));
  const txns = [];
  let i = 0,
    j = 0;
  const d = [...debtors.map((x) => ({ ...x }))];
  const c = [...creditors.map((x) => ({ ...x }))];
  while (i < d.length && j < c.length) {
    const amt = Math.min(d[i].amt, c[j].amt);
    txns.push({ from: d[i].name, to: c[j].name, amt });
    d[i].amt -= amt;
    c[j].amt -= amt;
    if (d[i].amt < 0.01) i++;
    if (c[j].amt < 0.01) j++;
  }
  const sEl = document.getElementById('settlements');
  if (!txns.length) {
    sEl.innerHTML =
      '<div class="empty">' +
      (total > 0 ? 'All settled!' : 'No expenses yet.') +
      '</div>';
  } else {
    sEl.innerHTML = txns
      .map(
        (t) => `
      <div class="balance-row">
        <span><strong>${t.from}</strong> owes <strong>${t.to}</strong></span>
        <span class="owe">₹${t.amt.toFixed(2)}</span>
      </div>
    `
      )
      .join('');
  }
}

// ══════════════════════════════════════════════════════════════════════
//  Dashboard
// ══════════════════════════════════════════════════════════════════════
function renderDashboard() {
  const hasTrip = !!currentTrip();
  document.getElementById('no-trip-dash').style.display = hasTrip ? 'none' : 'block';
  document.getElementById('dash-content').style.display = hasTrip ? 'block' : 'none';
  if (!hasTrip) return;
  const trip = currentTrip();
  const total = trip.expenses.reduce((s, e) => s + Number(e.amount), 0);
  const n = trip.participants.length;
  const share = n ? total / n : 0;
  const paid = {};
  trip.participants.forEach((p) => (paid[p] = 0));
  trip.expenses.forEach(
    (e) => (paid[e.paidBy] = (paid[e.paidBy] || 0) + Number(e.amount))
  );
  const pending = trip.participants.filter(
    (p) => (paid[p] || 0) < share - 0.01
  ).length;

  document.getElementById('dash-stats').innerHTML = `
    <div class="stat-box"><div class="num">₹${total.toFixed(0)}</div><div class="lbl">Total Expenses</div></div>
    <div class="stat-box"><div class="num">${n}</div><div class="lbl">Participants</div></div>
    <div class="stat-box"><div class="num">${trip.itinerary.length}</div><div class="lbl">Activities</div></div>
    <div class="stat-box"><div class="num">${pending}</div><div class="lbl">Pending Balances</div></div>
  `;
  document.getElementById('dash-parts').innerHTML = `
    <div style="display:flex;flex-wrap:wrap;gap:8px">
      ${trip.participants
        .map(
          (p) =>
            `<span class="badge badge-green">${p} — ₹${(paid[p] || 0).toFixed(0)} paid</span>`
        )
        .join('')}
    </div>
  `;
  const recent = trip.expenses.slice(-5).reverse();
  document.getElementById('dash-recent').innerHTML = recent.length
    ? `<table><tr><th>Description</th><th>Paid By</th><th>Amount</th></tr>
       ${recent
         .map(
           (e) =>
             `<tr><td>${e.desc}</td><td>${e.paidBy}</td><td>₹${Number(e.amount).toFixed(2)}</td></tr>`
         )
         .join('')}
       </table>`
    : '<div class="empty">No expenses yet.</div>';
}

// ══════════════════════════════════════════════════════════════════════
//  Initialise on page load
// ══════════════════════════════════════════════════════════════════════
document.addEventListener('DOMContentLoaded', () => {
  renderTrips();
});
