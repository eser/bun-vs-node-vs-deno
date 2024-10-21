import { readFileSync } from 'node:fs';

import path from 'node:path';
const testDataPath = process.env.TEST_DATA_PATH || '/app/test_data';
const filePath = path.join(testDataPath, 'large_data.json');

const jsonString = readFileSync(filePath, 'utf8');
const data = JSON.parse(jsonString);

let totalBalance = 0;
let activeUsers = 0;
let totalAge = 0;

for (const item of data) {
  totalBalance += parseFloat(item.balance.replace('$', '').replace(',', ''));
  if (item.isActive) activeUsers++;
  totalAge += item.age;
}

const averageBalance = totalBalance / data.length;
const averageAge = totalAge / data.length;
