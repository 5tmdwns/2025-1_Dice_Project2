`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2025 09:31:40 PM
// Design Name: 
// Module Name: uart_tx
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


module uart_tx(
	       input wire 	clk,
	       input wire 	rst,
	       input wire 	tx_start,
	       input wire [7:0] tx_data,
	       output reg 	tx,
	       output reg 	tx_ready
	       );

   wire 			baud_clk;

   reg [9:0] 			shifter;
   reg [3:0] 			bit_counter;
   reg [7:0] 			tx_data_reg;
   reg 				shifter_rst;
   reg 				baud_clk_en;

   reg [1:0] 			state, next_state;

   localparam IDLE = 2'b00;
   localparam START = 2'b01;
   localparam TRANS = 2'b10;

   baudgen_tx
     baudgen_tx_inst (
		      .rst(rst),
		      .clk(clk),
		      .baud_clk_en(baud_clk_en),
		      .baud_clk(baud_clk));

//////////////////////////////////////////////////////////////////////////////////
// === DATAPATH ===
//////////////////////////////////////////////////////////////////////////////////
   
   always @(posedge clk) begin
      if (rst) tx_data_reg <= 8'd0;
      else begin
	 if (tx_start == 1'b1 && state == IDLE) tx_data_reg <= tx_data;
      end
   end

   always @(posedge clk) begin
      if (rst) begin
	 shifter <= 10'b11_1111_1111;
	 bit_counter <= 4'd0;
      end
      else begin
	 if (shifter_rst == 1'b1) begin
	    shifter <= {tx_data_reg, 2'b01};
	    bit_counter <= 4'd0;
	 end
	 else if (shifter_rst == 1'b0 && baud_clk == 1'b1) begin
	    shifter <= {1'b1, shifter[9:1]};
	    bit_counter <= bit_counter + 4'd1;
	 end
	 tx <= shifter[0];
      end
   end

//////////////////////////////////////////////////////////////////////////////////
// === CONTROL ===
//////////////////////////////////////////////////////////////////////////////////

   always @(posedge clk) begin
      if (rst) state <= IDLE;
      else state <= next_state;
   end

   always @(*) begin
      next_state = state;
      baud_clk_en = 1'b0;
      case (state) 
	IDLE : begin
	   shifter_rst = 1'b0;
	   tx_ready = 1'b1;
	   if (tx_start == 1'b1) next_state = START;
	end
	START : begin
	   shifter_rst = 1'b1;
	   baud_clk_en = 1'b1;
	   tx_ready = 1'b0;
	   next_state = TRANS;
	end
	TRANS : begin
	   shifter_rst = 1'b0;
	   baud_clk_en = 1'b1;
	   tx_ready = 1'b0;
	   if (bit_counter == 4'd11) next_state = IDLE;
	end
	default : begin
	   shifter_rst = 1'b0;
	   tx_ready = 1'b0;
	end
      endcase
   end

endmodule
