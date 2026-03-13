// pipeline.js — Fetch → Render → Screenshot → Cloudinary → WhatsApp

const puppeteer = require('puppeteer');
const axios     = require('axios');
const FormData  = require('form-data');
const nodemailer = require('nodemailer');
const config    = require('./config');
const { generateReport } = require('./reportTemplate');

// ─────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────
function todayString() {
  return new Date().toISOString().slice(0, 10); // YYYY-MM-DD
}

function log(icon, msg) {
  const ts = new Date().toTimeString().slice(0, 8);
  console.log(`[${ts}] ${icon}  ${msg}`);
}

// ─────────────────────────────────────────────
// Step 1: Fetch data
// ─────────────────────────────────────────────
async function fetchAttendanceData(date) {
  log('📡', `Fetching attendance for ${date}...`);
  const url = `${config.ATTENDANCE_API_URL}/daily_students_attendance_by_parent_org/${config.PARENT_ORG_ID}?date=${date}`;
  const res = await axios.get(url, {
    timeout: 150000,
    headers: { 'api-key': config.ATTENDANCE_API_KEY },
  });
  log('✅', `Got ${res.data.length} class records`);
  return res.data;
}

async function fetchLateData(date) {
  log('📡', `Fetching late-arrival data for ${date}...`);
  const url = `${config.ATTENDANCE_API_URL}/organizations/${config.PARENT_ORG_ID}/late-attendance-summary?date=${date}&activity_id=${config.ACTIVITY_ID}`;
  try {
    const res = await axios.get(url, {
      timeout: 150000,
      headers: { 'api-key': config.ATTENDANCE_API_KEY },
    });
    const total = res.data.reduce((s, i) => s + (i.student_count || 0), 0);
    log('✅', `Got ${res.data.length} late-arrival buckets (${total} students late)`);
    return res.data;
  } catch (err) {
    log('⚠️', `Late-arrival data unavailable: ${err.message}`);
    return [];
  }
}

// ─────────────────────────────────────────────
// Step 2: Screenshot with Puppeteer
// ─────────────────────────────────────────────
async function takeScreenshot(htmlContent) {
  log('📸', 'Launching headless browser...');
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage'],
  });

  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 600, height: 10, deviceScaleFactor: 2 });
    await page.setContent(htmlContent, { waitUntil: 'networkidle0', timeout: 30000 });

    // Let fonts/animations settle
    await new Promise(r => setTimeout(r, 800));

    // Capture full content height
    const bodyHeight = await page.evaluate(() => document.body.scrollHeight);
    await page.setViewport({ width: 600, height: bodyHeight, deviceScaleFactor: 2 });

    const screenshotData = await page.screenshot({ type: 'png', fullPage: true });
    const screenshot = Buffer.from(screenshotData);
    log('✅', `Screenshot taken — ${(screenshot.length / 1024).toFixed(1)} KB`);
    return screenshot;
  } finally {
    await browser.close();
  }
}

// ─────────────────────────────────────────────
// Step 3: Upload to Cloudinary via your API
// ─────────────────────────────────────────────
async function uploadToCloudinary(imageBuffer, date) {
  log('☁️', 'Uploading image to Cloudinary...');
  const form = new FormData();
  form.append('image', imageBuffer, {
    filename: `attendance_${date}.png`,
    contentType: 'image/png',
  });

  const res = await axios.post(
    `${config.ATTENDANCE_API_URL}/upload/image`,
    form,
    { headers: { ...form.getHeaders(), 'api-key': config.ATTENDANCE_API_KEY }, timeout: 30000 }
  );

  const secureUrl = res.data.secure_url;
  log('✅', `Uploaded → ${secureUrl}`);
  return secureUrl;
}

// ─────────────────────────────────────────────
// Step 4: Send via WhatsApp
// ─────────────────────────────────────────────
async function sendWhatsApp(imageUrl, date) {
  log('💬', 'Sending WhatsApp messages...');
  const formattedDate = new Date(date + 'T00:00:00').toLocaleDateString('en-US', {
    weekday: 'long', year: 'numeric', month: 'long', day: 'numeric',
  });

  const payload = {
    image_url: imageUrl,
    date:      formattedDate,
  };

  // Send to both numbers
  await Promise.all([
    axios.post(
      `${config.ATTENDANCE_API_URL}/whatsapp/send/image`,
      { ...payload, to: config.WHATSAPP_TO_1 },
      { headers: { 'Content-Type': 'application/json', 'api-key': config.ATTENDANCE_API_KEY }, timeout: 150000 }
    ),
    axios.post(
      `${config.ATTENDANCE_API_URL}/whatsapp/send/image`,
      { ...payload, to: config.WHATSAPP_TO_2 },
      { headers: { 'Content-Type': 'application/json', 'api-key': config.ATTENDANCE_API_KEY }, timeout: 150000 }
    ),
  ]);

  log('✅', `WhatsApp messages sent to ${config.WHATSAPP_TO_1} and ${config.WHATSAPP_TO_2}`);
}

// ─────────────────────────────────────────────
// Step 5: Send Email
// ─────────────────────────────────────────────
async function sendEmail(imageBuffer, date) {
  log('📧', 'Sending email report...');

  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: config.EMAIL_FROM,
      pass: config.EMAIL_APP_PASSWORD,
    },
  });

  const formattedDate = new Date(date + 'T00:00:00').toLocaleDateString('en-US', {
    weekday: 'long', year: 'numeric', month: 'long', day: 'numeric',
  });

  const recipients = [config.EMAIL_TO_1, config.EMAIL_TO_2, config.EMAIL_TO_3, config.EMAIL_TO_4].filter(Boolean).join(',');

  await transporter.sendMail({
    from:    `"Avinya Academy" <${config.EMAIL_FROM}>`,
    to:      recipients,
    subject: `Avinya Academy Attendance Report — ${formattedDate}`,
    text:    `Please find the attendance report for ${formattedDate} attached.`,
    attachments: [{
      filename:    `attendance_${date}.png`,
      content:     imageBuffer,
      contentType: 'image/png',
    }],
  });

  log('✅', `Email sent to ${recipients}`);
}
// ─────────────────────────────────────────────
async function runPipeline(overrideDate) {
  const date = overrideDate || todayString();
  const started = Date.now();

  console.log('\n╔══════════════════════════════════════════════════════════╗');
  console.log(`║  ATTENDANCE REPORT PIPELINE  —  ${date}               ║`);
  console.log('╚══════════════════════════════════════════════════════════╝\n');

  const result = {
    success: false,
    date,
    timestamp: new Date().toISOString(),
    cloudinaryUrl: null,
    whatsappSent:  false,
    emailSent:     false,
    error: null,
    durationMs: 0,
  };

  try {
    // 1. Fetch
    const [attendanceData, lateData] = await Promise.all([
      fetchAttendanceData(date),
      fetchLateData(date),
    ]);

    // Check if there's any attendance data
    const totalPresent = attendanceData.reduce((s, i) => s + (i.present_count || 0), 0);
    if (totalPresent === 0) {
      log('⏭️', 'No attendance recorded today — skipping report');
      result.error = 'No attendance data';
      result.durationMs = Date.now() - started;
      console.log('═══════════════════════════════════════════════════════════\n');
      return result;
    }

    // 2. Render HTML
    log('🎨', 'Rendering HTML report...');
    const html = generateReport({ attendanceData, lateData, date });

    // 3. Screenshot
    const imageBuffer = await takeScreenshot(html);

    // 4. Upload
    const cloudinaryUrl = await uploadToCloudinary(imageBuffer, date);
    result.cloudinaryUrl = cloudinaryUrl;

    // 5. WhatsApp
    await sendWhatsApp(cloudinaryUrl, date);
    result.whatsappSent = true;

    // 6. Email
    await sendEmail(imageBuffer, date);
    result.emailSent = true;

    result.success = true;
    result.durationMs = Date.now() - started;

    console.log(`\n✨ Pipeline complete in ${(result.durationMs / 1000).toFixed(1)}s`);
    console.log('═══════════════════════════════════════════════════════════\n');
  } catch (err) {
    result.error = err.message;
    result.durationMs = Date.now() - started;
    log('❌', `Pipeline failed: ${err.message}`);
    console.log('═══════════════════════════════════════════════════════════\n');
  }

  return result;
}

module.exports = { runPipeline };