`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2025 01:22:36 AM
// Design Name: 
// Module Name: husky_cmd_set
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


module husky_cmd_set(
		     input wire       clk,
		     input wire       rst,
		     input wire       btn0,
		     input wire       req_husky_done,
		     input wire       req_husky_arrow_en,
		     output reg       req_husky_start,
		     output reg [7:0] req_husky_cmd,
		     output reg [7:0] req_husky_data_len
		     );

   reg 				      btn0_sync0, btn0_sync1, btn0_prev;

   always @(posedge clk) begin
      if (rst) begin
	 btn0_sync0 <= 1'b0;
	 btn0_sync1 <= 1'b0;
	 btn0_prev <= 1'b0;
      end
      else begin
	 btn0_sync0 <= btn0;
	 btn0_sync1 <= btn0_sync0;
	 btn0_prev <= btn0_sync1;
      end
   end

   assign btn0_rise = ~btn0_prev & btn0_sync1;


   //////////////////////////////////////////////////////////////////////////////////
  // Command Set
   //////////////////////////////////////////////////////////////////////////////////

   localparam CMD_NONE = 8'h00;
   localparam CMD_REQUEST_KNOCK = 8'h2C;
   localparam CMD_REQUEST_ARROW_LEARNED = 8'h25;

   always @(posedge clk) begin
		if (rst) begin
			req_husky_start <= 1'b0;
			req_husky_cmd <= CMD_NONE;
			req_husky_data_len <= 8'h00;
      end
      else begin
            if (btn0_rise) begin
                req_husky_start <= 1'b1;
				req_husky_cmd <= CMD_REQUEST_KNOCK;
				req_husky_data_len <= 8'h00;
            end
			if (req_husky_arrow_en) begin // COMMAND_REQUEST_ARROW_LEARNED
				req_husky_start <= 1'b1;
				req_husky_cmd <= CMD_REQUEST_ARROW_LEARNED;
				req_husky_data_len <= 8'h00;
			end
			else if (req_husky_done) begin
				req_husky_start <= 1'b0;
				req_husky_cmd <= CMD_NONE;
				req_husky_data_len <= 8'h00;
			end
      end
	end

endmodule
