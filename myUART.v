//BaudRate a 9600 
/*
Para modificar el baud rate se modifica la cuenta de 
  cntBaud y su numero de bits en el transmisor y tambien
  cntBaud, cnt217, y su respectivo numero de bits en el receptor

Configurado con Paridad PAR (numero de unos par se manda o espera 0 ya 
	se concidera el cero un valor par)*/
module myUART(rst, clk, st_tx, DataOUT, rxd, DataIn,rdy_Rx, rdy_Tx, txd);//, parCheck);
	input rst; 
	input clk;
	input st_tx;
	input [7:0]DataOUT;
	input rxd;
	output [7:0]DataIn;
	output rdy_Rx;
	output rdy_Tx;
	output txd;
	//output parCheck;
	
	myUART_TX transmisor(rst, clk, st_tx, DataOUT, rdy_Tx, txd);
	
	myUART_RX receptor(rst, clk, DataIn, rdy_Rx, rxd);
	
	
endmodule