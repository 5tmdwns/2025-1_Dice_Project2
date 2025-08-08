`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2025 09:29:19 PM
// Design Name: 
// Module Name: uart_rx
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


module uart_rx(
	input wire clk,
	input wire rst,
	input wire rx,
	output reg rx_done,
	output reg [7:0] rx_data
    );

	wire baud_clk;

	reg baud_clk_en, bit_counter_rst, load, rx_temp;
	reg [1:0] state, next_state;
	reg [3:0] bit_counter;
	reg [9:0] raw_rx_data;

	localparam IDLE = 2'b00;
	localparam RECEIVE = 2'b01;
	localparam LOAD = 2'b10;
	localparam DONE = 2'b11;

	baudgen_rx
	baudgen_rx_inst (
		.rst(rst),
		.clk(clk),
		.baud_clk_en(baud_clk_en),
		.baud_clk(baud_clk));

//////////////////////////////////////////////////////////////////////////////////
// === DATAPATH ===
//////////////////////////////////////////////////////////////////////////////////

	always @(posedge clk) begin
		if (rst) begin
			state <= IDLE;
			bit_counter <= 4'd0;
			rx_data <= 8'd0;
			rx_temp <= 1'b1;
			raw_rx_data <= 10'd0;
			end 
		else begin
			rx_temp <= rx;
			state <= next_state;

			// bit counter
			if (bit_counter_rst) bit_counter <= 4'd0;
			else if (baud_clk) bit_counter <= bit_counter + 4'd1;

			// raw_rx_data shift
			if (baud_clk) raw_rx_data <= {rx_temp, raw_rx_data[9:1]};
			
			// load raw_rx_data to rx_data
			if (load) rx_data <= raw_rx_data[8:1];
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
		case (state)
			IDLE : begin
				baud_clk_en = 1'b0;
				bit_counter_rst = 1'b1;
				load = 1'b0;
				rx_done = 1'b0;
				if (rx_temp == 1'b0) next_state = RECEIVE;
			end
			RECEIVE : begin
				baud_clk_en = 1'b1;
				bit_counter_rst = 1'b0;
				load = 1'b0;
				rx_done = 1'b0;
				if (bit_counter == 4'd10) next_state = LOAD;
			end
			LOAD : begin
				baud_clk_en = 1'b0;
				bit_counter_rst = 1'b0;
				load = 1'b1;
				rx_done = 1'b0;
				next_state = DONE;
			end
			DONE : begin
				baud_clk_en = 1'b0;
				bit_counter_rst = 1'b0;
				load = 1'b0;
				rx_done = 1'b1;
				next_state = IDLE;
			end
			default : begin
				baud_clk_en = 1'b0;
				bit_counter_rst = 1'b0;
				load = 1'b0;
				rx_done = 1'b0;
			end
		endcase
	end
endmodule
