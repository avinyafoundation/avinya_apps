// reportTemplate.js — Light mode design matching the Flutter app UI exactly

function toHex(colorStr) {
  if (!colorStr) return '#2196F3';
  return '#' + colorStr.replace(/^0xFF|^#/, '');
}

const CLASS_EMOJIS = {
  Dolphins: '🐬',
  Bears:    '🐻',
  Bees:     '🐝',
  Eagles:   '🦅',
  Leopards: '🐆',
  Sharks:   '🦈',
  Penguins: '🐧',
  Zebras:   '🦓',
};

const LATE_COLORS = {
  'Before 07:30':  '#2ECC71',
  '07:30 - 07:45': '#3498DB',
  '07:45 - 08:00': '#F39C12',
  '08:00 - 08:30': '#E67E22',
  'After 08:30':   '#E74C3C',
};

function getLateColor(label) {
  return LATE_COLORS[label] || '#9E9E9E';
}

// Full pie chart (no hole) — matches the image
function generatePieSegments(lateData) {
  const total = lateData.reduce((s, i) => s + (i.student_count || 0), 0);
  if (total === 0) return '<circle cx="90" cy="90" r="80" fill="#E0E0E0"/>';

  let angle = -90;
  return lateData.map(item => {
    const count = item.student_count || 0;
    if (!count) return '';
    const sweep = (count / total) * 360;
    const r = 80;
    const cx = 90, cy = 90;
    const startRad = (angle * Math.PI) / 180;
    const endRad   = ((angle + sweep) * Math.PI) / 180;
    const x1 = cx + r * Math.cos(startRad);
    const y1 = cy + r * Math.sin(startRad);
    const x2 = cx + r * Math.cos(endRad);
    const y2 = cy + r * Math.sin(endRad);
    const large = sweep > 180 ? 1 : 0;
    const color = getLateColor(item.label);
    angle += sweep;
    return `<path d="M${cx},${cy} L${x1.toFixed(2)},${y1.toFixed(2)} A${r},${r} 0 ${large},1 ${x2.toFixed(2)},${y2.toFixed(2)} Z" fill="${color}" stroke="white" stroke-width="2"/>`;
  }).join('');
}

// Inner white donut hole — shows number in center
function generateDonutHole(totalLate) {
  return `
    <circle cx="90" cy="90" r="48" fill="white"/>
    <text x="90" y="85" text-anchor="middle" font-family="'Roboto',sans-serif" font-size="28" font-weight="700" fill="#263238">${totalLate}</text>
    <text x="90" y="105" text-anchor="middle" font-family="'Roboto',sans-serif" font-size="13" fill="#90A4AE">Students</text>
  `;
}

function generateReport({ attendanceData, lateData, date }) {
  const dateObj = new Date(date + 'T00:00:00');
  const shortDate = dateObj.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  const shortDateBadge = dateObj.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });

  const totalStudents = attendanceData.reduce((s, i) => s + (i.total_student_count || 0), 0);
  const presentCount  = attendanceData.reduce((s, i) => s + (i.present_count || 0), 0);
  const percentage    = totalStudents > 0 ? (presentCount / totalStudents * 100) : 0;

  const totalLate = lateData.reduce((s, i) => s + (i.student_count || 0), 0);
  const maxLate   = lateData.reduce((m, i) => Math.max(m, i.student_count || 0), 1);

  // Blue donut for attendance — thick stroke, light grey track
  const R = 70;
  const circ = 2 * Math.PI * R;
  const dash = (percentage / 100) * circ;
  const gap  = circ - dash;

  // Pie chart SVG
  const pieSegments = generatePieSegments(lateData);
  const donutHole   = generateDonutHole(totalLate);

  // Late bars
  const lateBars = lateData.map(item => {
    const color = getLateColor(item.label);
    const count = item.student_count || 0;
    const barPct = totalLate > 0 ? (count / totalLate * 100) : 0;
    return `
      <div class="bar-row">
        <div class="bar-label-row">
          <span class="bar-dot" style="background:${color}"></span>
          <span class="bar-label">${item.label}</span>
        </div>
        <div class="bar-track">
          <div class="bar-fill" style="width:${barPct}%;background:${color}"></div>
        </div>
        <span class="bar-count" style="color:${color}">${count}</span>
      </div>`;
  }).join('');

  // Class cards
  const classCards = attendanceData.map(cls => {
    const name    = cls.description || 'Unknown';
    const present = cls.present_count || 0;
    const total   = cls.total_student_count || 0;
    const absent  = total - present;
    const pct     = total > 0 ? (present / total * 100) : 0;
    const emoji   = CLASS_EMOJIS[name] || '📚';
    const color   = toHex(cls.color);
    // mini donut
    const r2 = 26, circ2 = 2 * Math.PI * r2;
    const d2 = (pct / 100) * circ2;
    const g2 = circ2 - d2;

    return `
      <div class="class-card">
        <div class="class-card-inner">
          <div class="class-donut-wrap">
            <svg viewBox="0 0 70 70" width="70" height="70">
              <circle cx="35" cy="35" r="26" fill="none" stroke="#ECEFF1" stroke-width="8"/>
              <circle cx="35" cy="35" r="26" fill="none" stroke="${color}" stroke-width="8"
                stroke-dasharray="${d2.toFixed(2)} ${g2.toFixed(2)}"
                stroke-linecap="round" transform="rotate(-90 35 35)"/>
            </svg>
            <div class="class-donut-center">
              <span class="class-emoji">${emoji}</span>
            </div>
          </div>
          <div class="class-info">
            <div class="class-name">${name}</div>
            <div class="class-pct" style="color:${color}">${pct.toFixed(0)}%</div>
            <div class="class-sub">
              <span class="cls-present">✓ ${present}</span>
              <span class="cls-absent">✗ ${absent}</span>
            </div>
          </div>
        </div>
      </div>`;
  }).join('');

  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Student Attendance – ${shortDate}</title>
<style>
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  body {
    font-family: 'Roboto', 'Segoe UI', Arial, sans-serif;
    background: #ECEFF1;
    color: #263238;
    width: 600px;
    padding: 16px;
  }

  /* ── CARD ── */
  .card {
    background: #FFFFFF;
    border-radius: 16px;
    padding: 20px 24px;
    margin-bottom: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.07);
  }
  .card-title {
    font-size: 15px;
    font-weight: 700;
    color: #263238;
    margin-bottom: 4px;
  }
  .card-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 20px;
  }
  .date-badge {
    background: #E8F5E9;
    color: #388E3C;
    font-size: 12px;
    font-weight: 600;
    padding: 3px 10px;
    border-radius: 20px;
  }

  /* ── ATTENDANCE DONUT ── */
  .donut-section {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 8px 0 12px;
  }
  .donut-wrap {
    position: relative;
    width: 180px;
    height: 180px;
    margin-bottom: 6px;
  }
  .donut-wrap svg { width: 100%; height: 100%; }
  .donut-center {
    position: absolute;
    inset: 0;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
  }
  .donut-number {
    font-size: 48px;
    font-weight: 700;
    color: #263238;
    line-height: 1;
  }
  .donut-of {
    font-size: 15px;
    color: #90A4AE;
    margin-top: 2px;
  }
  .donut-label-text {
    font-size: 14px;
    color: #607D8B;
    margin-bottom: 10px;
  }
  .pct-badge {
    background: #E8F5E9;
    color: #388E3C;
    border: 1.5px solid #A5D6A7;
    font-size: 13px;
    font-weight: 600;
    padding: 4px 14px;
    border-radius: 20px;
  }

  /* ── LATE ANALYSIS ── */
  .late-body {
    display: flex;
    align-items: center;
    gap: 24px;
  }
  .pie-wrap {
    flex-shrink: 0;
    width: 180px;
    height: 180px;
  }
  .pie-wrap svg { width: 100%; height: 100%; }
  .bars-section {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 12px;
  }
  .bar-row {}
  .bar-label-row {
    display: flex;
    align-items: center;
    gap: 6px;
    margin-bottom: 4px;
  }
  .bar-dot {
    width: 10px; height: 10px;
    border-radius: 50%;
    flex-shrink: 0;
  }
  .bar-label {
    font-size: 12px;
    color: #546E7A;
  }
  .bar-track {
    height: 6px;
    background: #ECEFF1;
    border-radius: 3px;
    overflow: hidden;
    margin-bottom: 2px;
  }
  .bar-fill {
    height: 100%;
    border-radius: 3px;
  }
  .bar-count {
    font-size: 12px;
    font-weight: 700;
    display: block;
    text-align: right;
  }

  /* ── CLASS GRID ── */
  .classes-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 10px;
  }
  .class-card {
    background: #FAFAFA;
    border: 1px solid #ECEFF1;
    border-radius: 12px;
    padding: 12px 8px;
  }
  .class-card-inner {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 6px;
  }
  .class-donut-wrap {
    position: relative;
    width: 70px;
    height: 70px;
  }
  .class-donut-center {
    position: absolute;
    inset: 0;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .class-emoji { font-size: 20px; }
  .class-name {
    font-size: 11px;
    font-weight: 600;
    color: #37474F;
    text-align: center;
  }
  .class-pct {
    font-size: 16px;
    font-weight: 700;
  }
  .class-sub {
    display: flex;
    gap: 6px;
    font-size: 10px;
  }
  .cls-present { color: #43A047; }
  .cls-absent  { color: #E53935; }

  /* ── FOOTER ── */
  .footer {
    text-align: center;
    font-size: 11px;
    color: #90A4AE;
    margin-top: 4px;
    padding-bottom: 4px;
  }
</style>
</head>
<body>

<!-- Card 1: Overall Attendance -->
<div class="card">
  <div class="card-title">Student Attendance - ${shortDate}</div>
  <div class="donut-section">
    <div class="donut-wrap">
      <svg viewBox="0 0 180 180">
        <!-- track -->
        <circle cx="90" cy="90" r="${R}" fill="none" stroke="#ECEFF1" stroke-width="16"/>
        <!-- progress -->
        <circle cx="90" cy="90" r="${R}" fill="none" stroke="#2196F3" stroke-width="16"
          stroke-dasharray="${dash.toFixed(2)} ${gap.toFixed(2)}"
          stroke-linecap="round"
          transform="rotate(-90 90 90)"/>
      </svg>
      <div class="donut-center">
        <div class="donut-number">${totalLate}</div>
        <div class="donut-of">of ${totalStudents}</div>
      </div>
    </div>
    <div class="donut-label-text">Students Present</div>
    <div class="pct-badge">${percentage.toFixed(2)}%</div>
  </div>
</div>

<!-- Card 2: Late Attendance Analysis -->
<div class="card">
  <div class="card-header">
    <div class="card-title">Late Attendance Analysis</div>
    <div class="date-badge">${shortDateBadge}</div>
  </div>
  <div class="late-body">
    <div class="pie-wrap">
      <svg viewBox="0 0 180 180">
        ${pieSegments}
        ${donutHole}
      </svg>
    </div>
    <div class="bars-section">
      ${lateBars || '<div style="color:#90A4AE;font-size:13px;">No late arrivals recorded</div>'}
    </div>
  </div>
</div>

<div class="footer">Avinya Academy • Automated Report •</div>

</body>
</html>`;
}

module.exports = { generateReport };