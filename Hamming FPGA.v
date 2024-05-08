module Hamming_FPGA

(
input wire CLK_50M, BTN_WEST,
//input wire  BTN,
input wire [3:0] SW,
output wire [6:0] LED
);
//wire  db_btn;
/* debounce circuit for btn[0]:east:read
debounce_explicit btn_db_unit0
(.clk(CLK_50M), .reset(BTN_SOUTH), .sw(BTN),
.db_level(), .db_tick(db_btn));
debounce circuit for btn[1]:west:write
debounce_explicit btn_db_unit1
(.clk(CLK_50M), .reset(BTN_SOUTH), .sw(BTN[1]),
.db_level(), .db_tick(db_btn[1]));*/


// instantiate a 2^2-by-4 fifo
encoder encoder_unit
(.clk(CLK_50M), .encode(BTN_WEST),
 .en_in(SW),
.en_out(LED[6:0]));


endmodule