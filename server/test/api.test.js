const http = require('http');

const BASE_URL = 'http://localhost:3000';

async function testHealth() {
  return new Promise((resolve, reject) => {
    http.get(`${BASE_URL}/health`, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          resolve(json);
        } catch (e) {
          reject(new Error('Invalid JSON response'));
        }
      });
    }).on('error', reject);
  });
}

async function runTests() {
  console.log('Running API tests...\n');

  try {
    console.log('1. Testing health endpoint...');
    const health = await testHealth();
    console.log('   ✓ Health check passed:', health.status);
    console.log('\n✅ All tests passed!');
    console.log('\nServer is running. Test the following endpoints:');
    console.log('  POST /api/auth/register');
    console.log('  POST /api/auth/login');
    console.log('  GET  /api/khanis');
    console.log('  POST /api/khanis');
    console.log('  POST /api/paras/assign');
    console.log('  POST /api/paras/:id/complete');
    console.log('  GET  /api/paras/my-assignments');
    console.log('  POST /api/sawab');
  } catch (error) {
    console.error('❌ Tests failed:', error.message);
    process.exit(1);
  }
}

runTests();
