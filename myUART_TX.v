module myUART_TX(rst, clk, st_tx, Data, rdy, txd);
	input rst; 
	input clk;
	input st_tx;
	input [7:0]Data;
	output rdy;
	output reg txd;
	
	wire rst_syn, e, opR;
	reg [12:0]cntBaud;
	wire carryB;
	always @(negedge rst, posedge clk) 
		if(~rst) cntBaud <= 0;
		else if(carryB | opR) cntBaud <= 0;
		else cntBaud <= cntBaud + 1'b1;
		
	assign carryB = (cntBaud == 5208)? 1'b1 : 1'b0;
	
	reg [3:0]sel;
	wire carryMux;
	always @(negedge rst, posedge clk)
		if(~rst) sel <= 0;
		else if(rst_syn) sel <= 0;
		else if(e) sel <= sel + 1'b1;
		
	assign carryMux = (sel == 10)? 1'b1 : 1'b0; // sel == 11 con paridad

	//wire paridad;
	reg [7:0]DataR;
	//assign paridad = DataR[0] ^ DataR[1] ^ DataR[2] ^ DataR[3] ^ DataR[4] ^ DataR[5] ^ DataR[6] ^ DataR[7];		

	
	always @(sel,DataR) begin //poner en lista de sensitividad a paridad
		case(sel)
			0: txd = 1; // idle
			1: txd = 0; // start bit
			2: txd = DataR[0]; //LSB
			3: txd = DataR[1];
			4: txd = DataR[2];
			5: txd = DataR[3];
			6: txd = DataR[4];
			7: txd = DataR[5];
			8: txd = DataR[6];
			9: txd = DataR[7]; //MSB
			//10: txd = paridad;//pair; //Paridad
			default: txd = 1; // stop bit
		endcase
	end
	
	
	
	always @(negedge rst, posedge clk) //Registro de data
		if(~rst) DataR <= 0;
		else if(opR) DataR <= Data;
		
	reg [1:0] nxtSt;
	reg [1:0] currSt;
	
	always @* begin 
		nxtSt = currSt;   //This line is equivalent to the "else" condition and avoids to repeat code
		
		case(currSt)
			0:
				if (~st_tx)
					nxtSt = 1;
			1:	
			   if (~carryMux)
					nxtSt = 2;
				else
					nxtSt = 3;
			2:
				if(carryB)
					nxtSt = 1;
			default:	
				nxtSt = 0;
		endcase   
	end
	/***************************************************/
	
	/*** FSM Sequential Always***/
	always @(negedge rst, posedge clk) begin
		if (~rst) begin
			currSt <= 0;
		end
		else begin
			currSt <= nxtSt;
		end
	
	end
	/***************************************************/
	
	/*** FSM Outputs ***/
	
	assign rst_syn = (currSt == 3) ? 1'b1 : 1'b0;
	assign opR = (currSt == 0) ? 1'b1 : 1'b0;
	assign e = (currSt == 1) ? 1'b1 : 1'b0;
	assign rdy = rst_syn;
	
endmodule