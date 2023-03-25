const express = require("express");
const http = require("http");
const mongoose = require("mongoose");
const dotenv = require("dotenv").config({
  path: "./config.env",
});
const Game = require("./models/gameModel");
const getSentence = require("./api/getSentence");

const app = express();
var server = http.createServer(app);

var io = require("socket.io")(server);

app.use(express.json());

mongoose
  .connect(process.env.MONGODB_URL)
  .then(() => {
    console.log("Connected To DB");
  })
  .catch((e) => {
    console.log(e);
  });

io.on("connection", (socket) => {
  console.log(socket.id);

  socket.on("create-game", async ({ nickname }) => {
    try {
      let game = new Game();
      const sentence = await getSentence();
      game.words = sentence;

      let player = {
        socketId: socket.id,
        nickname,
        isPartyLeader: true,
      };

      game.players.push(player);
      game = await game.save();

      const gameId = game._id.toString();

      socket.join(gameId);

      io.to(gameId).emit("updateGame", game);
    } catch (e) {
      console.log(e);
    }
  });

  socket.on("join-game", async ({ nickname, gameId }) => {
    try {
      if (!gameId.match(/^[0-9a-fA-F]{24}$/)) {
        socket.emit("notCorrectGame", "Please enter a valid game Id");
        return;
      }

      let game = await Game.findById(gameId);

      if (game.isJoin) {
        const id = game._id.toString();
        let player = {
          nickname,
          socketId: socket.id,
        };
        socket.join(id);
        game.players.push(player);
        game = await game.save();
        io.to(gameId).emit("updateGame", game);
      } else {
        socket.emit(
          "notCorrectGame",
          "The game is in progress, Please try agian later!"
        );
      }
    } catch (e) {
      console.log(e);
    }
  });

  socket.on("userInput", async ({ userInput, gameId }) => {
    let game = await Game.findById(gameId);
    if (!game.isJoin && !game.isOver) {
      let player = game.players.find((player) => player.socketId === socket.id);
      if (game.words[player.currentWordIndex] === userInput.trim()) {
        player.currentWordIndex = player.currentWordIndex + 1;
        if (player.currentWordIndex !== game.words.length) {
          game = await game.save();
          io.to(gameId).emit("updateGame", game);
        } else {
          let endTime = new Date().getTime();
          let { startTime } = game;
          player.WPM = calculateWPM(endTime, startTime, player);
          game = await game.save();
          socket.emit("done");
          io.to(gameId).emit("updateGame", game);
        }
      }
    }
  });

  // timer listener
  socket.on("timer", async ({ playerId, gameId }) => {
    let countDown = 5;
    let game = await Game.findById(gameId);
    let player = game.players.id(playerId);

    if (player.isPartyLeader) {
      let timerId = setInterval(async () => {
        if (countDown >= 0) {
          io.to(gameId).emit("timer", {
            countDown,
            msg: "Game Starting",
          });
          countDown--;
        } else {
          game.isJoin = false;
          game = await game.save();
          io.to(gameId).emit("updateGame", game);
          startGameClock(gameId);
          clearInterval(timerId);
        }
      }, 1000);
    }
  });
});

const startGameClock = async (gameId) => {
  let game = await Game.findById(gameId);
  game.startTime = new Date().getTime();
  game = await game.save();

  let time = 120;

  let timerId = setInterval(() => {
    if (time >= 0) {
      const timeFormat = calculateTime(time);
      io.to(gameId).emit("timer", {
        countDown: timeFormat,
        msg: "Time Remaning",
      });
      time--;
      console.log(time);
    } else {
      (async () => {
        try {
          let endTime = new Date().getTime();
          let game = await Game.findById(gameId);

          let { startTime } = game;
          game.isOver = true;
          game.players.forEach((player, index) => {
            if (player.WPM === -1) {
              game.players[index].WPM = calculateWPM(
                endTime,
                startTime,
                player
              );
            }
          });
          game = await game.save();
          io.to(gameId).emit("updateGame", game);
          clearInterval(timerId);
        } catch (e) {
          console.log(e);
        }
      })();
    }
  }, 1000);
};

function calculateTime(time) {
  let min = Math.floor(time / 60);
  let sec = time % 60;
  return `${min}:${sec < 10 ? "0" + sec : sec}`;
}

const calculateWPM = (endTime, startTime, player) => {
  const timeTakenInSec = (endTime - startTime) / 1000;
  const timeTaken = timeTakenInSec / 60;

  let wordsTyped = player.currentWordIndex;
  const WPM = Math.floor(wordsTyped / timeTaken);
  return WPM;
};

const port = process.env.PORT || 3000;
server.listen(port, "0.0.0.0", () => {
  console.log("Started Listening");
});
