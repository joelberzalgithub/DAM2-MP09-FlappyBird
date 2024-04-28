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

    /**
     * Function to start the match game loop.
     * 
     * Sets the its running variable to true and starts the loop.
     * 
     */
    async start() {
        this.isRunning = true;
        this.gameLoop();
    }

    /**
     * Function that handles the game loop.
     * 
     * Every time its called it checks if itsRunning is true.
     * If true it calls for an update, and then calls itself again after a timeout.
     * 
     * @returns 
     */
    async gameLoop() {
        if (!this.isRunning) return;

        this.update();
        setTimeout(() => this.gameLoop(), this.updateInterval);
    }

    /**
     * Function that handles the update logic.
     * 
     * First updates the ellapsedTime.
     * Then if the ellapsed time is bigger or equal to the target time it spawns a box
     * and reduces the target time.
     */
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

    /**
     * Function to set isRunning to false.
     * 
     * It sets the isRunning variable to false.
     * 
     */
    stop() {
        this.isRunning = false;
    }
}

module.exports = Match;
