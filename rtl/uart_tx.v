// UART Transmitter (FSM-based)
// 8 data bits, 1 start bit, 1 stop bit, no parity
// Simulation-oriented, synthesizable RTL

module uart_tx (
    input  wire       clk,
    input  wire       reset,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output reg        tx,
    output reg        tx_busy
);

    // UART parameters (can be changed for simulation)
    parameter CLOCK_FREQ = 50_000_000;
    parameter BAUD_RATE  = 9600;
    localparam BAUD_TICK = CLOCK_FREQ / BAUD_RATE;

    // FSM states
    localparam IDLE  = 2'b00,
               START = 2'b01,
               DATA  = 2'b10,
               STOP  = 2'b11;

    reg [1:0] state;
    reg [12:0] baud_cnt;
    reg [2:0] bit_index;
    reg [7:0] tx_shift;

    // State register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state      <= IDLE;
            baud_cnt  <= 0;
            bit_index <= 0;
            tx_shift  <= 0;
            tx        <= 1'b1;
            tx_busy   <= 1'b0;
        end else begin
            case (state)

                IDLE: begin
                    tx <= 1'b1;
                    tx_busy <= 1'b0;
                    if (tx_start) begin
                        tx_shift <= tx_data;
                        state <= START;
                        baud_cnt <= 0;
                        tx_busy <= 1'b1;
                    end
                end

                START: begin
                    tx <= 1'b0;
                    if (baud_cnt == BAUD_TICK - 1) begin
                        baud_cnt <= 0;
                        state <= DATA;
                        bit_index <= 0;
                    end else
                        baud_cnt <= baud_cnt + 1;
                end

                DATA: begin
                    tx <= tx_shift[bit_index];
                    if (baud_cnt == BAUD_TICK - 1) begin
                        baud_cnt <= 0;
                        if (bit_index == 7)
                            state <= STOP;
                        else
                            bit_index <= bit_index + 1;
                    end else
                        baud_cnt <= baud_cnt + 1;
                end

                STOP: begin
                    tx <= 1'b1;
                    if (baud_cnt == BAUD_TICK - 1) begin
                        baud_cnt <= 0;
                        state <= IDLE;
                    end else
                        baud_cnt <= baud_cnt + 1;
                end

            endcase
        end
    end

endmodule
