`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2025 12:25:53 AM
// Design Name: 
// Module Name: bluetooth_request
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bluetooth_request(
			 input wire 	  clk,
			 input wire 	  rst,
			 input wire 	  req_bluetooth_start,
			 input wire [7:0] req_bluetooth_data,
			 output reg 	  req_bluetooth_done,
			 output wire 	  tx_bluetooth
			 );
   
   localparam PACKET_LEN = 4'd10;

   wire 				  tx_bluetooth_ready;

   reg [3:0] 				  byte_index;
   reg [7:0] 				  tx_bluetooth_data;
   reg 					  tx_bluetooth_start;

   uart_tx
     uart_tx_bluetooth_inst (
			     .clk(clk),
			     .rst(rst),
			     .tx_start(tx_bluetooth_start),
			     .tx_data(tx_bluetooth_data),
			     .tx(tx_bluetooth),
			     .tx_ready(tx_bluetooth_ready));

   localparam IDLE = 3'b000;
   localparam BUILD = 3'b001;
   localparam LOAD = 3'b010;
   localparam SEND = 3'b011;
   localparam WAIT = 3'b100;
   localparam DONE = 3'b101;

   reg [2:0] 				  state, next_state;

   always @(posedge clk) begin
      if (rst) begin
	 state <= IDLE;
      end
      else begin
	 state <= next_state;
	 if (state == LOAD) tx_bluetooth_data <= req_bluetooth_data;
      end
   end

   always @(*) begin
      next_state = state;
      tx_bluetooth_start = 1'b0;
      req_bluetooth_done = 1'b0;
      case (state)
	IDLE : begin
	   if (req_bluetooth_start) next_state = BUILD;
	end
	BUILD : begin
	   next_state = LOAD;
	end
	LOAD : begin
	   tx_bluetooth_start = 1'b1;
	   next_state = SEND;
	end
	SEND : begin
	   next_state = WAIT;
	end
	WAIT : begin
	   if (tx_bluetooth_ready) next_state = DONE;
	end
	DONE : begin
	   req_bluetooth_done = 1'b1;
	   next_state = IDLE;
	end
      endcase
   end

endmodule
