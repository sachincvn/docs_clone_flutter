const mongooes = require('mongoose');

const documentSchema = new mongooes.Schema({
    uid: {
        type: String,
        required: true,
    },
    createdAt:{
        type: Number,
        required: true,
    },
    title:{
        type: String,
        required: true,
        trim: true,
    },
    content:{
        type: Array,
        default: [],
    }
});
const Document = mongooes.model("Document",documentSchema);
module.exports = Document;