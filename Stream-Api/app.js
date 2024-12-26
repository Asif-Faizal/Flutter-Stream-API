const express = require('express');
const bodyParser = require('body-parser');
const User = require('./models/User');
const connectDB = require('./db'); // Import the MongoDB connection function

const app = express();
const port = 3000;

// Middleware to parse JSON bodies
app.use(bodyParser.json());

// Connect to MongoDB before starting the server
const startServer = async () => {
  try {
    await connectDB(); // Ensure DB connection is established before starting the server
    console.log('MongoDB connected');
    
    // Stream Users Endpoint (using MongoDB Change Streams)
    app.get('/stream-users', async (req, res) => {
      res.setHeader('Content-Type', 'application/json');
      res.setHeader('Cache-Control', 'no-cache');
      res.setHeader('Connection', 'keep-alive');

      try {
        // Fetch the entire list of users initially and send to the client
        const users = await User.find(); // Get all users
        console.log('Sending full list of users:', users);

        // Send the full list of users to the client right at the start
        res.write(`data: ${JSON.stringify(users)}\n\n`);

        // Open a change stream on the "users" collection to listen for new users
        const changeStream = User.watch(); // Watch for changes in the 'users' collection

        // Listen for 'insert' events and send the full list of users to the client
        changeStream.on('change', async (change) => {
          if (change.operationType === 'insert') {
            // Fetch the entire list of users after each insert
            const updatedUsers = await User.find(); // Get all users

            console.log('New user added, sending full user list:', updatedUsers);

            // Send the updated full list of users to the client
            res.write(`data: ${JSON.stringify(updatedUsers)}\n\n`);
          }
        });

        // This will keep the connection open and stream the events until the client closes the connection
      } catch (error) {
        console.error('Error streaming users:', error);
        res.status(500).send('Error streaming users');
      }
    });

    // Add User Endpoint
    app.post('/add-user', async (req, res) => {
      const { name, email } = req.body;

      if (!name || !email) {
        return res.status(400).send('Name and email are required');
      }

      try {
        const newUser = new User({ name, email });
        await newUser.save();
        res.status(201).json({ message: 'User added successfully', user: newUser });
      } catch (error) {
        console.error('Error adding user:', error);
        res.status(500).send('Error adding user');
      }
    });

    // Start the server after DB connection is established
    app.listen(port, () => {
      console.log(`Server is running at http://localhost:${port}`);
    });
    
  } catch (error) {
    console.error('Error connecting to MongoDB:', error);
    process.exit(1); // Exit if MongoDB connection fails
  }
};

// Call the function to start the server
startServer();
