# Use the build stage to compile any necessary code, run tests, etc.
FROM docker.io/library/node:18.18.2 as build
RUN mkdir /peer-server
WORKDIR /peer-server
COPY package.json package-lock.json ./
RUN npm clean-install
COPY . ./
RUN npm run build
RUN npm run test

# Use the production stage to set up the production environment.
FROM docker.io/library/node:18.18.2-alpine as production
WORKDIR /peer-server
COPY --from=build /peer-server .
COPY package.json package-lock.json ./
RUN npm clean-install --omit=dev

# Copy SSL certificates
# Make sure to replace './certs/privkey.pem' and './certs/fullchain.pem' with the paths to your actual SSL key and certificate files.
COPY ./certs/privkey.pem /peer-server/privkey.pem
COPY ./certs/fullchain.pem /peer-server/fullchain.pem

# Set up environment variables
ENV NODE_ENV=production
ENV PORT=9000
# Set environment variables for SSL key and cert
ENV SSL_KEY_PATH="/peer-server/privkey.pem"
ENV SSL_CERT_PATH="/peer-server/fullchain.pem"

# Expose the port the app runs on
EXPOSE ${PORT}

# Start the application with SSL options
CMD ["node", "peerjs.js", "--port", "${PORT}", "--sslkey", "${SSL_KEY_PATH}", "--sslcert", "${SSL_CERT_PATH}"]
