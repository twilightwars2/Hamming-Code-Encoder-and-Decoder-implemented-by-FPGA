module uart_test(
input wire CLK_50M, BTN_SOUTH, BTN_EAST,
input wire RS232_DCE_RXD,
input wire ROT_CENTER,
output wire RS232_DCE_TXD,
output wire [7:0]LED,
output wire LCD_E, LCD_RS, LCD_RW,
output wire [7:0] LCD_DB

);

// signal declaration

wire tx_full, rx_empty, btn_tick;
wire [7:0] rec_data, rec_data1;


// body
// instantiate uart
uart uart_unit
(.clk(CLK_50M), .reset(BTN_SOUTH), .decode(BTN_EAST),
.rd_uart(btn_tick),.wr_uart(btn_tick), .rx(RS232_DCE_RXD), 
.w_data(rec_data1),.tx_full(tx_full), .rx_empty(rx_empty),
.r_data(rec_data), .tx(RS232_DCE_TXD), .get_data(LED), .LCD_E(LCD_E), .LCD_RS(LCD_RS), .LCD_RW(LCD_RW), .LCD_DB(LCD_DB));


// instantiate debounce circuit
debounce_explicit btn_db_unit
(.clk(CLK_50M), .reset(BTN_SOUTH), 
.sw(ROT_CENTER),.db_level(), .db_tick(btn_tick));




// incremented data loops back

assign rec_data1 = rec_data+1;



endmodule