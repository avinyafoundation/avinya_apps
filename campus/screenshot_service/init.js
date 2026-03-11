// init.js — Triggers the GitHub Actions workflow via repository_dispatch and exits

require('dotenv').config();
const https = require('https');

const options = {
  hostname: 'api.github.com',
  path:     '/repos/sakunasanka/attendance-workflow/dispatches',
  method:   'POST',
  headers: {
    'Accept':               'application/vnd.github+json',
    'Authorization':        `Bearer ${process.env.GITHUB_ACCESS_TOKEN}`,
    'X-GitHub-Api-Version': '2022-11-28',
    'Content-Type':         'application/json',
    'User-Agent':           'attendance-workflow-init',
  },
};

const body = JSON.stringify({ event_type: 'trigger-attendance' });

const req = https.request(options, (res) => {
  if (res.statusCode === 204) {
    console.log('✅ Workflow triggered successfully.');
  } else {
    console.error(`❌ Unexpected status: ${res.statusCode}`);
    process.exitCode = 1;
  }
  process.exit();
});

req.on('error', (err) => {
  console.error(`❌ Request failed: ${err.message}`);
  process.exit(1);
});

req.write(body);
req.end();
