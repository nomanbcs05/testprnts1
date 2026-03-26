const express = require('express');
const cors = require('cors');
require('dotenv').config();
const { printKOT, printBill } = require('./printerService');

const app = express();
app.use(express.json());
app.use(cors());

const PORT = process.env.PORT || 5000;

app.post('/print/kot', async (req, res) => {
    try {
        const order = req.body;
        await printKOT(order);
        res.status(200).send({ message: 'KOT printed successfully' });
    } catch (error) {
        console.error('KOT Printing failed:', error);
        res.status(500).send({ error: 'KOT printing failed' });
    }
});

app.post('/print/bill', async (req, res) => {
    try {
        const order = req.body;
        await printBill(order);
        res.status(200).send({ message: 'Bill printed successfully' });
    } catch (error) {
        console.error('Bill Printing failed:', error);
        res.status(500).send({ error: 'Bill printing failed' });
    }
});

app.listen(PORT, () => {
    console.log(`Printer backend listening at http://localhost:${PORT}`);
});
