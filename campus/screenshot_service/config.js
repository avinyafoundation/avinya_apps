require('dotenv').config();

module.exports = {
  // Port this service runs on
  PORT: process.env.PORT || 9098,

  // Your backend APIs
  ATTENDANCE_API_URL: process.env.ATTENDANCE_API_URL,

  // API Keys
  ATTENDANCE_API_KEY:  process.env.ATTENDANCE_API_KEY,

  // Org & activity config
  PARENT_ORG_ID: process.env.PARENT_ORG_ID ? parseInt(process.env.PARENT_ORG_ID) : 2,
  ACTIVITY_ID:   process.env.ACTIVITY_ID   ? parseInt(process.env.ACTIVITY_ID)   : 4,

  // WhatsApp recipients
  WHATSAPP_TO_1: process.env.WHATSAPP_TO_1,
  WHATSAPP_TO_2: process.env.WHATSAPP_TO_2,
  
  // Email (Nodemailer + Gmail)
  EMAIL_FROM:         process.env.EMAIL_FROM,
  EMAIL_APP_PASSWORD: process.env.EMAIL_APP_PASSWORD,
  EMAIL_TO_1:         process.env.EMAIL_TO_1,
  EMAIL_TO_2:         process.env.EMAIL_TO_2,

  // Cron schedule — default: every day at 10:00 AM (Sri Lanka time)
  // Format: 'second minute hour dayOfMonth month dayOfWeek'
  CRON_SCHEDULE: '0 0 10 * * *',
};