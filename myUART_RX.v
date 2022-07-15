module myUART_RX(rst, clk, Data, rdy, rxd);//, parCheck);
	input rst, clk, rxd;
	output rdy;
	output [7:0]Data;
	//output parCheck;
	
	reg [8:0]trama;
	wire opR, rst_synR, ecnt217, syn, ecntBaud, carryB, carry, ecntData;
	reg [11:0]cnt217;
	reg [12:0]cntBaud;
	reg [3:0]cntData;
	
	always @(negedge rst, posedge clk) //Registro de serie a paralelo
		if(~rst) trama <= 0;
		//else if(rst_synR) trama <= 0;
		else if(opR) trama <= {rxd, trama[8:1]};
		
	always @(negedge rst, posedge clk) //Contador para sincornizar los datos
		if(~rst) cnt217 <= 0;
		else if(syn) cnt217 <= 0;
		else if (ecnt217) cnt217 <= cnt217 + 1'b1;
		
	assign syn = (cnt217 == 2604)? 1'b1 : 1'b0;
	
	always @(negedge rst, posedge clk) //Generador de baudios
		if(~rst) cntBaud <= 0;
		else if(carryB) cntBaud <= 0;
		else if (ecntBaud)cntBaud <= cntBaud + 1'b1;
		
	assign carryB = (cntBaud == 5208)? 1'b1 : 1'b0;
	
	always @(negedge rst, posedge clk) //Contador de datos de la trama recibida
		if(~rst) cntData <= 0;
		else if(carry) cntData <= 0;
		else if (opR)cntData <= cntData + 1'b1;
		
	assign carry = (cntData == 9)? 1'b1 : 1'b0;
	
	assign Data = trama[7:0];
	//assign parCheck = ~((trama[0] ^ trama[1] ^ trama[2] ^ trama[3] ^ trama[4] ^ trama[5] ^ trama[6] ^ trama[7]) ^ trama[8]);		
	
	reg [2:0] nxtSt;
	reg [2:0] currSt;
	
	always @* begin 
		nxtSt = currSt;   //This line is equivalent to the "else" condition and avoids to repeat code
		
		case(currSt)
			0:
			   if (~rxd)
					nxtSt = 1;
			1:	
			   if (syn)
					nxtSt = 2;
			2:
				if(carryB)
					nxtSt = 3;
				else if(carry)
					nxtSt = 4;
			3:
				nxtSt = 2;
			4: 
				if (carryB)
					nxtSt = 5;
			5:
				if (rxd) //Con paridad el estado 5 es copia del 4 (el rxd de esta linea se cambia por carryB)
					nxtSt = 6;
			/*6: //Descomentar para agregar paridad par
				if (rxd) 
					nxtSt = 7;*/
			6:	
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
	
	assign opR = (currSt == 3) ? 1'b1 : 1'b0;
	assign ecnt217 = (currSt == 1) ? 1'b1 : 1'b0;
	assign ecntBaud = (currSt == 2 || currSt == 3 || currSt == 4 || currSt == 5) ? 1'b1 : 1'b0;
	//assign ecntData = (currSt == 3) ? 1'b1 : 1'b0;
	assign rdy = (currSt == 6) ? 1'b1 : 1'b0; // La paridad seria en estado 7
	

endmodule