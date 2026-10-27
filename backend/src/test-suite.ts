import app from './index';
import http from 'http';
import httpReq from 'http';

async function runTests() {
  console.log('🧪 Running Backend API Automated Tests...');
  const server = http.createServer(app);
  await new Promise<void>((resolve) => server.listen(0, resolve));
  const address = server.address() as any;
  const port = address.port;
  const baseUrl = `http://localhost:${port}/api/v1`;

  console.log(`📡 Test Server listening on port ${port}`);

  let farmerToken = '';
  let agentToken = '';
  let testCropId = '';
  let testBookingId = '';

  async function request(path: string, options: { method?: string; headers?: Record<string, string>; body?: any } = {}) {
    const url = `${baseUrl}${path}`;
    const method = options.method || 'GET';
    const payload = options.body ? JSON.stringify(options.body) : null;

    return new Promise<{ status: number; body: any }>((resolve, reject) => {
      const u = new URL(url);
      const req = httpReq.request(
        {
          hostname: u.hostname,
          port: u.port,
          path: u.pathname + u.search,
          method: method,
          headers: {
            'Content-Type': 'application/json',
            ...(options.headers || {}),
          },
        },
        (res) => {
          let data = '';
          res.on('data', (chunk) => (data += chunk));
          res.on('end', () => {
            try {
              const parsed = JSON.parse(data);
              resolve({ status: res.statusCode || 500, body: parsed });
            } catch (e) {
              resolve({ status: res.statusCode || 500, body: data });
            }
          });
        }
      );
      req.on('error', reject);
      if (payload) req.write(payload);
      req.end();
    });
  }

  try {
    // 1. Health check
    console.log('Test 1: Health Check Endpoint');
    const health = await request('/health');
    if (health.status !== 200 || health.body.status !== 'UP') {
      throw new Error(`Health check failed: ${JSON.stringify(health.body)}`);
    }
    console.log('  ✅ Health Check Passed');

    // 2. Farmer Login
    console.log('Test 2: Farmer Login with Sample Credentials');
    const farmerLogin = await request('/auth/login', {
      method: 'POST',
      body: { phone: '+1254700000001', password: 'Password123!' },
    });
    if (farmerLogin.status !== 200 || !farmerLogin.body.data.token) {
      throw new Error(`Farmer login failed: ${JSON.stringify(farmerLogin.body)}`);
    }
    farmerToken = farmerLogin.body.data.token;
    console.log('  ✅ Farmer Login Passed');

    // 3. Agent Login
    console.log('Test 3: Agent Login');
    const agentLogin = await request('/auth/login', {
      method: 'POST',
      body: { phone: '+1254700000002', password: 'Password123!' },
    });
    if (agentLogin.status !== 200 || !agentLogin.body.data.token) {
      throw new Error(`Agent login failed: ${JSON.stringify(agentLogin.body)}`);
    }
    agentToken = agentLogin.body.data.token;
    console.log('  ✅ Agent Login Passed');

    // 4. Duplicate Registration Rejection
    console.log('Test 4: Reject Duplicate Phone Registration');
    const dupReg = await request('/auth/register', {
      method: 'POST',
      body: {
        fullName: 'Duplicate User',
        phone: '+1254700000001',
        password: 'Password123!',
        role: 'FARMER',
      },
    });
    if (dupReg.status !== 409) {
      throw new Error(`Duplicate phone should return 409, got ${dupReg.status}`);
    }
    console.log('  ✅ Duplicate Phone Validation Passed');

    // 5. Create Crop Listing
    console.log('Test 5: Create Crop Listing');
    const cropRes = await request('/crops', {
      method: 'POST',
      headers: { Authorization: `Bearer ${farmerToken}` },
      body: {
        cropType: 'Organic Beans',
        quantityKg: 2500,
        unit: 'kg',
        askingPricePerKg: 110,
        location: 'Eldoret Grain Store',
        description: 'Fresh organic high-protein beans',
        harvestDate: new Date().toISOString(),
      },
    });
    if (cropRes.status !== 201 || !cropRes.body.data.id) {
      throw new Error(`Create crop failed: ${JSON.stringify(cropRes.body)}`);
    }
    testCropId = cropRes.body.data.id;
    console.log(`  ✅ Crop Listing Created (ID: ${testCropId})`);

    // 6. Create Transport Booking
    console.log('Test 6: Create Transport Booking');
    const bookingRes = await request('/bookings', {
      method: 'POST',
      headers: { Authorization: `Bearer ${farmerToken}` },
      body: {
        cropListingId: testCropId,
        pickupLocation: 'Eldoret Grain Store',
        destinationLocation: 'Nairobi Market Depot',
        estimatedWeight: 2500,
        requiredVehicleType: '3-Ton Pickup Truck',
        estimatedPrice: 18500,
      },
    });
    if (bookingRes.status !== 201 || !bookingRes.body.data.id) {
      throw new Error(`Create booking failed: ${JSON.stringify(bookingRes.body)}`);
    }
    testBookingId = bookingRes.body.data.id;
    console.log(`  ✅ Transport Booking Created (ID: ${testBookingId})`);

    // 7. Get Crops & Bookings List
    console.log('Test 7: Fetch Crops and Bookings');
    const getCropsRes = await request('/crops', {
      headers: { Authorization: `Bearer ${farmerToken}` },
    });
    if (getCropsRes.status !== 200 || !Array.isArray(getCropsRes.body.data)) {
      throw new Error(`Get crops failed: ${JSON.stringify(getCropsRes.body)}`);
    }
    console.log(`  ✅ Crops Listed (${getCropsRes.body.data.length} crops found)`);

    console.log('\n🎉 ALL BACKEND AUTOMATED TESTS PASSED SUCCESSFULLY!');
  } catch (err) {
    console.error('\n❌ TEST FAILED:', err);
    process.exitCode = 1;
  } finally {
    server.close();
  }
}

runTests();
