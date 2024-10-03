# Use the official Node.js image.
FROM node:20.17.0

# Set the working directory inside the container.
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (or yarn.lock) to the working directory.
COPY package*.json ./

# Install dependencies.
RUN npm install

# Copy the rest of the application code to the working directory.
COPY . .

# Expose the port that your application will run on.
EXPOSE 80

# Start the application.
CMD ["npm", "start"]
