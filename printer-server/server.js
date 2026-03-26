const express = require('express');
const cors = require('cors');
const escpos = require('escpos');
const Network = require('escpos-network');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());

const PORT = process.env.PORT || 5000;
const KOT_IP = process.env.KOT_PRINTER_IP;
const BILL_IP = process.env.BILL_PRINTER_IP;

app.post('/print/kot', async (req, res) => {
    const order = req.body;
    if (!KOT_IP) {
        console.error("Printer IP not configured: KOT_PRINTER_IP");
        return res.status(400).send({ error: "Printer IP not configured" });
    }

    try {
        const device = new Network(KOT_IP, 9100);
        const printer = new escpos.Printer(device);

        device.open((err) => {
            if (err) {
                console.error("KOT Printer connection error:", err);
                return res.status(500).send({ error: "Printer connection error" });
            }

            printer
                .font('a')
                .align('ct')
                .style('bu')
                .size(1, 1)
                .text('KOT')
                .text(`Order #: ${order.orderNumber || 'N/A'}`)
                .text('--------------------------------')
                .align('lt');

            order.items.forEach(item => {
                printer.text(`${item.product_name || item.product?.name || 'Item'} x ${item.quantity}`);
            });

            printer
                .text('--------------------------------')
                .text(`Type: ${order.orderType || 'N/A'}`)
                .text(`Date: ${new Date().toLocaleString()}`)
                .cut()
                .close();
            
            res.status(200).send({ message: "KOT printed successfully" });
        });
    } catch (error) {
        console.error("KOT Printing failed:", error);
        res.status(500).send({ error: "KOT printing failed" });
    }
});

app.post('/print/bill', async (req, res) => {
    const order = req.body;
    if (!BILL_IP) {
        console.error("Printer IP not configured: BILL_PRINTER_IP");
        return res.status(400).send({ error: "Printer IP not configured" });
    }

    try {
        const device = new Network(BILL_IP, 9100);
        const printer = new escpos.Printer(device);

        device.open((err) => {
            if (err) {
                console.error("Bill Printer connection error:", err);
                return res.status(500).send({ error: "Printer connection error" });
            }

            printer
                .font('a')
                .align('ct')
                .size(1, 1)
                .text('BILL')
                .text(`Order #: ${order.orderNumber || 'N/A'}`)
                .text('--------------------------------')
                .align('lt');

            order.items.forEach(item => {
                const price = item.price || item.product?.price || 0;
                printer.text(`${item.product_name || item.product?.name || 'Item'} x ${item.quantity} - ${price * item.quantity}`);
            });

            printer
                .text('--------------------------------')
                .align('rt')
                .text(`Subtotal: ${order.subtotal || 0}`)
                .text(`Tax: ${order.taxAmount || 0}`)
                .text(`Discount: ${order.discountAmount || 0}`)
                .text(`Total: ${order.total || 0}`)
                .align('ct')
                .text('Thank you for your visit!')
                .cut()
                .close();
            
            res.status(200).send({ message: "Bill printed successfully" });
        });
    } catch (error) {
        console.error("Bill Printing failed:", error);
        res.status(500).send({ error: "Bill printing failed" });
    }
});

app.listen(PORT, () => {
    console.log(`Printer server listening at http://localhost:${PORT}`);
});
