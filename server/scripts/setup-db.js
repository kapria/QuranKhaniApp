const mongoose = require('mongoose');

async function setupDatabase() {
  console.log('Setting up MongoDB connection...\n');

  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✓ Connected to MongoDB');

    console.log('\nMongoDB collections will be created automatically by Mongoose.');
    console.log('Indexes are defined in the model schemas and will be created on first connection.');
    console.log('\nCollections:');
    console.log('  - profiles');
    console.log('  - khanis');
    console.log('  - para_assignments');
    console.log('  - sawab_details');
    console.log('\n✅ Database setup complete!');
  } catch (error) {
    console.error('❌ Setup failed:', error.message);
    console.log('\nPlease ensure MongoDB is running and MONGODB_URI is correct in .env');
    process.exit(1);
  } finally {
    await mongoose.disconnect();
  }
}

setupDatabase();
