const { io } = require("../index.js");
const Bands = require("../models/bands.js");
const Band = require("../models/band.js");

const bands = new Bands();
console.log("Init Server");

bands.addBand(new Band("Los Mojarras"));
bands.addBand(new Band("Cuchillazo"));
bands.addBand(new Band("Arena Hash"));
bands.addBand(new Band("Los Enanitos Verdes"));

console.log(bands);

//Socket Messages
io.on("connection", (client) => {
  console.log("Cliente Conectado");
  client.emit("active-bands", bands.getBands());

  client.on("disconnect", () => {
    console.log("Cliente Desconectado");
  });
  client.on("mensaje", (payload) => {
    console.log("Mensaje", payload);

    io.emit("mensaje2", { admin: "Mensaje desde el servidor" });
  });

  client.on("emitir-mensaje", (payload) => {
    client.broadcast.emit("nuevo-mensaje", payload);
  });

  client.on("add-vote", (payload) => {
    bands.voteBand(payload["id"]);
    io.emit("active-bands", bands.getBands());
  });

  client.on("add-band", (payload) => {
    const newBand = new Band(payload["name"]);
    bands.addBand(newBand);
    io.emit("active-bands", bands.getBands());
  });

  client.on("erase-band", (payload) => {
    console.log("band erased");
    bands.addBand(payload["id"]);
  });
});
