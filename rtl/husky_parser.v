`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2025 12:25:53 AM
// Design Name: 
// Module Name: husky_parser
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


module husky_parser(
		    input wire 	     clk,
		    input wire 	     rst,
		    input wire 	     rx_husky,
		    input wire 	     req_bluetooth_done,
		    output reg 	     req_bluetooth_start,
		    output reg [7:0] req_bluetooth_data,
		    output reg [15:0] origin_x,
            output reg [15:0] target_x,
            output reg [15:0] origin_y,
            output reg [15:0] target_y
		    );

   wire 			     rx_husky_done;
   wire [7:0] 			     rx_husky_data;

   uart_rx
     uart_rx_husky_inst (
			 .clk(clk),
			 .rst(rst),
			 .rx(rx_husky),
			 .rx_done(rx_husky_done),
			 .rx_data(rx_husky_data));

   localparam IDLE = 4'b0000;
   localparam HEADER1 = 4'b0001;
   localparam HEADER2 = 4'b0010;
   localparam ADDR = 4'b0011;
   localparam LEN = 4'b0100;
   localparam CMD = 4'b0101;
   localparam DATA_LOAD = 4'b0111;
   localparam DATA_WAIT = 4'b1000;
   localparam SEND = 4'b1001;
   localparam SEND_WAIT = 4'b1010;

   reg [3:0] 			     state, next_state;
   reg [3:0] 			     byte_count;
   reg [7:0] 			     buffer [0:9];
   reg [3:0] 			     send_index;

   always @(posedge clk) begin
      if (rst) begin
	 state <= IDLE;
	 byte_count <= 4'd0;
	 send_index <= 4'd1;
	 req_bluetooth_start <= 1'b0;
	 req_bluetooth_data <= 8'd0;
      end 
      else begin
	 state <= next_state;
	 req_bluetooth_start <= 1'b0;
	 case (state)
	   IDLE : begin
	      if (rx_husky_done && rx_husky_data == 8'h55) next_state <= HEADER1;
	   end
	   HEADER1 : begin
              if (rx_husky_done && rx_husky_data == 8'hAA) next_state <= HEADER2;
	   end
	   HEADER2 : begin
              if (rx_husky_done && rx_husky_data == 8'h11) next_state <= ADDR;
	   end
	   ADDR : begin
              if (rx_husky_done) next_state <= LEN;
	   end
	   LEN : begin
              if (rx_husky_done) next_state <= CMD;
	   end
	   CMD : begin
              if (rx_husky_done && rx_husky_data == 8'h2B) begin
		 next_state <= DATA_LOAD;
		 byte_count <= 4'd0;
              end
	   end
	   DATA_LOAD : begin
	      buffer[byte_count] <= rx_husky_data;
	      next_state <= DATA_WAIT;
	   end
	   DATA_WAIT : begin
	      if (rx_husky_done) begin
		 if (byte_count == 4'd9) begin
		    next_state <= SEND;
		    byte_count <= 4'd0;
		    send_index <= 4'd1;
		 end
		 else begin
		    byte_count <= byte_count + 4'd1;
		    next_state <= DATA_LOAD;
		 end
	      end
	   end
	   SEND : begin
	      req_bluetooth_data <= buffer[send_index];
	      req_bluetooth_start <= 1'b1;
	      next_state <= SEND_WAIT;
	   end
	   SEND_WAIT : begin
	    if (req_bluetooth_done) begin
		 if (send_index == 4'd8) begin
		    origin_x <= {buffer[2], buffer[1]};
		    origin_y <= {buffer[4], buffer[3]};
		    target_x <= {buffer[6], buffer[5]};
		    target_y <= {buffer[8], buffer[7]};
		    send_index <= 4'd1;
		    next_state <= IDLE;
		 end
		 else begin
		    send_index <= send_index + 4'd1;
		    next_state <= SEND;
		 end
	    end
	   end
	 endcase
      end
   end

endmodule

