const logger = require('../logger/logger');

class Match {
    constructor(id, room) {
        this.id = id;
        this.room = room;
        this.ellapsedTime = 0;
        this.targetTime = 1;
        this.isRunning = false;
        this.updateInterval = 2;
    }

    async start() {
        this.isRunning = true;
        this.gameLoop();
    }

    async gameLoop() {
        if (!this.isRunning) return;

        this.update();
        setTimeout(() => this.gameLoop(), this.updateInterval);
    }

    update() {
        this.ellapsedTime += this.updateInterval / 1000; 

        if (this.ellapsedTime >= this.targetTime) {
            this.ellapsedTime = 0;

            if (this.targetTime >= 0.05) {
                this.targetTime = this.targetTime * 0.95;
            }

            this.room.spawnBox();
        }
    }

    stop() {
        this.isRunning = false;
    }
}

module.exports = Match;
