// server.js — Express server + cron scheduler

const express = require('express');
const cron    = require('node-cron');
const config  = require('./config');
const { runPipeline } = require('./pipeline');

const app = express();
app.use(express.json());

// ─────────────────────────────────────────────
// HTTP Endpoints
// ─────────────────────────────────────────────

// Health check
app.get('/health', (req, res) => {
  res.json({
    service:   'Attendance Report Service',
    status:    'running',
    port:      config.PORT,
    schedule:  config.CRON_SCHEDULE,
    timestamp: new Date().toISOString(),
  });
});

// Manual trigger — POST /run
// Optional body: { "date": "2026-02-25" }
app.post('/run', async (req, res) => {
  const overrideDate = req.body?.date || null;
  console.log(`\n🖱️  Manual trigger received${overrideDate ? ` for date: ${overrideDate}` : ''}`);

  // Respond immediately so the caller isn't left waiting
  res.json({ message: 'Pipeline started', date: overrideDate || new Date().toISOString().slice(0, 10) });

  // Run in background
  runPipeline(overrideDate).catch(err => {
    console.error('Background pipeline error:', err.message);
  });
});

// Manual trigger — GET /run (convenient for browser testing)
app.get('/run', async (req, res) => {
  const overrideDate = req.query.date || null;
  console.log(`\n🌐 GET /run triggered${overrideDate ? ` for date: ${overrideDate}` : ''}`);
  res.json({ message: 'Pipeline started', date: overrideDate || new Date().toISOString().slice(0, 10) });
  runPipeline(overrideDate).catch(err => console.error(err.message));
});

// Preview HTML without uploading — GET /preview?date=YYYY-MM-DD
app.get('/preview', async (req, res) => {
  const date = req.query.date || new Date().toISOString().slice(0, 10);
  const axios = require('axios');
  const { generateReport } = require('./reportTemplate');

  try {
    const [attendanceRes, lateRes] = await Promise.allSettled([
      axios.get(`${config.ATTENDANCE_API_URL}/daily_students_attendance_by_parent_org/${config.PARENT_ORG_ID}?date=${date}`, {
        headers: { 'api-key': config.ATTENDANCE_API_KEY },
      }),
      axios.get(`${config.ATTENDANCE_API_URL}/organizations/${config.PARENT_ORG_ID}/late-attendance-summary?date=${date}&activity_id=${config.ACTIVITY_ID}`, {
        headers: { 'api-key': config.ATTENDANCE_API_KEY },
      }),
    ]);

    const attendanceData = attendanceRes.status === 'fulfilled' ? attendanceRes.value.data : [];
    const lateData       = lateRes.status      === 'fulfilled' ? lateRes.value.data      : [];

    const html = generateReport({ attendanceData, lateData, date });
    res.setHeader('Content-Type', 'text/html');
    res.send(html);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ─────────────────────────────────────────────
// Cron Scheduler — Default: 10:00 AM daily
// ─────────────────────────────────────────────
console.log(`\n⏰ Scheduling cron: "${config.CRON_SCHEDULE}" (10:00 AM daily)`);
cron.schedule(config.CRON_SCHEDULE, () => {
  const now = new Date().toLocaleString('en-US', { timeZone: 'Asia/Colombo' });
  console.log(`\n🔔 Cron fired at ${now}`);
  runPipeline().catch(err => console.error('Cron pipeline error:', err.message));
}, {
  timezone: 'Asia/Colombo', // Sri Lanka time — change if needed
});

// ─────────────────────────────────────────────
// Start
// ─────────────────────────────────────────────
app.listen(config.PORT, () => {
  console.log('\n╔══════════════════════════════════════════════════════════════╗');
  console.log('║          ATTENDANCE REPORT SERVICE  —  READY                 ║');
  console.log('╚══════════════════════════════════════════════════════════════╝');
  console.log('');
  console.log(`  🚀  http://localhost:${config.PORT}`);
  console.log('');
  console.log('  Endpoints:');
  console.log(`    GET  /health          — Service status`);
  console.log(`    GET  /preview         — Preview report HTML in browser`);
  console.log(`    GET  /preview?date=YYYY-MM-DD`);
  console.log(`    POST /run             — Trigger full pipeline now`);
  console.log(`    POST /run  { "date": "YYYY-MM-DD" }  — Specific date`);
  console.log(`    GET  /run             — Same, browser-friendly`);
  console.log('');
  console.log(`  ⏰  Daily cron: ${config.CRON_SCHEDULE}  (10:00 AM Asia/Colombo)`);
  console.log('');
  console.log('  Config:');
  console.log(`    Attendance API : ${config.ATTENDANCE_API_URL}`);
  console.log('');
});