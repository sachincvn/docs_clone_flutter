const express = require('express');
const mongoose = require('mongoose');
const authRouter = require('./routes/auth');
const cors = require('cors');
const documentRouter = require('./routes/document');
const http = require('http');
const Document = require('./models/document');
const mongoConnectionString = require('./config/cong');
const PORT = process.env.PORT | 3001;

const app = express()
var server = http.createServer(app);
var io = require('socket.io')(server);
app.use(cors());
app.use(express.json())
app.use(authRouter)
app.use(documentRouter)

const DB = mongoConnectionString;

mongoose.connect(DB).then(() =>{
    console.log("connection successfully");
}).catch((err)=>{
    console.log(err);
});


io.on('connection',(socket)=>{
    socket.on("join",(documentId) => {
        socket.join(documentId);
        console.log("Joined!");
    });

    socket.on("typing",(data) => {
        socket.broadcast.to(data.room).emit('changes',data);
    });

    socket.on("save",(data)=>{
        saveData(data);
    });
});


const saveData = async (data) =>{
    try {
        
    let document = await Document.findById(data.room);
    console.log(data.delta);
    document.content = data.delta;
    document = await document.save();
    } catch (error) {
        console.log(error.message);
    }
}
server.listen(PORT,"0.0.0.0", () => {
    console.log("running server at port 3001");
})