const winston = require('winston');

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
      new winston.transports.File({ filename: './logs/error.log', level: 'error' }),
      new winston.transports.File({ filename: './logs/combined.log' }),
      new winston.transports.Console(),
    ],
  });

  module.exports = logger;