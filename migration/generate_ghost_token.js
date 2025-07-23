const jwt = require('jsonwebtoken');

// Admin API key parts
const keyId = "687e137adb65b00001a55bbe";
const secret = "0d346b24dfa16f8dfe3b8a80acbd7475eeb205bd2957595fe5698b13a81048a5";

// Create JWT token
const iat = Math.floor(Date.now() / 1000);
const payload = {
    iat: iat,
    exp: iat + 300,  // 5 minutes
    aud: "/admin/"
};

// Convert hex secret to buffer
const secretBuffer = Buffer.from(secret, 'hex');

// Generate token
const token = jwt.sign(payload, secretBuffer, {
    algorithm: 'HS256',
    header: {
        alg: 'HS256',
        typ: 'JWT',
        kid: keyId
    }
});

console.log(token);