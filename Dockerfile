# Use the build stage to compile any necessary code, run tests, etc.
FROM docker.io/library/node:18.18.2 as build
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

# Assuming 'npm run build' puts 'peerjs.js' inside '/peer-server/dist/bin/'
# Correctly copy 'peerjs.js' to '/peer-server'
COPY --from=build /peer-server/dist/bin/peerjs.js ./peerjs.js

# Proceed with other commands
COPY package.json package-lock.json ./
RUN npm clean-install --omit=dev

# Copy SSL certificates
COPY ./certs/privkey.pem ./privkey.pem
COPY ./certs/fullchain.pem ./fullchain.pem

# Set up environment variables
ENV NODE_ENV=production
ENV PORT=9000
ENV SSL_KEY_PATH="/peer-server/privkey.pem"
ENV SSL_CERT_PATH="/peer-server/fullchain.pem"

# Expose the port the app runs on
EXPOSE ${PORT}

# Start the application with SSL options
CMD node peerjs.js --port ${PORT} --sslkey ${SSL_KEY_PATH} --sslcert ${SSL_CERT_PATH}
