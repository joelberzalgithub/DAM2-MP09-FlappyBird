const logger = require('../logger/logger');

class Player {
    constructor(socket, nickname, id) {
        this.nickname = nickname;
        this.socket = socket
        this.id = id;
    }
}

module.exports = Player;