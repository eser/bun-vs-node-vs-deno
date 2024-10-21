import { readFileSync } from 'node:fs';
import { gzipSync, gunzipSync } from 'node:zlib';
import path from 'node:path';

const testDataPath = process.env.TEST_DATA_PATH || '/app/test_data';
const filePath = path.join(testDataPath, 'large_data.json');

const buffer = readFileSync(filePath);

const compressed = gzipSync(buffer);
const decompressed = gunzipSync(compressed);
