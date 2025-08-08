`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2025 12:25:53 AM
// Design Name: 
// Module Name: husky_request
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


module husky_request(
		     input wire       clk,
		     input wire       rst,
		     input wire       req_husky_start,
		     input wire [7:0] req_husky_cmd,
		     input wire [7:0] req_husky_data_len,
		     output reg       req_husky_done,
		     output wire      tx_husky
		     );
   
   localparam PACKET_LEN = 3'd6;

   wire 			      tx_husky_ready;

   reg [7:0] 			      tx_husky_packet [0:5];
   reg [2:0] 			      byte_index;
   
   reg [2:0] 			      state, next_state;
   reg [7:0] 			      tx_husky_data;
   reg 				      tx_husky_start;

   uart_tx
     uart_tx_husky_inst (
			 .clk(clk),
			 .rst(rst),
			 .tx_start(tx_husky_start),
			 .tx_data(tx_husky_data),
			 .tx(tx_husky),
			 .tx_ready(tx_husky_ready));

   always @(*) begin
      tx_husky_packet[0] = 8'h55;
      tx_husky_packet[1] = 8'hAA;
      tx_husky_packet[2] = 8'h11;
      tx_husky_packet[3] = req_husky_data_len;
      tx_husky_packet[4] = req_husky_cmd;
      tx_husky_packet[5] = tx_husky_packet[0] + tx_husky_packet[1] + tx_husky_packet[2] + tx_husky_packet[3] + tx_husky_packet[4];
   end

   localparam IDLE = 3'b000;
   localparam BUILD = 3'b001;
   localparam LOAD = 3'b010;
   localparam SEND = 3'b011;
   localparam WAIT = 3'b100;
   localparam DONE = 3'b101;

   always @(posedge clk) begin
      if (rst) begin
	 state <= IDLE;
	 byte_index <= 3'd0;
      end
      else begin
	 state <= next_state;
	 if (state == LOAD) tx_husky_data <= tx_husky_packet[byte_index];
	 if (state == WAIT && tx_husky_ready && byte_index < PACKET_LEN - 3'd1) byte_index <= byte_index + 3'd1;
	 if (state == DONE) byte_index <= 3'd0;
      end
   end

   always @(*) begin
      next_state = state;
      tx_husky_start = 1'b0;
      req_husky_done = 1'b0;
      case (state)
	IDLE : begin
	   if (req_husky_start) next_state = BUILD;
	end
	BUILD : begin
	   next_state = LOAD;
	end
	LOAD : begin
	   tx_husky_start = 1'b1;
	   next_state = SEND;
	end
	SEND : begin
	   next_state = WAIT;
	end
	WAIT : begin
	   if (tx_husky_ready) next_state = (byte_index == PACKET_LEN - 3'd1) ? DONE : LOAD;
	end
	DONE : begin
	   req_husky_done = 1'b1;
	   next_state = IDLE;
	end
      endcase
   end

endmodule
