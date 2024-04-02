const WebSocket = require('ws');
const winston = require('winston');
const express = require('express');
const http = require('http');

const app = express();
const port = 8888;

app.get('/', getHello);
async function getHello(req, res) {
  res.send(`Hello World`);
}

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


const server = http.createServer(app);


process.on('SIGTERM', shutDown);
process.on('SIGINT', shutDown);
function shutDown() {
  logger.info('Received kill signal, shutting down gracefully');
  server.close();
  process.exit(0);
}


logger.info(`starting WebSocket service...`);
let currentRoom = 0;
const wss = new WebSocket.Server({ server });


const rooms = {};
wss.on('connection', (socket) => {
  	const id = socket._socket.remoteAddress + ':' + socket._socket.remotePort;
  	logger.info(`WebSocket client connected: ${id}`);

  	const leave = room => {
	  	if (!rooms[room][id]) return;
	  	if (Object.keys(rooms[room]).length === 1) {
        logger.info(`liberating room ${room}`);
	    	delete rooms[room];
        currentRoom = room;
	  	} else {
	    	delete rooms[room][id];
  		}
	}

 
  	socket.send(JSON.stringify({
  		type: `salutation`,
		value: `This WebSocket salutes you`,
		id: `${id}`
  	}));

  
  	socket.on('message', msg => {
    	logger.info(`New message from ${id}: ${msg}`);
      let data = JSON.parse(msg);
      const { type, value, room } = data;

      if (type === "join") {
        if (! rooms[currentRoom]) rooms[currentRoom] = {};
        if (! rooms[currentRoom][id]) rooms[currentRoom][id] = socket;
        broadcast(currentRoom, id, {
          type: `join`, value: `${id}`, name: `${room}`
        });
        socket.send(JSON.stringify({
          type: `joined`,
          value: `${id}`,
          room: `${currentRoom}`,
          name: `${room}`
        }));
        for (const property in rooms[currentRoom]) {
          socket.send(JSON.stringify({
          type: `player`,
          value: property,
        }));
        }
        if (Object.keys(rooms[currentRoom]).length >= 2) {
          //currentRoom++;
          setTimeout(() => {
            logger.warn('STARTING');
            broadcast(currentRoom, 'xd', {
              type: 'start'
            });
          }, 3000);
        };
      } else if (type === "leave") {
        leave(room);
      } else if (type === "alive") {
        broadcast(currentRoom, id, {
          type: 'move', id: `${id}`, x: data.x, y: data.y, score: data.score
        });
      } else if (type === 'dead') {
        // leave(currentRoom);
      } else if (! type) {
        // perhaps can be used?
      }

	});


  	socket.on('close', () => {
    	logger.info(`WebSocket client disconnected: ${id}`);
      Object.keys(rooms).forEach(room => leave(room));
	});
});


server.listen(port, () => {
  logger.info(`Example app listening on: http://localhost:${port}`);
});



const broadcast = (room, excludedId, message) => {
  if (!rooms[room]) return;

  Object.entries(rooms[room]).forEach(([id, socket]) => {
    if (id !== excludedId) {
      socket.send(JSON.stringify(message));
    }
  });
};





