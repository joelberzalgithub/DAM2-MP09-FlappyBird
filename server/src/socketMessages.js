const Player = require('./classes/player');
const Room = require('./classes/room');
const logger = require('./logger/logger');

let rooms = [];
async function sendSalutation(socket, id) {
    socket.send(JSON.stringify(
        {
            type: 'salutation',
            value: 'connection success',
            id: `${id}`
        }
    ));
}

async function handleJoinMessage(socket, id, message) {
    var player = new Player(socket, message.nickname, id);
    var room = await rooms.find((room) => { return room.players.length < 4 && room.timer === null });
    if (!room || room === null) {
        logger.info(`No valid room found, creating one with id ${id}`);
        room = new Room(id);
        rooms.push(room);
    }
    console.log(message);
    room.addPlayer(player);
}

async function handleAliveMessage(message, playerId) {
    const room = await rooms.find((room) => {
        return room.hasPlayer(playerId);
    });

    if (!room || room === null) {
        logger.error(`Received alive message from ${playerId}, but couldn't find the target room`);
        return;
    }

    room.broadcast(JSON.stringify(
        {
            type: 'move',
            id: `${playerId}`,
            x: message.x,
            y: message.y,
            score: message.score
        }
    ));
}

async function handleDeadMessage(message, playerId) {
    const room = await rooms.find((room) => {
        return room.hasPlayer(playerId);
    });

    if (!room || room === null) {
        logger.error(`Received dead message from ${playerId}, but couldn't find the target room`);
        return;
    }

    room.broadcast(JSON.stringify(
        {
            type: 'dead',
            id: `${playerId}`,
        }
    ));
    await room.removePlayer(playerId);
    if (room.players.length === 0) {
        logger.warn(`The room ${room.id} is empty, clearing it...`);
        rooms = rooms.filter(r => r.id !== room.id);
    }
    
}

module.exports = {
    handleAliveMessage,
    handleDeadMessage,
    handleJoinMessage,
    sendSalutation
}