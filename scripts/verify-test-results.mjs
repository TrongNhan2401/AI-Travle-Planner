import { readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

const directory = process.argv[2];
const reports = readdirSync(directory).filter((file) => file.endsWith('.trx'));
if (reports.length === 0) {
  console.error('[tests] No TRX report generated. Check test discovery and solution membership.');
  process.exit(1);
}

let total = 0;
for (const report of reports) {
  const xml = readFileSync(join(directory, report), 'utf8');
  const counters = xml.match(/<Counters\b[^>]*>/)?.[0];
  const count = Number(counters?.match(/\btotal="(\d+)"/)?.[1]);
  const executed = Number(counters?.match(/\bexecuted="(\d+)"/)?.[1]);
  const passed = Number(counters?.match(/\bpassed="(\d+)"/)?.[1]);
  if (!(count > 0) || executed !== count || passed !== count) {
    console.error(`[tests] ${report}: expected all discovered tests to execute and pass.`);
    process.exit(1);
  }
  total += count;
}
console.log(`[tests] Verified ${total} passing tests across ${reports.length} report(s).`);
