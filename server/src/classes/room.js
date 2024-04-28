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

        if (playerCount >= 1) {
            logger.info(`Atleast 2 players joined room ${this.id}, match starting...`);
            this.startMatch();
        }
    }

    getPlayers() {
        return this.players;
    }

    hasPlayer(playerId) {
        var hasPlayer = false;
        this.players.forEach((player) => {
            if (player.id === playerId) hasPlayer = true;
        });
        return hasPlayer;
    }

    broadcast(message) {
        this.players.forEach((player) => {
            const playerSocket = player.socket;
            if (playerSocket.readyState === OPEN) {
                playerSocket.send(message);
            }
        });
    }

    broadcastOthers(message, p) {
        this.players.forEach((player) => {
            const playerSocket = player.socket;
            if (playerSocket.readyState === OPEN && player !== p) {
                playerSocket.send(message);
            }
        });
    }

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
}

module.exports = Room;