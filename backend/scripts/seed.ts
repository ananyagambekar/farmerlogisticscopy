import { store } from '../src/services/store';

async function main() {
  console.log('🌱 Starting Dynamic Agri-Logistics database seeding...');
  await store.seedInitialData();
  console.log('✅ Seed completed successfully:');
  console.log(` - Users: ${store.users.size}`);
  console.log(` - Crops: ${store.crops.size}`);
  console.log(` - Bookings: ${store.bookings.size}`);
  console.log(` - Vehicles: ${store.vehicles.size}`);
  console.log(` - Trips: ${store.trips.size}`);
  console.log(` - Configs: ${store.configs.size}`);
}

main().catch((err) => {
  console.error('❌ Seed failed:', err);
  process.exit(1);
});
