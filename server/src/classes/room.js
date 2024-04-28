const logger = require('../logger/logger');
const { OPEN } = require('ws')
const Match = require('./match');

class Room {
    constructor(id) {
        this.id = id;
        this.players = [];
        this.timer = null;
        this.timeout = 3000;
        this.match = null;
    }

    /**
     * Function to add a new player to the room.
     * 
     * First checks if the room is joinable by asserting that the timer is null and the 
     * player count is less than 4.
     * If the room is joinable, the player is added. 
     * Then all the players in the room are notified of the new player.
     * If the player count is 3 before adding the player the match starts.
     * 
     * @param {
     * } player 
     * @returns 
     */
    addPlayer(player) {
        const playerCount = this.players.length;
        if (this.timer !== null || playerCount >= 4) {
            logger.warn(`Failed to add ${player.id} in room: ${this.id}`);
            return;
        }

        this.players.push(player);
        this.players.forEach((p) => {
            const bMessage = JSON.stringify(
                {
                    type: 'player',
                    value: p.id,
                    name: p.nickname
                }
            );
            this.broadcast(bMessage);
        });
        const pMessage = JSON.stringify(
            {
                type: 'joined',
                value: player.id,
                room: this.id,
                name: player.nickname
            }
        );
        player.socket.send(pMessage);
        logger.info(`${player.id} joined room ${this.id}`);

        if (playerCount >= 3) {
            logger.info(`4 players joined room ${this.id}, match starting...`);
            this.startMatch();
        }
    }

    /**
     * Function to return the player list.
     * 
     * @returns 
     */
    getPlayers() {
        return this.players;
    }

    /**
     * Function to get an specific player.
     * 
     * @param {*} playerId 
     * @returns 
     */
    getPlayer(playerId) {
        const player = this.players.find((player) => {return player.id === playerId});
        return player;
    }

    /**
     * Function to remove a player from the list.
     * 
     * If a player with the given id is found, it is filtered out of the player list.
     * If the player list length becomes 0 the match is stoped.
     * 
     * @param {*} playerId 
     */
    removePlayer(playerId) {
        const player = this.getPlayer(playerId);
        this.players = this.players.filter(p => p !== player);

        if (this.players.length === 0) {
            this.match.stop();
        }
    }

    /**
     * Function to check if a player exists in the room.
     * 
     * It searches for the player in the player array. If found returns true.
     * Else it returns false.
     * 
     * @param {*} playerId 
     * @returns 
     */
    hasPlayer(playerId) {
        var hasPlayer = false;
        this.players.forEach((player) => {
            if (player.id === playerId) hasPlayer = true;
        });
        return hasPlayer;
    }

    /**
     * Function to send a message to all the players.
     * 
     * Sends a message to all the players with a socket in the ready state.
     * 
     * @param {*} message 
     */
    broadcast(message) {
        this.players.forEach((player) => {
            const playerSocket = player.socket;
            if (playerSocket.readyState === OPEN) {
                playerSocket.send(message);
            }
        });
    }

    /**
     * Function to send a message to all the players except one.
     * 
     * Sends a message to all the players with a socket in the ready state. And different
     * to the given one.
     * 
     * @param {*} message 
     * @param {*} p 
     */
    broadcastOthers(message, p) {
        this.players.forEach((player) => {
            const playerSocket = player.socket;
            if (playerSocket.readyState === OPEN && player !== p) {
                playerSocket.send(message);
            }
        });
    }

    /**
     * Function to start the match associated with the room.
     * 
     * First broadcasts the start message after a certain timeout.
     * Then a new match instance is created and started.
     * 
     */
    startMatch() {
        this.timer = setTimeout(() => {
            const message = JSON.stringify(
                {
                    type: 'start',
                    message: 'the match is starting soon'
                }
            );
            this.broadcast(message);
        }, this.timeout);

        this.match = new Match(this.id, this);
        this.match.start();
    }

    /**
     * Function to handle the box spawn of the match,
     * 
     * It randomly calculates the next obstacle of the match.
     * Then broadcasts it to the players.
     * 
     */
    spawnBox() {
        const isBottom = Math.random() * 100 > 50;
        const maxStackHeight = 4;
        const stackHeight = Math.floor(Math.random() * (maxStackHeight + 1));

        this.broadcast(JSON.stringify(
            {
                type: 'box',
                isBottom: isBottom,
                height: stackHeight
            }
        ));
    }

    /**
     * Function to stop the match.
     * 
     * It stops the associated match.
     * 
     */
    stopMatch() {
        this.match.stop();
    }
}

module.exports = Room;