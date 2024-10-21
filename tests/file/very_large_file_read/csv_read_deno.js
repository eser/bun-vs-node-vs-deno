import { createReadStream } from 'node:fs';
import { join } from 'node:path';
import { createInterface } from 'node:readline';

const testDataPath = process.env.TEST_DATA_PATH || '/app/test_data';
const directoryPath = join(testDataPath, 'very_large_files');
const filePath = join(directoryPath, 'very_large_data.csv')

async function readLargeCSV() {
  const fileStream = createReadStream(filePath);
  const rl = createInterface({
    input: fileStream,
    crlfDelay: Infinity
  });

  let lineCount = 0;
  for await (const line of rl) {
    lineCount++;
  }

  console.log(`Total lines: ${lineCount}`);
}

console.time('Node.js CSV Read');
readLargeCSV().then(() => {
  console.timeEnd('Node.js CSV Read');
});
