module encoder
(
input wire clk, encode,
input wire [3:0] en_in,
output wire [6:0] en_out
);


//registers


reg [2:0] tem_reg0, tem_reg1, tem_reg2, tem_reg3;
reg [2:0] tem_reg0_next, tem_reg1_next, tem_reg2_next, tem_reg3_next;
reg [2:0] cal_reg, cal_next;
reg [1:0] state_reg, state_next;
reg [6:0] final, final_next;
reg [3:0] check, check_next, data;

//state param

localparam 
	get  = 2'b00,
	calculate = 2'b01,
	out = 2'b10;


//body

//DFF setting

always @(posedge clk, posedge encode)
	if (encode)
		begin
		tem_reg0 <= 3'b0;
		tem_reg1 <= 3'b0;
		tem_reg2 <= 3'b0;
		tem_reg3 <= 3'b0;
		cal_reg <= 0;
		state_reg <= get;
		final <= 0;
		check <= 4'b0000;
		data <= en_in;

		end
	else
		begin
		cal_reg <= cal_next;
		state_reg <= state_next;
		tem_reg0 <= tem_reg0_next;
		tem_reg1 <= tem_reg1_next;
		tem_reg2 <= tem_reg2_next;
		tem_reg3 <= tem_reg3_next;
		final <= final_next;
		check <= check_next;

		end


//next state logic

always@*
	begin
	state_next = state_reg;
	cal_next = cal_reg;
	tem_reg0_next = tem_reg0;
	tem_reg1_next = tem_reg1;
	tem_reg2_next = tem_reg2;
	tem_reg3_next = tem_reg3;
	final_next = final;
	check_next = check;
	case(state_reg)
	get:		
					//get state: get input and check if the input bit is one, if is , then store the address into tem_reg
		begin				
		if(data[0])  
			begin
			tem_reg0_next = 3'b111; 
			check_next[3] = 1;
			end
		else
			check_next[3] = 1;
		if(data[1])  
			begin
			tem_reg1_next = 3'b110; 
			check_next[2] = 1;
			end
		else
			check_next[2] = 1;
		if(data[2])  
			begin
			tem_reg2_next = 3'b101; 
			check_next[1] = 1;
			end
		else
			check_next[1] = 1;
		if(data[3])  
			begin
			tem_reg3_next = 3'b011; 
			check_next[0] = 1;   
			end   
		else
			check_next[0] = 1;       
		if(check == 4'b1111)
			state_next = calculate;
		end
	calculate: 
		begin        					//calculate state: calculate the one's address with XOR, store it into cal_reg
		if((tem_reg0 == 3'b0) && (tem_reg1 == 3'b0) && (tem_reg2 == 3'b0) && (tem_reg3 == 3'b0))
			begin
			cal_next = 3'b0;
			state_next = out;
			end
		else if((tem_reg0 == 3'b0) && (tem_reg1 == 3'b0) && (tem_reg2 == 3'b0))
			begin
			cal_next = tem_reg3;
			state_next = out;
			end
		else if((tem_reg0 == 3'b0) && (tem_reg1 == 3'b0) && (tem_reg3 == 3'b0))
			begin
			cal_next = tem_reg2;
			state_next = out;
			end
		else if((tem_reg0 == 3'b0) && (tem_reg2 == 3'b0) && (tem_reg3 == 3'b0))
			begin
			cal_next = tem_reg1;
			state_next = out;
			end
		else if((tem_reg1 == 3'b0) && (tem_reg2 == 3'b0) && (tem_reg3 == 3'b0))
			begin
			cal_next = tem_reg0;
			state_next = out;
			end
		else if((tem_reg0 == 3'b0) && (tem_reg1 == 3'b0))
			begin
			cal_next = tem_reg2^tem_reg3;
			state_next = out;
			end
		else if((tem_reg0 == 3'b0) && (tem_reg2 == 3'b0))
			begin
			cal_next = tem_reg1^tem_reg3;
			state_next = out;
			end
		else if((tem_reg0 == 3'b0) && (tem_reg3 == 3'b0))
			begin
			cal_next = tem_reg1^tem_reg2;
			state_next = out;
			end
		else if((tem_reg1 == 3'b0) && (tem_reg2 == 3'b0))
			begin
			cal_next = tem_reg0^tem_reg3;
			state_next = out;
			end
		else if((tem_reg1 == 3'b0) && (tem_reg3 == 3'b0))
			begin
			cal_next = tem_reg0^tem_reg2;
			state_next = out;
			end
		else if((tem_reg2 == 3'b0) && (tem_reg3 == 3'b0))
			begin
			cal_next = tem_reg0^tem_reg1;
			state_next = out;
			end
		else if(tem_reg0 == 3'b0)
			begin
			cal_next = tem_reg1^tem_reg2^tem_reg3;
			state_next = out;
			end
		else if(tem_reg1 == 3'b0)
			begin
			cal_next = tem_reg0^tem_reg2^tem_reg3;
			state_next = out;
			end
		else if(tem_reg2 == 3'b0)
			begin
			cal_next = tem_reg0^tem_reg1^tem_reg3;
			state_next = out;
			end
		else if(tem_reg3 == 3'b0)
			begin
			cal_next = tem_reg0^tem_reg1^tem_reg2;
			state_next = out;
			end
		else
			begin
			cal_next = tem_reg0^tem_reg1^tem_reg2^tem_reg3;
			state_next = out;
			end
		end

	out: 
		final_next = {cal_reg[0], cal_reg[1], data[3], cal_reg[2], data[2], data[1], data[0]};
	endcase
	end


//output logic


	
assign en_out = final;


endmodule

