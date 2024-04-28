const Player = require('./classes/player');
const Room = require('./classes/room');
const logger = require('./logger/logger');

let rooms = [];

/**
 * Function to handle the socket connection message.
 * 
 * It sends a message to the connected socket to inform of the successfull connection.
 * 
 * @param {*} socket 
 * @param {*} id 
 */
async function sendSalutation(socket, id) {
    socket.send(JSON.stringify(
        {
            type: 'salutation',
            value: 'connection success',
            id: `${id}`
        }
    ));
}

/**
 * Function to handle the socket join message.
 * 
 * First uses the message data to create a new Player class instance.
 * Then it looks for a room to assign the player to.
 * If no room is found, a new one is created with the player id.
 * 
 * @param {*} socket 
 * @param {*} id 
 * @param {*} message 
 */
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

/**
 * Function to handle the alive socket message.
 * 
 * First looks for a room with a player that has the given playerId.
 * If found it broadcasts the players position to the other players.
 * 
 * @param {*} message 
 * @param {*} playerId 
 * @returns 
 */
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

/**
 * Function to handle the dead socket message.
 * 
 * First looks for a room with a player that has the given playerId.
 * If found it broadcasts that the player died to the other players.
 * Then removes the player from the room.
 * If the room happens to become empty after removing the player it is deleted.
 * 
 * @param {*} message 
 * @param {*} playerId 
 * @returns 
 */
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