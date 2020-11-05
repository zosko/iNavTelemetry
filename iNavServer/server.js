var express = require("express");
var app = express();
var http = require("http");
var server = http.createServer(app);
var io = require("socket.io").listen(server);
var path = require('path');
var database = {};

server.listen(3000);
app.use(express.static(path.join(__dirname, 'public')))
app.get('/', function(req, res){
  res.sendFile('public/index.html', { root : __dirname })
})

app.get('/restart', function(req, res){
  database = {};
  res.sendFile('public/index.html', { root : __dirname })
})

io.sockets.on("connection", function(socket) {
  database["rcPlace_1"] = {lat:41.985904,lng:21.486492,alt:0,speed:0,heading:0,photo:"",name:"B1",type:0};
  database["rcPlace_2"] = {lat:41.976906,lng:21.503710,alt:0,speed:0,heading:0,photo:"",name:"B2",type:0};
  database["rcPlace_3"] = {lat:42.060316,lng:21.384396,alt:0,speed:0,heading:0,photo:"",name:"Stenkovec",type:0};
  database["rcPlace_4"] = {lat:41.915790,lng:21.487247,alt:0,speed:0,heading:0,photo:"",name:"Piramida",type:0};
 
  setInterval(function(){ 
    var planes = Object.keys(database).map(key => database[key]);
    socket.emit("planesLocation", planes); 
  }, 2000);
  
  //send to everyone -> io.sockets.emit('planes',plane);
  //send to everyone except for sender -> socket.broadcast.emit('planes',plane); 
  
  // socket.id
  // socket.username
  // socket.roomnum
  
  socket.on("planeLocation", function(plane) {
    database[socket.id] = {lat : plane.lat,
                           lng : plane.lng,
                           alt : plane.alt,
                           speed : plane.speed,
                           heading : plane.heading,
                           photo : plane.photo,
                           type : 1, // type 0 - RCPlace, type 1 - Plane
                           name: plane.name
                          };
  });
  socket.on("disconnect", function() {
    //remove plane from database
    delete database[socket.id];
  });
});

