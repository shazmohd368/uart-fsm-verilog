`timescale 1ns/1ps

module uart_tx_tb;

    // Testbench signals
    reg clk;
    reg reset;
    reg tx_start;
    reg [7:0] tx_data;
    wire tx;
    wire tx_busy;

    // Instantiate UART TX
    uart_tx uut (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // Clock generation: 50 MHz (20 ns period)
    always #10 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        tx_start = 0;
        tx_data = 8'h00;

        // Hold reset
        #100;
        reset = 0;

        // Wait before transmission
        #100;

        // Send one byte: 0xA5 (10100101)
        tx_data = 8'hA5;
        tx_start = 1;
        #20;
        tx_start = 0;

        // Wait for transmission to complete
        wait (tx_busy == 0);

        // Finish simulation
        #200;
        $finish;
    end

endmodule
