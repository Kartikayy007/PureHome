const WebSocket = require('ws');

const wss = new WebSocket.Server({ host: '0.0.0.0', port: 8080 });

const devices = [
    { id: 'room_living', basePM25: 15, basePM10: 30, baseCO2: 400, baseTemp: 22, baseHum: 45 },
    { id: 'room_bedroom', basePM25: 10, basePM10: 20, baseCO2: 450, baseTemp: 21, baseHum: 50 },
    { id: 'room_kitchen', basePM25: 45, basePM10: 60, baseCO2: 800, baseTemp: 24, baseHum: 55 }
];

let globalClients = new Set();

wss.on('connection', (ws) => {
    globalClients.add(ws);
    ws.on('close', () => globalClients.delete(ws));
});

function randomOffset(base, maxVariance) {
    return base + (Math.random() * maxVariance * 2 - maxVariance);
}

setInterval(() => {
    const timestamp = new Date().toISOString();
    devices.forEach((device) => {
        const pm2_5 = Math.max(0, Math.round(randomOffset(device.basePM25, 20)));
        const pm10 = Math.max(0, Math.round(randomOffset(device.basePM10, 30)));
        const co2 = Math.max(400, Math.round(randomOffset(device.baseCO2, 200)));
        const temperature = Math.round(randomOffset(device.baseTemp, 2) * 10) / 10;
        const humidity = Math.round(randomOffset(device.baseHum, 5));
        
        let status = 'online';
        if (Math.random() < 0.05) {
            status = 'offline';
        }

        const reading = {
            device_id: device.id,
            pm2_5: pm2_5,
            pm10: pm10,
            co2: co2,
            temperature: temperature,
            humidity: humidity,
            timestamp: timestamp,
            status: status
        };

        const jsonString = JSON.stringify(reading);
        for (let client of globalClients) {
            if (client.readyState === WebSocket.OPEN) {
                client.send(jsonString);
            }
        }
    });
}, 10000);
