const escpos = require('escpos');
const Network = require('escpos-network');
require('dotenv').config();

const KOT_IP = process.env.KOT_PRINTER_IP;
const BILL_IP = process.env.BILL_PRINTER_IP;

const printKOT = async (order) => {
    if (!KOT_IP) {
        console.error("Printer IP not configured");
        return;
    }

    try {
        const device = new Network(KOT_IP, 9100);
        const printer = new escpos.Printer(device);

        device.open((err) => {
            if (err) {
                console.error("KOT Printer connection error:", err);
                return;
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
                printer.text(`${item.product_name || item.product.name} x ${item.quantity}`);
            });

            printer
                .text('--------------------------------')
                .text(`Type: ${order.orderType || 'N/A'}`)
                .text(`Date: ${new Date().toLocaleString()}`)
                .cut()
                .close();
        });
    } catch (error) {
        console.error("KOT Printing failed:", error);
    }
};

const printBill = async (order) => {
    if (!BILL_IP) {
        console.error("Printer IP not configured");
        return;
    }

    try {
        const device = new Network(BILL_IP, 9100);
        const printer = new escpos.Printer(device);

        device.open((err) => {
            if (err) {
                console.error("Bill Printer connection error:", err);
                return;
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
                const price = item.price || item.product.price;
                printer.text(`${item.product_name || item.product.name} x ${item.quantity} - ${price * item.quantity}`);
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
        });
    } catch (error) {
        console.error("Bill Printing failed:", error);
    }
};

module.exports = {
    printKOT,
    printBill
};
