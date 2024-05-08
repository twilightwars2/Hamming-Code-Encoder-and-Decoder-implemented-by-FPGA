module decoder
(
input wire clk, decode, 
input wire [7:0] de_in,
output wire [3:0] de_out,
output reg LCD_E, LCD_RS, LCD_RW,
output reg [7:0] LCD_DB
);


//registers

reg [2:0] state_reg, state_next, get, get_next;
reg [3:0] error_tem0, error_tem1, error_tem2, error_code;
reg [3:0] parity_count, parity_next, data, data_next, check_reg, check_reg_next;

reg [24:0] count_next;
reg [24:0] count = 0; // 23-bit count, 0-(2^23-1), less than 0.2 s

reg [5:0] code; // {LCD_RS, LCD_RW, LCD_DB[7:4]}
reg refresh; // refresh LCD rate @ about 200Hz


//state param

localparam [2:0]
	prepare = 3'b000,
	check = 3'b001,
	branch = 3'b010,
	ham_right_p_right = 3'b011,
	ham_right_p_wrong = 3'b100,
	ham_wrong1bit = 3'b101,
	ham_wrong2bit = 3'b110;






//body

//DFF setting
always @(posedge clk, posedge decode)
	if (decode)
		begin
		check_reg <= 0;
		parity_count <= 0;
		state_reg <= prepare;
		data <= 0;
		count <= 0;
		get <= 0;

		end
	else
		begin
		check_reg <= check_reg_next;
		state_reg <= state_next;
		parity_count <= parity_next;
		data <= data_next;
		count <= count_next;
		get <= get_next;
		LCD_E <= refresh;
		LCD_RS <= code[5];
		LCD_RW <= code[4];
		LCD_DB[7] <= code[3];
		LCD_DB[6] <= code[2];
		LCD_DB[5] <= code[1];
		LCD_DB[4] <= code[0];
		LCD_DB[3] <= 1;
		LCD_DB[2] <= 1;
		LCD_DB[1] <= 1;
		LCD_DB[0] <= 1;
		
		end


//next state logic

always@*
	begin
	state_next = state_reg;
	check_reg_next = check_reg;
	parity_next = parity_count;
	data_next = data;
	get_next = get;
	case(state_reg)
	prepare: 
		begin
		if(de_in[4]^de_in[3]^de_in[2]^de_in[1])
			begin
			error_tem0 = 4;
			get_next[0] = 1;
			end
		else 
			begin
			error_tem0 = 0;
			get_next[0] = 1;
			end
		if(de_in[6]^de_in[5]^de_in[2]^de_in[1])
			begin
			error_tem1 = 2;
			get_next[1] = 1;
			end
		else 
			begin
			error_tem1 = 0;
			get_next[1] = 1;
			end
		if(de_in[7]^de_in[5]^de_in[3]^de_in[1])
			begin
			error_tem2 = 1;
			get_next[2] = 1;
			end
		else 
			begin
			error_tem2 = 0;
			get_next[2] = 1;
			end
		if(get==3'b111)
			begin
			error_code = error_tem0 + error_tem1 + error_tem2;
			state_next = check;
			end
		end
		
	check:						//check state: check the parity
		begin				
		if(de_in[check_reg] == 1)
			begin
			parity_next = parity_count + 1;             
			check_reg_next = check_reg + 1;
			end
		else
			parity_next = parity_count;
			check_reg_next = check_reg + 1;
		if(check_reg == 4'b1000)  
			begin
			parity_next = parity_count;
			state_next = branch;
			end
		end
	branch:						//branch state: according to error code and parity, branch to different state
		if((error_code == 0) && (parity_count[0] == 0))
			state_next = ham_right_p_right;
		else if((error_code == 0) && (parity_count[0] == 1))
			state_next = ham_right_p_wrong;
		else if((error_code != 0) && (parity_count[0] == 1))
			state_next = ham_wrong1bit;
		else if((error_code != 0) && (parity_count[0] == 0))
			state_next = ham_wrong2bit;
		else state_next = state_reg;

	ham_right_p_right:
		begin					
		data_next = {de_in[5], de_in[3], de_in[2], de_in[1]};
		if(count [24:18] ==68)
				count_next = count;
			else
				count_next = count + 1;
			refresh = count[17];
			case (count [24:18]) 
				0: code = 6'h03; // power-on initializatoin sequence
				1: code = 6'h03;
				2: code = 6'h03;
				3: code = 6'h02;
				4: code = 6'h02; // configuration
				5: code = 6'h08;
				6: code = 6'h00;
				7: code = 6'h06;
				8: code = 6'h00;
				9: code = 6'h0C;
				10: code = 6'h00;
				11: code = 6'h01;
				12: code = 6'h24; // write data, H
				13: code = 6'h28;
				14: code = 6'h26; //a
				15: code = 6'h21;
				16: code = 6'h26; //m
				17: code = 6'h2D;
				18: code = 6'h26; //m
				19: code = 6'h2D;
				20: code = 6'h26; //i
				21: code = 6'h29;
				22: code = 6'h26; //n
				23: code = 6'h2E;
				24: code = 6'h26; //g
				25: code = 6'h27;
				26: code = 6'h22; //space
				27: code = 6'h20;
				28: code = 6'h25; //R
				29: code = 6'h22;
				30: code = 6'h26; //i
				31: code = 6'h29;
				32: code = 6'h26; //g
				33: code = 6'h27;
				34: code = 6'h26; //h
				35: code = 6'h28;
				36: code = 6'h27; //t
				37: code = 6'h24; 
				38: code = 6'h22; //!
				39: code = 6'h21;
				40: code = 6'h0A; //set DD RAM to second line
				41: code = 6'h08;
				42: code = 6'h25; //P
				43: code = 6'h20; 
				44: code = 6'h26; //a
				45: code = 6'h21;
				46: code = 6'h27; //r
				47: code = 6'h22;
				48: code = 6'h26; //i
				49: code = 6'h29;
				50: code = 6'h27; //t
				51: code = 6'h24;
				52: code = 6'h27; //y
				53: code = 6'h29;
				54: code = 6'h22; //space
				55: code = 6'h20;
				56: code = 6'h25; //R
				57: code = 6'h22;
				58: code = 6'h26; //i
				59: code = 6'h29;
				60: code = 6'h26; //g
				61: code = 6'h27;
				62: code = 6'h26; //h
				63: code = 6'h28;
				64: code = 6'h27; //t
				65: code = 6'h24; 
				66: code = 6'h22; //!
				67: code = 6'h21;
				default: code = 6'h10; //no written data 

			endcase
		end
	ham_right_p_wrong:
		begin
		data_next = {de_in[5], de_in[3], de_in[2], de_in[1]};
		if(count [24:18] ==68)
				count_next = count;
			else
				count_next = count + 1;
			refresh = count[17];
			case (count [24:18]) 
				0: code = 6'h03; // power-on initializatoin sequence
				1: code = 6'h03;
				2: code = 6'h03;
				3: code = 6'h02;
				4: code = 6'h02; // configuration
				5: code = 6'h08;
				6: code = 6'h00;
				7: code = 6'h06;
				8: code = 6'h00;
				9: code = 6'h0C;
				10: code = 6'h00;
				11: code = 6'h01;
				12: code = 6'h24; // write data, H
				13: code = 6'h28;
				14: code = 6'h26; //a
				15: code = 6'h21;
				16: code = 6'h26; //m
				17: code = 6'h2D;
				18: code = 6'h26; //m
				19: code = 6'h2D;
				20: code = 6'h26; //i
				21: code = 6'h29;
				22: code = 6'h26; //n
				23: code = 6'h2E;
				24: code = 6'h26; //g
				25: code = 6'h27;
				26: code = 6'h22; //space
				27: code = 6'h20;
				28: code = 6'h25; //R
				29: code = 6'h22;
				30: code = 6'h26; //i
				31: code = 6'h29;
				32: code = 6'h26; //g
				33: code = 6'h27;
				34: code = 6'h26; //h
				35: code = 6'h28;
				36: code = 6'h27; //t
				37: code = 6'h24; 
				38: code = 6'h22; //!
				39: code = 6'h21;
				40: code = 6'h0A; //set DD RAM to second line
				41: code = 6'h08;
				42: code = 6'h25; //P
				43: code = 6'h20; 
				44: code = 6'h26; //a
				45: code = 6'h21;
				46: code = 6'h27; //r
				47: code = 6'h22;
				48: code = 6'h26; //i
				49: code = 6'h29;
				50: code = 6'h27; //t
				51: code = 6'h24;
				52: code = 6'h27; //y
				53: code = 6'h29;
				54: code = 6'h22; //space
				55: code = 6'h20;
				56: code = 6'h25; //W
				57: code = 6'h27;
				58: code = 6'h27; //r
				59: code = 6'h22;
				60: code = 6'h26; //o
				61: code = 6'h2F;
				62: code = 6'h26; //n
				63: code = 6'h2E;
				64: code = 6'h26; //g
				65: code = 6'h27;
				66: code = 6'h22; //!
				67: code = 6'h21;
				default: code = 6'h10; //no written data 

			endcase
		end
	ham_wrong1bit:
		begin
		if((error_code == 1) || (error_code == 2) || (error_code == 4) )
			begin
			data_next = {de_in[5], de_in[3], de_in[2], de_in[1]};
			if(count [24:18] ==52)
				count_next = count;
			else
				count_next = count + 1;
			refresh = count[17];
			case (count [24:18]) 
				0: code = 6'h03; // power-on initializatoin sequence
				1: code = 6'h03;
				2: code = 6'h03;
				3: code = 6'h02;
				4: code = 6'h02; // configuration
				5: code = 6'h08;
				6: code = 6'h00;
				7: code = 6'h06;
				8: code = 6'h00;
				9: code = 6'h0C;
				10: code = 6'h00;
				11: code = 6'h01;
				12: code = 6'h25; //W
				13: code = 6'h27;
				14: code = 6'h27; //r
				15: code = 6'h22;
				16: code = 6'h26; //o
				17: code = 6'h2F;
				18: code = 6'h26; //n
				19: code = 6'h2E;
				20: code = 6'h26; //g
				21: code = 6'h27;
				22: code = 6'h22; //space
				23: code = 6'h20;
				24: code = 6'h23; //1
				25: code = 6'h21;
				26: code = 6'h22; //space
				27: code = 6'h20;
				28: code = 6'h26; //b
				29: code = 6'h22;
				30: code = 6'h26; //i
				31: code = 6'h29;
				32: code = 6'h27; //t
				33: code = 6'h24; 
				34: code = 6'h22; //!
				35: code = 6'h21;
				36: code = 6'h0A; //set DD RAM to second line
				37: code = 6'h08;
				38: code = 6'h23;
				39: begin
					if(error_code == 1)
					begin
						if(de_in[7]==1)
							code = 6'h20;
						else if(de_in[7]==0)
							code = 6'h21;
					end
					else
					begin
						if(de_in[7]==0)
							code = 6'h20;
						else if(de_in[7]==1)
							code = 6'h21;
					end
				    end
				40: code = 6'h23;
				41: begin
					if(error_code == 2)
					begin
						if(de_in[6]==1)
							code = 6'h20;
						else if(de_in[6]==0)
							code = 6'h21;
					end
					else
					begin
						if(de_in[6]==0)
							code = 6'h20;
						else if(de_in[6]==1)
							code = 6'h21;
					end
				    end
				42: code = 6'h23;
				43: begin
						if(de_in[5]==0)
							code = 6'h20;
						else if(de_in[5]==1)
							code = 6'h21;
				    end
				44: code = 6'h23;
				45: begin
					if(error_code == 4)
					begin
						if(de_in[4]==1)
							code = 6'h20;
						else if(de_in[4]==0)
							code = 6'h21;
					end
					else
					begin
						if(de_in[4]==0)
							code = 6'h20;
						else if(de_in[4]==1)
							code = 6'h21;
					end
				    end
				46: code = 6'h23;
				47: begin
						if(de_in[3]==0)
							code = 6'h20;
						else if(de_in[3]==1)
							code = 6'h21;
				    end
				48: code = 6'h23;
				49: begin
						if(de_in[2]==0)
							code = 6'h20;
						else if(de_in[2]==1)
							code = 6'h21;
				    end
				50: code = 6'h23;
				51: begin
						if(de_in[1]==0)
							code = 6'h20;
						else if(de_in[1]==1)
							code = 6'h21;
				    end
				
			default: code = 6'h10; //no written data 

			endcase

			end
		if(error_code == 3)
			begin
			data_next = {~de_in[5], de_in[3], de_in[2], de_in[1]};
			if(count [24:18] ==52)
				count_next = count;
			else
				count_next = count + 1;
			refresh = count[17];
			case (count [24:18]) 
				0: code = 6'h03; // power-on initializatoin sequence
				1: code = 6'h03;
				2: code = 6'h03;
				3: code = 6'h02;
				4: code = 6'h02; // configuration
				5: code = 6'h08;
				6: code = 6'h00;
				7: code = 6'h06;
				8: code = 6'h00;
				9: code = 6'h0C;
				10: code = 6'h00;
				11: code = 6'h01;
				12: code = 6'h25; //W
				13: code = 6'h27;
				14: code = 6'h27; //r
				15: code = 6'h22;
				16: code = 6'h26; //o
				17: code = 6'h2F;
				18: code = 6'h26; //n
				19: code = 6'h2E;
				20: code = 6'h26; //g
				21: code = 6'h27;
				22: code = 6'h22; //space
				23: code = 6'h20;
				24: code = 6'h23; //1
				25: code = 6'h21;
				26: code = 6'h22; //space
				27: code = 6'h20;
				28: code = 6'h26; //b
				29: code = 6'h22;
				30: code = 6'h26; //i
				31: code = 6'h29;
				32: code = 6'h27; //t
				33: code = 6'h24; 
				34: code = 6'h22; //!
				35: code = 6'h21;
				36: code = 6'h0A; //set DD RAM to second line
				37: code = 6'h08;
				38: code = 6'h23;
				39: begin
						if(de_in[7]==0)
							code = 6'h20;
						else if(de_in[7]==1)
							code = 6'h21;
				    end
				40: code = 6'h23;
				41: begin
						if(de_in[6]==0)
							code = 6'h20;
						else if(de_in[6]==1)
							code = 6'h21;
				    end
				42: code = 6'h23;
				43: begin
						if(de_in[5]==0)
							code = 6'h21;
						else if(de_in[5]==1)
							code = 6'h20;
				    end
				44: code = 6'h23;
				45: begin
						if(de_in[4]==0)
							code = 6'h20;
						else if(de_in[4]==1)
							code = 6'h21;
				    end
				46: code = 6'h23;
				47: begin
						if(de_in[3]==0)
							code = 6'h20;
						else if(de_in[3]==1)
							code = 6'h21;
				    end
				48: code = 6'h23;
				49: begin
						if(de_in[2]==0)
							code = 6'h20;
						else if(de_in[2]==1)
							code = 6'h21;
				    end
				50: code = 6'h23;
				51: begin
						if(de_in[1]==0)
							code = 6'h20;
						else if(de_in[1]==1)
							code = 6'h21;
				    end
				

			default: code = 6'h10; //no written data 

			endcase

			end
		if(error_code == 5)
			begin
			data_next = {de_in[5], ~de_in[3], de_in[2], de_in[1]};
			if(count [24:18] ==52)
				count_next = count;
			else
				count_next = count + 1;
			refresh = count[17];
			case (count [24:18]) 
				0: code = 6'h03; // power-on initializatoin sequence
				1: code = 6'h03;
				2: code = 6'h03;
				3: code = 6'h02;
				4: code = 6'h02; // configuration
				5: code = 6'h08;
				6: code = 6'h00;
				7: code = 6'h06;
				8: code = 6'h00;
				9: code = 6'h0C;
				10: code = 6'h00;
				11: code = 6'h01;
				12: code = 6'h25; //W
				13: code = 6'h27;
				14: code = 6'h27; //r
				15: code = 6'h22;
				16: code = 6'h26; //o
				17: code = 6'h2F;
				18: code = 6'h26; //n
				19: code = 6'h2E;
				20: code = 6'h26; //g
				21: code = 6'h27;
				22: code = 6'h22; //space
				23: code = 6'h20;
				24: code = 6'h23; //1
				25: code = 6'h21;
				26: code = 6'h22; //space
				27: code = 6'h20;
				28: code = 6'h26; //b
				29: code = 6'h22;
				30: code = 6'h26; //i
				31: code = 6'h29;
				32: code = 6'h27; //t
				33: code = 6'h24; 
				34: code = 6'h22; //!
				35: code = 6'h21;
				36: code = 6'h0A; //set DD RAM to second line
				37: code = 6'h08;
				38: code = 6'h23;
				39: begin
						if(de_in[7]==0)
							code = 6'h20;
						else if(de_in[7]==1)
							code = 6'h21;
				    end
				40: code = 6'h23;
				41: begin
						if(de_in[6]==0)
							code = 6'h20;
						else if(de_in[6]==1)
							code = 6'h21;
				    end
				42: code = 6'h23;
				43: begin
						if(de_in[5]==0)
							code = 6'h20;
						else if(de_in[5]==1)
							code = 6'h21;
				    end
				44: code = 6'h23;
				45: begin
						if(de_in[4]==0)
							code = 6'h20;
						else if(de_in[4]==1)
							code = 6'h21;
				    end
				46: code = 6'h23;
				47: begin
						if(de_in[3]==0)
							code = 6'h21;
						else if(de_in[3]==1)
							code = 6'h20;
				    end
				48: code = 6'h23;
				49: begin
						if(de_in[2]==0)
							code = 6'h20;
						else if(de_in[2]==1)
							code = 6'h21;
				    end
				50: code = 6'h23;
				51: begin
						if(de_in[1]==0)
							code = 6'h20;
						else if(de_in[1]==1)
							code = 6'h21;
				    end
				
				

			default: code = 6'h10; //no written data 

			endcase
			end

		if(error_code == 6)
			begin
			data_next = {de_in[5], de_in[3], ~de_in[2], de_in[1]};
			if(count [24:18] ==52)
				count_next = count;
			else
				count_next = count + 1;
			refresh = count[17];
			case (count [24:18]) 
				0: code = 6'h03; // power-on initializatoin sequence
				1: code = 6'h03;
				2: code = 6'h03;
				3: code = 6'h02;
				4: code = 6'h02; // configuration
				5: code = 6'h08;
				6: code = 6'h00;
				7: code = 6'h06;
				8: code = 6'h00;
				9: code = 6'h0C;
				10: code = 6'h00;
				11: code = 6'h01;
				12: code = 6'h25; //W
				13: code = 6'h27;
				14: code = 6'h27; //r
				15: code = 6'h22;
				16: code = 6'h26; //o
				17: code = 6'h2F;
				18: code = 6'h26; //n
				19: code = 6'h2E;
				20: code = 6'h26; //g
				21: code = 6'h27;
				22: code = 6'h22; //space
				23: code = 6'h20;
				24: code = 6'h23; //1
				25: code = 6'h21;
				26: code = 6'h22; //space
				27: code = 6'h20;
				28: code = 6'h26; //b
				29: code = 6'h22;
				30: code = 6'h26; //i
				31: code = 6'h29;
				32: code = 6'h27; //t
				33: code = 6'h24; 
				34: code = 6'h22; //!
				35: code = 6'h21;
				36: code = 6'h0A; //set DD RAM to second line
				37: code = 6'h08;
				38: code = 6'h23;
				39: begin
						if(de_in[7]==0)
							code = 6'h20;
						else if(de_in[7]==1)
							code = 6'h21;
				    end
				40: code = 6'h23;
				41: begin
						if(de_in[6]==0)
							code = 6'h20;
						else if(de_in[6]==1)
							code = 6'h21;
				    end
				42: code = 6'h23;
				43: begin
						if(de_in[5]==0)
							code = 6'h20;
						else if(de_in[5]==1)
							code = 6'h21;
				    end
				44: code = 6'h23;
				45: begin
						if(de_in[4]==0)
							code = 6'h20;
						else if(de_in[4]==1)
							code = 6'h21;
				    end
				46: code = 6'h23;
				47: begin
						if(de_in[3]==0)
							code = 6'h20;
						else if(de_in[3]==1)
							code = 6'h21;
				    end
				48: code = 6'h23;
				49: begin
						if(de_in[2]==0)
							code = 6'h21;
						else if(de_in[2]==1)
							code = 6'h20;
				    end
				50: code = 6'h23;
				51: begin
						if(de_in[1]==0)
							code = 6'h20;
						else if(de_in[1]==1)
							code = 6'h21;
				    end
				
				

			default: code = 6'h10; //no written data 

			endcase
			end

		if(error_code == 7)
			begin
			data_next = {de_in[5], de_in[3], de_in[2], ~de_in[1]};
			if(count [24:18] ==52)
				count_next = count;
			else
				count_next = count + 1;
			refresh = count[17];
			case (count [24:18]) 
				0: code = 6'h03; // power-on initializatoin sequence
				1: code = 6'h03;
				2: code = 6'h03;
				3: code = 6'h02;
				4: code = 6'h02; // configuration
				5: code = 6'h08;
				6: code = 6'h00;
				7: code = 6'h06;
				8: code = 6'h00;
				9: code = 6'h0C;
				10: code = 6'h00;
				11: code = 6'h01;
				12: code = 6'h25; //W
				13: code = 6'h27;
				14: code = 6'h27; //r
				15: code = 6'h22;
				16: code = 6'h26; //o
				17: code = 6'h2F;
				18: code = 6'h26; //n
				19: code = 6'h2E;
				20: code = 6'h26; //g
				21: code = 6'h27;
				22: code = 6'h22; //space
				23: code = 6'h20;
				24: code = 6'h23; //1
				25: code = 6'h21;
				26: code = 6'h22; //space
				27: code = 6'h20;
				28: code = 6'h26; //b
				29: code = 6'h22;
				30: code = 6'h26; //i
				31: code = 6'h29;
				32: code = 6'h27; //t
				33: code = 6'h24; 
				34: code = 6'h22; //!
				35: code = 6'h21;
				36: code = 6'h0A; //set DD RAM to second line
				37: code = 6'h08;
				38: code = 6'h23;
				39: begin
						if(de_in[7]==0)
							code = 6'h20;
						else if(de_in[7]==1)
							code = 6'h21;
				    end
				40: code = 6'h23;
				41: begin
						if(de_in[6]==0)
							code = 6'h20;
						else if(de_in[6]==1)
							code = 6'h21;
				    end
				42: code = 6'h23;
				43: begin
						if(de_in[5]==0)
							code = 6'h20;
						else if(de_in[5]==1)
							code = 6'h21;
				    end
				44: code = 6'h23;
				45: begin
						if(de_in[4]==0)
							code = 6'h20;
						else if(de_in[4]==1)
							code = 6'h21;
				    end
				46: code = 6'h23;
				47: begin
						if(de_in[3]==0)
							code = 6'h20;
						else if(de_in[3]==1)
							code = 6'h21;
				    end
				48: code = 6'h23;
				49: begin
						if(de_in[2]==0)
							code = 6'h20;
						else if(de_in[2]==1)
							code = 6'h21;
				    end
				50: code = 6'h23;
				51: begin
						if(de_in[1]==0)
							code = 6'h21;
						else if(de_in[1]==1)
							code = 6'h20;
				    end
				
				

			default: code = 6'h10; //no written data 

			endcase
			end

		end
	ham_wrong2bit:
		begin
		data_next = 4'b0000;
		if(count [24:18] ==38)
				count_next = count;
			else
				count_next = count + 1;
			refresh = count[17];
			case (count [24:18]) 
				0: code = 6'h03; // power-on initializatoin sequence
				1: code = 6'h03;
				2: code = 6'h03;
				3: code = 6'h02;
				4: code = 6'h02; // configuration
				5: code = 6'h08;
				6: code = 6'h00;
				7: code = 6'h06;
				8: code = 6'h00;
				9: code = 6'h0C;
				10: code = 6'h00;
				11: code = 6'h01;
				12: code = 6'h25; //W
				13: code = 6'h27;
				14: code = 6'h27; //r
				15: code = 6'h22;
				16: code = 6'h26; //o
				17: code = 6'h2F;
				18: code = 6'h26; //n
				19: code = 6'h2E;
				20: code = 6'h26; //g
				21: code = 6'h27;
				22: code = 6'h22; //space
				23: code = 6'h20;
				24: code = 6'h23; //2
				25: code = 6'h22;
				26: code = 6'h22; //space
				27: code = 6'h20;
				28: code = 6'h26; //b
				29: code = 6'h22;
				30: code = 6'h26; //i
				31: code = 6'h29;
				32: code = 6'h27; //t
				33: code = 6'h24; 
				34: code = 6'h27; //s
				35: code = 6'h23; 
				36: code = 6'h22; //!
				37: code = 6'h21;
				

			default: code = 6'h10; //no written data 

			endcase
		end

	endcase
	end

//output logic



assign de_out = data;

			






endmodule