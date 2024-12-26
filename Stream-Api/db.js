const mongoose = require('mongoose');

// MongoDB Atlas connection string
const connectDB = async () => {
  try {
    await mongoose.connect('mongodb+srv://Cluster59727:b3NNRG9QSkRY@cluster59727.gejn6.mongodb.net/crypto_scope', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('MongoDB connected');
  } catch (err) {
    console.error('Error connecting to MongoDB:', err);
    process.exit(1);
  }
};

module.exports = connectDB;
