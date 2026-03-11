// run.js — CLI entry point to run the pipeline once and exit
// Usage:  node run.js              (uses today's date)
//         node run.js 2026-03-10   (override date)

const { runPipeline } = require('./pipeline');

const date = (process.argv[2] && process.argv[2].trim()) || null;

runPipeline(date)
  .then(result => {
    if (!result.success && result.error !== 'No attendance data') {
      console.error(`\n❌ Pipeline finished with error: ${result.error}`);
      process.exit(1);
    }
    process.exit(0);
  })
  .catch(err => {
    console.error('Fatal:', err.message);
    process.exit(1);
  });
