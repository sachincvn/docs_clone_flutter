const jwt = require('jsonwebtoken');

const auth = async (req,res,next) => {
    try {
        const token = req.header("x-auth-token");
        if (!token) {
            return res.status(401).json({ msg: "Unauthorized, No auth token access denied"});
        }
        const verified = jwt.verify(token,"myKey");
        if (!verified) {
            return res.status(401).json({ msg: "Unauthorized, Invalid token access denied"});
        }
        req.user = verified.id;
        req.token = token;
        next();
    } catch (error) {
        return res.status(500).json({ error: error.message});
    }
} 

module.exports = auth