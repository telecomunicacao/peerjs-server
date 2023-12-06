#!/bin/bash

#docker run -p 9000:9000 -d peerjs/peerjs-server

#docker build -t my-peerjs-app .



docker run -p 9000:9000 \
	    -v certs:/peer-server/certs \
	        --env NODE_ENV=production \
		    --env PORT=9000 \
		        --env SSL_KEY_PATH="./certs/privkey.pem" \
			    --env SSL_CERT_PATH="./certs/fullchain.pem" \
			        my-peerjs-app

