// Listing 4.20
module fifo
   #(
    parameter B=8, // number of bits in a word
              W=10  // number of address bits
   )
   (
    input wire clk, reset,
    input wire rd, wr,
    input wire [B-1:0] w_data,
    output wire empty, full,
    output wire [B-1:0] r_data,
    output wire [7:0] out
   );

   //signal declaration
   reg [B-1:0] array_reg [2**W-1:0];  // register array reg [B-1:0] array_reg [2**W-1:0];
   reg [W-1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;
   reg [W-1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;
   reg full_reg, empty_reg, full_next, empty_next;
   reg [7:0]tem_reg, tem_next, trans;
   reg [7:0]counter, counter_next;
   wire wr_en;

   // body
   // register file write operation
   always @(posedge clk)
      if (wr_en)
         array_reg[w_ptr_reg] <= w_data;
   // register file read operation
   assign r_data = array_reg[r_ptr_reg];
   // write enabled only when FIFO is not full
   assign wr_en = wr & ~full_reg;

   // fifo control logic
   // register for read and write pointers
   always @(posedge clk, posedge reset)
      if (reset)
         begin
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
            full_reg <= 1'b0;
            empty_reg <= 1'b1;
	    tem_reg <= 8'b00000000;
	    counter <= 8'b00000000;
         end
      else
         begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg <= full_next;
            empty_reg <= empty_next;
	    tem_reg <= tem_next;
	    counter <= counter_next;
         end

   // next-state logic for read and write pointers
   always @*
   begin
      // successive pointer values
      w_ptr_succ = w_ptr_reg + 1;
      r_ptr_succ = r_ptr_reg + 1;
      // default: keep old values
      w_ptr_next = w_ptr_reg;
      r_ptr_next = r_ptr_reg;
      full_next = full_reg;
      empty_next = empty_reg;
	
      case ({wr, rd})
         // 2'b00:  no op
         2'b01: // read
            if (~empty_reg) // not empty
               begin
                  r_ptr_next = r_ptr_succ;
                  full_next = 1'b0;
                  if (r_ptr_succ==w_ptr_reg)
                     empty_next = 1'b1;
               end
         2'b10: // write
            if (~full_reg) // not full
               begin
                  w_ptr_next = w_ptr_succ;
                  empty_next = 1'b0;
                  if (w_ptr_succ==r_ptr_reg)
                     full_next = 1'b1;
               end
         2'b11: // write and read
            begin
               w_ptr_next = w_ptr_succ;
               r_ptr_next = r_ptr_succ;
            end
      endcase
   end


always@(array_reg[0],array_reg[1],array_reg[2],array_reg[3],array_reg[4],array_reg[5],array_reg[6], array_reg[7])

begin
if(array_reg[0]== 8'b00110001)
	begin
	tem_next[7] = 1;
	counter_next[7] = 1;
	end
else if (array_reg[0] == 8'b00110000)
	begin
	tem_next[7] = 0;
	counter_next[7] = 1;
	end
if(array_reg[1]== 8'b00110001)
	begin
	tem_next[6] = 1;
	counter_next[6] = 1;
	end
else if (array_reg[1] == 8'b00110000)
	begin
	tem_next[6] = 0;
	counter_next[6] = 1;
	end
if(array_reg[2]== 8'b00110001)
	begin
	tem_next[5] = 1;
	counter_next[5] = 1;
	end
else if (array_reg[2] == 8'b00110000)
	begin
	tem_next[5] = 0;
	counter_next[5] = 1;
	end
if(array_reg[3]== 8'b00110001)
	begin
	tem_next[4] = 1;
	counter_next[4] = 1;
	end
else if (array_reg[3] == 8'b00110000)
	begin
	tem_next[4] = 0;
	counter_next[4] = 1;
	end
if(array_reg[4]== 8'b00110001)
	begin
	tem_next[3] = 1;
	counter_next[3] = 1;
	end
else if (array_reg[4] == 8'b00110000)
	begin
	tem_next[3] = 0;
	counter_next[3] = 1;
	end
if(array_reg[5]== 8'b00110001)
	begin
	tem_next[2] = 1;
	counter_next[2] = 1;
	end
else if (array_reg[5] == 8'b00110000)
	begin
	tem_next[2] = 0;
	counter_next[2] = 1;
	end
if(array_reg[6]== 8'b00110001)
	begin
	tem_next[1] = 1;
	counter_next[1] = 1;
	end
else if (array_reg[6] == 8'b00110000)
	begin
	tem_next[1] = 0;
	counter_next[1] = 1;
	end
if(array_reg[7]== 8'b00110001)
	begin
	tem_next[0] = 1;
	counter_next[0] = 1;
	end
else if (array_reg[7] == 8'b00110000)
	begin
	tem_next[0] = 0;
	counter_next[0] = 1;
	end
if(counter == 8'b11111111)
	trans = tem_reg;
	

	end

   // output
   assign full = full_reg;
   assign empty = empty_reg;




assign out = trans;

endmodule

