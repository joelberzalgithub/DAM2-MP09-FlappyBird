const WebSocket = require('ws');
const winston = require('winston');
const express = require('express');
const http = require('http');

const app = express();
const port = 3000;

// Address settings ‘/’
app.get('/', getHello);
async function getHello(req, res) {
  res.send(`Hello World`);
}

// logger settings
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.printf(({ level, message, timestamp }) => {
      let levelColor, timestampColor;
      switch (level) {
        case 'info':
          levelColor = '\x1b[36m'; // cyan
          break;
        case 'warn':
          levelColor = '\x1b[33m'; // yellow
          break;
        case 'error':
          levelColor = '\x1b[31m'; // red
          break;
        case 'debug':
          levelColor = '\x1b[32m'; // green
          break;
        default:
          levelColor = '\x1b[37m'; // white
      }
      timestampColor = '\x1b[35m'; // purple
      return `${timestampColor}[${timestamp}]${levelColor} [${level.toUpperCase()}]: \x1b[37m${message}\x1b[0m`;
    })
  ),
  defaultMeta: { service: 'user-service' },
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
    new winston.transports.Console(),
  ],
});
logger.info(`logger started`);

// Create an HTTP server
const server = http.createServer(app);

// Properly shutdown the server
process.on('SIGTERM', shutDown);
process.on('SIGINT', shutDown);
function shutDown() {
  logger.info('Received kill signal, shutting down gracefully');
  server.close();
  process.exit(0);
}

// WebSocket initialization
logger.info(`starting WebSocket service...`);
const wss = new WebSocket.Server({ server });

// on socket connection
wss.on('connection', (socket) => {
  const id = socket._socket.remoteAddress + ':' + socket._socket.remotePort;
  logger.info(`WebSocket client connected: ${id}`);

  // Send a salutation message
  socket.send(JSON.stringify({
    type: `salutation`,
    value: `This WebSocket salutes you`,
    id: `${id}`
  }));

  // on socket message
  socket.on('message', (msg) => {
    logger.info(`New message from ${id}: ${msg}`);
  });

  // on socket close
  socket.on('close', () => {
    logger.info(`WebSocket client disconnected: ${id}`);
  });
});

// Run the server
server.listen(port, () => {
  logger.info(`Example app listening on: http://localhost:${port}`);
});
