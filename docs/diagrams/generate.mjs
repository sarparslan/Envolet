// Generates the hand-drawn (Excalidraw-style) diagrams in this folder.
//
//   node docs/diagrams/generate.mjs
//
// No dependencies: shapes get a small seeded jitter so they look sketched,
// and the Virgil font (OFL, from Excalidraw) is embedded in every SVG.

import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const fontData = readFileSync(join(here, 'fonts/Virgil.woff2')).toString('base64');

const C = {
  bg: '#121212',
  fg: '#e9e9e9',
  muted: '#a3a3a3',
  blue: '#5b9cf6',
  orange: '#f59f3a',
  red: '#ff6b6b',
  group: '#8a8a8a',
};

// ---------------------------------------------------------------- drawing kit

function mulberry32(seed) {
  return () => {
    seed |= 0;
    seed = (seed + 0x6d2b79f5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

const esc = (s) =>
  String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
const f = (n) => Math.round(n * 10) / 10;

class Sketch {
  constructor(width, height, seed = 7) {
    this.w = width;
    this.h = height;
    this.rand = mulberry32(seed);
    this.out = [];
  }

  j(amount) {
    return (this.rand() * 2 - 1) * amount;
  }

  // A slightly bowed stroke between two points.
  seg(x1, y1, x2, y2, jitter = 1) {
    const len = Math.hypot(x2 - x1, y2 - y1) || 1;
    const bow = this.j(Math.min(2.2, len * 0.006 + 0.4));
    const mx = (x1 + x2) / 2 + (-(y2 - y1) / len) * bow;
    const my = (y1 + y2) / 2 + ((x2 - x1) / len) * bow;
    return `M${f(x1 + this.j(jitter))} ${f(y1 + this.j(jitter))} Q${f(mx)} ${f(my)} ${f(
      x2 + this.j(jitter),
    )} ${f(y2 + this.j(jitter))}`;
  }

  path(d, { color = C.fg, width = 2, dashed = false, fill = 'none' } = {}) {
    const dash = dashed ? ` stroke-dasharray="10 9"` : '';
    this.out.push(
      `<path d="${d}" fill="${fill}" stroke="${color}" stroke-width="${width}" stroke-linecap="round" stroke-linejoin="round"${dash}/>`,
    );
  }

  roundedRectPath(x, y, w, h, r, jitter) {
    const J = () => this.j(jitter);
    const pts = [
      [x + r, y],
      [x + w - r, y],
      [x + w, y + r],
      [x + w, y + h - r],
      [x + w - r, y + h],
      [x + r, y + h],
      [x, y + h - r],
      [x, y + r],
    ].map(([px, py]) => [px + J(), py + J()]);
    const corners = [
      [x + w, y],
      [x + w, y + h],
      [x, y + h],
      [x, y],
    ];
    let d = `M${f(pts[0][0])} ${f(pts[0][1])}`;
    for (let i = 0; i < 4; i++) {
      const [ax, ay] = pts[i * 2];
      const [bx, by] = pts[i * 2 + 1];
      const len = Math.hypot(bx - ax, by - ay) || 1;
      const bow = this.j(Math.min(2.5, len * 0.005 + 0.4));
      const mx = (ax + bx) / 2 + (-(by - ay) / len) * bow;
      const my = (ay + by) / 2 + ((bx - ax) / len) * bow;
      d += ` Q${f(mx)} ${f(my)} ${f(bx)} ${f(by)}`;
      const [nx, ny] = pts[(i * 2 + 2) % 8];
      const [cx, cy] = corners[i];
      d += ` Q${f(cx + J())} ${f(cy + J())} ${f(nx)} ${f(ny)}`;
    }
    return d;
  }

  rect(x, y, w, h, { color = C.fg, dashed = false, width = 2, r = 16, fill = null } = {}) {
    if (fill) this.path(this.roundedRectPath(x, y, w, h, r, 0), { color: 'none', fill, width: 0 });
    const passes = dashed ? 1 : 2;
    for (let i = 0; i < passes; i++) {
      this.path(this.roundedRectPath(x, y, w, h, r, dashed ? 0.6 : 1.2), {
        color,
        dashed,
        width: i === 0 ? width : width * 0.6,
      });
    }
  }

  diamond(cx, cy, w, h, { color = C.fg } = {}) {
    const p = [
      [cx, cy - h / 2],
      [cx + w / 2, cy],
      [cx, cy + h / 2],
      [cx - w / 2, cy],
    ];
    for (let pass = 0; pass < 2; pass++) {
      const d = p.map((a, i) => this.seg(...a, ...p[(i + 1) % 4], 1.4)).join(' ');
      this.path(d, { color, width: pass === 0 ? 2 : 1.2 });
    }
  }

  line(points, { color = C.fg, dashed = false, width = 2, head = true } = {}) {
    let d = '';
    for (let i = 0; i < points.length - 1; i++) d += this.seg(...points[i], ...points[i + 1], 0.8) + ' ';
    this.path(d, { color, dashed, width });
    if (!head) return;
    const [tx, ty] = points[points.length - 1];
    const [px, py] = points[points.length - 2];
    const a = Math.atan2(ty - py, tx - px);
    const L = 16;
    const wing = (s) => [tx - L * Math.cos(a + s), ty - L * Math.sin(a + s)];
    const [lx, ly] = wing(0.45);
    const [rx, ry] = wing(-0.45);
    this.path(`${this.seg(lx, ly, tx, ty, 0.5)} ${this.seg(tx, ty, rx, ry, 0.5)}`, {
      color,
      width,
    });
  }

  text(x, y, str, { size = 24, color = C.fg, anchor = 'middle', lh = 1.3 } = {}) {
    const lines = Array.isArray(str) ? str : [str];
    const top = y - ((lines.length - 1) * size * lh) / 2;
    lines.forEach((ln, i) => {
      this.out.push(
        `<text x="${f(x)}" y="${f(top + i * size * lh)}" font-size="${size}" fill="${color}" text-anchor="${anchor}" dominant-baseline="central">${esc(ln)}</text>`,
      );
    });
  }

  // Box with a title and an optional muted subtitle, centred on (cx, cy).
  node(cx, cy, w, h, title, sub, opts = {}) {
    const { titleColor = C.fg, subColor = C.muted, titleSize = 28, subSize = 20 } = opts;
    this.rect(cx - w / 2, cy - h / 2, w, h, opts);
    const subLines = sub ? (Array.isArray(sub) ? sub : [sub]) : [];
    if (!subLines.length) return this.text(cx, cy, title, { size: titleSize, color: titleColor });
    const gap = 10;
    const total = titleSize + gap + subLines.length * subSize * 1.3;
    const ty = cy - total / 2 + titleSize / 2;
    this.text(cx, ty, title, { size: titleSize, color: titleColor });
    this.text(cx, ty + titleSize / 2 + gap + (subLines.length * subSize * 1.3) / 2, subLines, {
      size: subSize,
      color: subColor,
    });
  }

  title(str) {
    this.text(110, 100, str, { size: 36, anchor: 'start' });
  }

  legend(y, items, x = 150) {
    for (const { label, color, dashed } of items) {
      this.line(
        [
          [x, y],
          [x + 105, y],
        ],
        { color, dashed, head: false, width: 3 },
      );
      this.text(x + 125, y, label, { size: 24, color: C.muted, anchor: 'start' });
      x += 145 + label.length * 13 + 90;
    }
  }

  svg() {
    return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${this.w} ${this.h}" width="${this.w}" height="${this.h}">
<style>
@font-face { font-family: 'Virgil'; src: url(data:font/woff2;base64,${fontData}) format('woff2'); }
text { font-family: 'Virgil', 'Segoe Print', 'Chalkboard SE', cursive; }
</style>
<rect width="100%" height="100%" fill="${C.bg}"/>
${this.out.join('\n')}
</svg>
`;
  }
}

const REQUEST = { label: 'request', color: C.orange, dashed: true };
const RESPONSE = { label: 'response', color: C.blue };

// ---------------------------------------------------------------- diagrams

function architecture() {
  const s = new Sketch(2300, 1100, 11);
  s.title('Envolet · System Overview');

  // Flutter app
  s.rect(140, 170, 480, 780);
  s.text(380, 225, 'Flutter App', { size: 38 });
  s.text(380, 272, 'Provider · fl_chart', { size: 24, color: C.muted });
  s.node(380, 410, 400, 140, 'Screens', ['Home · Tracker', 'Transactions · Settings'], { color: C.blue, dashed: true });
  s.node(380, 600, 400, 140, 'Providers', ['SessionProvider', 'SettingsProvider · currency'], { color: C.blue, dashed: true });
  s.node(380, 790, 400, 140, 'ApiService', ['JSON · Bearer JWT', 'token in keychain / keystore'], { color: C.blue, dashed: true });

  // FastAPI
  s.rect(1000, 170, 460, 780);
  s.text(1230, 225, 'FastAPI', { size: 38 });
  s.text(1230, 272, 'uvicorn :5001', { size: 24, color: C.orange });
  s.node(1230, 410, 380, 140, 'Routers', ['/auth · /transactions', '/assets · /ai'], { color: C.blue, dashed: true });
  s.node(1230, 600, 380, 140, 'get_current_user', ['Bearer → JWT → User', 'else 401'], { color: C.blue, dashed: true });
  s.node(1230, 790, 380, 140, 'Services', ['analytics (pure)', 'ai · OpenRouterClient'], { color: C.blue, dashed: true });

  // External systems
  s.rect(1690, 150, 530, 820, { color: C.group, dashed: true, r: 10 });
  s.node(1955, 390, 420, 200, 'SQLite', ['SQLAlchemy', 'users · transactions · assets'], { r: 20 });
  s.node(1955, 740, 420, 200, 'OpenRouter', ['gemini-2.0-flash', 'max 100 tokens · T 0.7'], { r: 20 });

  // App <-> API
  s.text(810, 330, ['/auth/login · /auth/me', 'CRUD /transactions · /assets'], { size: 20, color: C.orange });
  s.line([[635, 385], [985, 385]], { color: C.orange, dashed: true });
  s.line([[985, 450], [635, 450]], { color: C.blue });
  s.text(810, 500, ['{ token, user } · { data }', '401 · 404 · 409'], { size: 20, color: C.blue });

  s.text(810, 690, ['GET *-buckets · category %', 'POST /ai/suggestion'], { size: 20, color: C.orange });
  s.line([[635, 745], [985, 745]], { color: C.orange, dashed: true });
  s.line([[985, 810], [635, 810]], { color: C.blue });
  s.text(810, 860, ['{ buckets: [5] } · shares', 'suggestion · 502 · 503'], { size: 20, color: C.blue });

  // API <-> externals
  s.text(1580, 340, 'SELECT · INSERT', { size: 20, color: C.orange });
  s.line([[1475, 370], [1740, 370]], { color: C.orange, dashed: true });
  s.line([[1740, 430], [1475, 430]], { color: C.blue });
  s.text(1580, 462, 'rows', { size: 20, color: C.blue });

  s.text(1580, 690, 'prompt', { size: 20, color: C.orange });
  s.line([[1475, 720], [1740, 720]], { color: C.orange, dashed: true });
  s.line([[1740, 780], [1475, 780]], { color: C.blue });
  s.text(1580, 812, 'tip ≤ 3 sentences', { size: 20, color: C.blue });

  s.legend(1035, [RESPONSE, REQUEST]);
  return s;
}

function sessionFlow() {
  const s = new Sketch(1950, 1340, 23);
  s.title('Session Flow · app launch & login');

  const X = 380;
  s.node(X, 210, 360, 100, 'App launch', 'main() · MultiProvider', { r: 40 });
  s.line([[X, 262], [X, 318]]);
  s.node(X, 375, 420, 110, 'SplashScreen', ['fade 1.5 s + restoreSession()'], { color: C.blue, dashed: true });
  s.line([[X, 432], [X, 480]]);
  s.diamond(X, 565, 340, 160);
  s.text(X, 565, ['token in', 'keychain?'], { size: 24 });
  s.line([[X, 646], [X, 718]]);
  s.text(X + 30, 682, 'yes', { size: 20, color: C.muted, anchor: 'start' });
  s.node(X, 770, 360, 100, 'GET /auth/me', 'Authorization: Bearer', { titleColor: C.orange });
  s.line([[X, 822], [X, 880]]);
  s.diamond(X, 960, 300, 150);
  s.text(X, 960, 'status?', { size: 24 });
  s.line([[X, 1036], [X, 1118]], { color: C.blue });
  s.text(X + 30, 1077, '200', { size: 20, color: C.blue, anchor: 'start' });
  s.node(X, 1170, 360, 100, 'HomePage', 'user, assets, last 3 txns', { r: 40, color: C.blue });

  // Side column
  const S = 1000;
  s.line([[551, 565], [818, 565]]);
  s.text(685, 540, 'no', { size: 20, color: C.muted });
  s.node(S, 565, 360, 110, 'LoginPage', 'email · password');

  s.line([[531, 960], [838, 960]], { color: C.red });
  s.text(685, 935, '401', { size: 20, color: C.red });
  s.node(S, 960, 320, 100, 'logout()', 'delete stored token', { color: C.red });
  s.line([[S, 908], [S, 622]], { color: C.red });
  s.text(S, 1050, ['network / 5xx →', 'LoginPage, token kept'], { size: 18, color: C.muted });

  // Login round-trip
  s.rect(1370, 410, 460, 310, { color: C.group, dashed: true, r: 10 });
  s.text(1600, 450, 'FastAPI', { size: 22, color: C.muted });
  s.node(1600, 590, 400, 150, 'POST /auth/login', ['email.lower() → SELECT', 'bcrypt.checkpw → JWT'], { r: 20 });
  s.line([[1182, 555], [1398, 555]], { color: C.orange, dashed: true });
  s.line([[1398, 620], [1182, 620]], { color: C.blue });
  s.text(1275, 655, '{ token, user }', { size: 20, color: C.blue });
  s.node(1600, 860, 400, 130, 'SecureTokenStorage', ['_storeSession()', 'flutter_secure_storage'], { color: C.blue, dashed: true });
  s.line([[1600, 667], [1600, 792]], { color: C.blue });
  s.line([[1600, 927], [1600, 1170], [562, 1170]], { color: C.blue });
  s.text(1100, 1140, 'session.user = user · notifyListeners()', { size: 20, color: C.blue });

  s.legend(1290, [
    { label: 'happy path', color: C.blue },
    REQUEST,
    { label: 'unauthorized', color: C.red },
  ]);
  return s;
}

function authGuard() {
  const s = new Sketch(2000, 1080, 5);
  s.title('Auth · login & request guard');

  const row = (y, label, nodes, fails) => {
    s.text(150, y - 110, label, { size: 26, color: C.orange, anchor: 'start' });
    const W = 290;
    const gap = 60;
    const xs = nodes.map((_, i) => 150 + W / 2 + i * (W + gap));
    nodes.forEach(([t, sub, opts], i) => s.node(xs[i], y, W, 130, t, sub, { titleSize: 24, subSize: 19, ...opts }));
    for (let i = 0; i < xs.length - 1; i++) {
      s.line([[xs[i] + W / 2 + 6, y], [xs[i + 1] - W / 2 - 6, y]], { color: C.blue });
    }
    for (const { from, x, text } of fails) {
      for (const i of from) {
        s.line([[xs[i], y + 68], [xs[i], y + 115], [x, y + 115], [x, y + 145]], { color: C.red, dashed: true });
      }
      s.node(x, y + 190, 360, 80, text, null, { color: C.red, titleColor: C.red, titleSize: 22 });
    }
    return xs;
  };

  row(
    300,
    'POST /auth/login',
    [
      ['LoginRequest', ['email · password']],
      ['normalize', ['email.lower()']],
      ['lookup', ['SELECT user', 'WHERE email']],
      ['bcrypt', ['checkpw(pw, hash)']],
      ['create_access_token', ['HS256 · sub = user.id', 'exp = now + 7 d'], { color: C.blue }],
    ],
    [{ from: [2, 3], x: 1025, text: '401 Invalid email or password' }],
  );

  row(
    740,
    'every protected route',
    [
      ['HTTPBearer', ['Authorization header', 'scheme == bearer']],
      ['decode_access_token', ['verify signature', 'and expiry']],
      ['db.get(User, sub)', ['user still exists']],
      ['_get_owned(id)', ['row.user_id == user.id']],
      ['handler', ['commit → JSON'], { color: C.blue }],
    ],
    [
      { from: [0, 1, 2], x: 500, text: '401 Not authenticated' },
      { from: [3], x: 1375, text: '404 not found' },
    ],
  );

  s.legend(1035, [
    { label: 'ok', color: C.blue },
    { label: 'rejected', color: C.red, dashed: true },
  ]);
  return s;
}

function spendingBuckets() {
  const s = new Sketch(2000, 1330, 42);
  s.title('Spending Analytics · 5 day-buckets per month');

  // Day strip
  const x0 = 170;
  const cw = 53;
  const y0 = 170;
  const bucketOf = (d) => Math.min(Math.floor((d - 1) / 6), 4);
  for (let d = 1; d <= 31; d++) {
    const x = x0 + (d - 1) * cw;
    const color = bucketOf(d) % 2 === 0 ? C.blue : C.orange;
    s.rect(x + 3, y0, cw - 6, 56, { color, r: 8, width: 1.6 });
    s.text(x + cw / 2, y0 + 28, String(d), { size: 18, color: C.fg });
  }
  const labels = ['b0 · 1–6', 'b1 · 7–12', 'b2 · 13–18', 'b3 · 19–24', 'b4 · 25–31 (7 days)'];
  for (let b = 0; b < 5; b++) {
    const first = b * 6 + 1;
    const last = b === 4 ? 31 : first + 5;
    const xa = x0 + (first - 1) * cw + 6;
    const xb = x0 + last * cw - 6;
    const color = b % 2 === 0 ? C.blue : C.orange;
    s.line([[xa, y0 + 76], [xa, y0 + 90], [xb, y0 + 90], [xb, y0 + 76]], { color, head: false });
    s.text((xa + xb) / 2, y0 + 122, labels[b], { size: 20, color });
  }

  // Pipeline
  s.node(400, 520, 440, 140, 'SELECT date, amount', ['WHERE user_id', '[AND category]'], { titleSize: 26 });
  s.node(1300, 520, 520, 140, 'bucket_index(day)', ['min((day − 1) // 6, 4)'], { color: C.orange, titleSize: 28, subSize: 24 });
  s.line([[625, 520], [1035, 520]], { color: C.blue });
  s.text(830, 490, '(date, amount)[ ]', { size: 20, color: C.blue });
  s.line([[1300, 448], [1300, 340]], { color: C.orange, dashed: true });
  s.text(1320, 395, 'maps every day', { size: 18, color: C.muted, anchor: 'start' });

  // Outputs
  const oy = 850;
  s.line([[400, 592], [400, oy - 132]], { color: C.blue });
  s.line([[1180, 592], [1180, 660], [1000, 660], [1000, oy - 132]], { color: C.blue });
  s.line([[1420, 592], [1420, 660], [1620, 660], [1620, oy - 132]], { color: C.blue });

  s.node(400, oy, 500, 250, 'category_percentages', [
    'total per category (month)',
    'share = total / Σ total · 100',
    'drop ≤ 0 · sort by −total, name',
  ], { color: C.blue, dashed: true, titleSize: 26 });
  s.node(1000, oy, 500, 250, 'month_buckets(y, m)', [
    'keep entries of that month',
    'buckets[bucket_index] += amt',
    'round(·, 2)',
  ], { color: C.blue, dashed: true, titleSize: 26 });
  s.node(1620, oy, 520, 250, 'average_buckets', [
    'group by (year, month)',
    'Σ bucketᵢ ÷ #months with data',
    'no data → [0, 0, 0, 0, 0]',
  ], { color: C.blue, dashed: true, titleSize: 26 });

  // Consumers
  const cy = 1140;
  s.line([[400, oy + 127], [400, cy - 52]], { color: C.orange, dashed: true });
  s.text(420, 1030, 'GET /monthly-category-percentages', { size: 18, color: C.orange, anchor: 'start' });
  s.node(400, cy, 420, 100, 'CategoryPieChart', 'Analytics tab');

  s.line([[1000, oy + 127], [1000, 1040], [1240, 1040], [1240, cy - 52]], { color: C.orange, dashed: true });
  s.line([[1620, oy + 127], [1620, 1040], [1380, 1040], [1380, cy - 52]], { color: C.orange, dashed: true });
  s.text(1030, 1015, '*-buckets-by-month', { size: 18, color: C.orange, anchor: 'start' });
  s.text(1640, 1015, '*-buckets', { size: 18, color: C.orange, anchor: 'start' });
  s.node(1310, cy, 520, 100, 'SpendingLineChart', 'this month vs average');

  s.legend(1275, [
    { label: 'data', color: C.blue },
    { label: 'HTTP response', color: C.orange, dashed: true },
  ]);
  return s;
}

function trackerPipeline() {
  const s = new Sketch(2060, 1120, 3);
  s.title('Tracker Page · load pipeline');

  s.rect(140, 170, 520, 820);
  s.text(400, 222, 'TrackerPage', { size: 38 });
  s.text(400, 268, 'month · category change', { size: 22, color: C.muted });
  s.node(400, 390, 430, 130, '_loadData()', ['requestId = ++_requestId'], { color: C.blue, dashed: true });
  s.node(400, 570, 430, 130, 'stale guard', ['mounted && id == _requestId', 'else drop response'], { color: C.blue, dashed: true });
  s.node(400, 750, 430, 130, 'setState', ['line chart · pie chart', 'Σ buckets → totals'], { color: C.blue, dashed: true });
  s.node(400, 910, 430, 100, 'AiSuggestionCard', '_loadSuggestion(id)', { color: C.orange, dashed: true, titleSize: 26 });

  s.rect(1260, 150, 700, 860, { color: C.group, dashed: true, r: 10 });
  s.text(1610, 200, 'FastAPI', { size: 22, color: C.muted });
  s.node(1610, 400, 560, 230, 'Analytics API', ['month buckets', 'average buckets', 'category shares'], { r: 20 });
  s.text(1610, 485, 'Future.wait · 3 in parallel', { size: 20, color: C.orange });
  s.node(1610, 790, 560, 250, 'POST /ai/suggestion', [
    'build_prompt(category, month,',
    'monthTotal, monthlyAverage, currency)',
    '→ OpenRouter · 100 tokens',
  ], { r: 20 });

  s.text(960, 305, ['GET /transactions/…-buckets-by-month', 'GET /transactions/…-buckets', 'GET /monthly-category-percentages'], { size: 19, color: C.orange });
  s.line([[680, 365], [1310, 365]], { color: C.orange, dashed: true });
  s.line([[1310, 440], [680, 440]], { color: C.blue });
  s.text(960, 480, '[5] · [5] · [{category, total, %}]', { size: 20, color: C.blue });

  s.text(960, 690, ['monthTotal = Σ month buckets', 'monthlyAverage = Σ avg buckets'], { size: 20, color: C.orange });
  s.line([[680, 745], [1310, 745]], { color: C.orange, dashed: true });
  s.line([[1310, 825], [680, 825]], { color: C.blue });
  s.text(960, 870, ['200 suggestion', '503 not configured · 502 provider'], { size: 20, color: C.blue });

  s.legend(1075, [RESPONSE, REQUEST]);
  return s;
}

const diagrams = {
  architecture,
  'session-flow': sessionFlow,
  'auth-guard': authGuard,
  'spending-buckets': spendingBuckets,
  'tracker-pipeline': trackerPipeline,
};

for (const [name, build] of Object.entries(diagrams)) {
  writeFileSync(join(here, `${name}.svg`), build().svg());
  console.log(`wrote ${name}.svg`);
}
