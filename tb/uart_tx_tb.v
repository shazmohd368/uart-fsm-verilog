`timescale 1ns/1ps

module uart_tx_tb;

    reg clk;
    reg reset;
    reg tx_start;
    reg [7:0] tx_data;
    wire tx;
    wire tx_busy;

    uart_tx uut (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // Clock generation: 50 MHz
    always #10 clk = ~clk;

    initial begin
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, uart_tx_tb);

        clk = 0;
        reset = 1;
        tx_start = 0;
        tx_data = 8'h00;

        #100;
        reset = 0;

        #100;
        tx_data = 8'hA5;
        tx_start = 1;
        #20;
        tx_start = 0;

        wait (tx_busy == 0);

        #2000000;
        $finish;
    end

endmodule
