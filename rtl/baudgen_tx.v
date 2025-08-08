`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2025 08:35:04 PM
// Design Name: 
// Module Name: baudgen_tx
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


module baudgen_tx #(
		    parameter BAUD_DIV = 1250
		    )(
		      input wire  rst,
		      input wire  clk,
		      input wire  baud_clk_en,
		      output wire baud_clk
		      );

   localparam N = $clog2(BAUD_DIV);

   reg [N-1:0] 			  divide_cnt = 0;

   assign baud_clk = (divide_cnt == 0) ? baud_clk_en : 0;

   always @(posedge clk) begin
      if (rst) divide_cnt <= 0;
      else begin
	 if (baud_clk_en) divide_cnt <= (divide_cnt == BAUD_DIV - 1) ? 0 : divide_cnt + 1;
	 else divide_cnt <= BAUD_DIV - 1;
      end
   end

endmodule
