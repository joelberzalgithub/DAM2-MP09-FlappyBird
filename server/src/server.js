const logger = require('./logger/logger');
const wSocket = require('ws');
const http = require('http');
const app = require('./app');
const Room = require('./classes/room');
const Player = require('./classes/player');
const messages = require('./socketMessages');

process.on('SIGTERM', shutDown);
process.on('SIGINT', shutDown);

function shutDown() {
    logger.info('Received kill signal, shutting down gracefully');
    server.close();
    process.exit(1);
}

const server = http.createServer(app);
const ws = new wSocket.Server({ server });

ws.on('connection', (socket) => {
    const playerId = socket._socket.remoteAddress + ':' + socket._socket.remotePort;
    logger.info(`New connection: ${playerId}`);
    messages.sendSalutation(socket, playerId);

    socket.on('message', async (message) => {
        const messageData = JSON.parse(message);

        if (messageData.type === 'join') messages.handleJoinMessage(socket, playerId, messageData);
        if (messageData.type === 'alive') messages.handleAliveMessage(messageData, playerId);
        if (messageData.type === 'dead') messages.handleDeadMessage(messageData, playerId);
    });
});

const port = process.env.PORT || 8888;
server.listen(port, () => {
    const address = server.address();
    const fullUrl = `http://${address.address}:${address.port}`;
    logger.info(`Server listening on ${fullUrl}`);
});



