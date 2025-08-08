`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2025 08:32:27 PM
// Design Name: 
// Module Name: xadc_parser
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


module xadc_parser (
		    input wire clk, // 100MHz system clock
		    input wire rst, // Active high reset
		    input wire vauxp5, // Analog input VAUX5_P
		    input wire vauxn5, // Analog input VAUX5_N
		    output reg pwm_r, // Red channel PWM output
		    output reg pwm_g, // Green channel PWM output
		    output reg pwm_b             // Blue channel PWM output
		    );

   // === XADC signals ===
   wire [15:0] 		       adc_data;
   wire 		       drdy;
   reg [6:0] 		       daddr = 7'h15;      // VAUX5 channel address
   reg [15:0] 		       di_drp = 16'd0;
   reg 			       den = 1'd0;
   reg 			       dwe = 1'd0;
   reg 			       vp_in = 1'd0;
   reg 			       vn_in = 1'd0;
   wire 		       busy, eoc, eos, alarm;
   wire [4:0] 		       channel_out, muxaddr;

   // DRP enable pulse generator (every ~60,000 cycles)
   reg [15:0] 		       counter;
   always @(posedge clk) begin
      if (rst) begin
         den <= 1'd0;
         counter <= 16'd0;
      end else begin
         if (counter == 16'd0) begin
            den <= 1'd1;
            counter <= counter + 16'd1;
         end else if (counter == 16'd1) begin
            den <= 1'd0;
            counter <= counter + 16'd1;
         end else if (counter == 16'd60000) begin
            counter <= 16'd0;
         end else begin
            counter <= counter + 16'd1;
         end
      end
   end

   // === adc_data Parsing ===
   reg [7:0] duty;            // 8-bit duty (0~255)
   wire [17:0] scaled_wire;
   assign scaled_wire = (adc_data[15:4] - 12'd880) * 12'd271;

   always @(posedge clk) begin
      if (rst)
        duty <= 8'd0;
      else if (drdy) begin
         if (adc_data[15:4] <= 12'd880)
           duty <= 8'd0;
         else if (adc_data[15:4] >= 12'd1360)
           duty <= 8'd255;
         else begin
	    duty <= scaled_wire >> 9;
         end
      end

   end

   // PWM counter (free running)
   reg [7:0] pwm_counter;
   always @(posedge clk) begin
      if (rst)
        pwm_counter <= 8'd0;
      else
        pwm_counter <= pwm_counter + 8'd1;
   end

   // Output PWM signals for R, G, B (equal for white)
   always @(posedge clk) begin
      if (rst) begin
         pwm_r <= 1'd0;
         pwm_g <= 1'd0;
         pwm_b <= 1'd0;
      end else begin
         pwm_r <= (pwm_counter < duty) ? 1'd1 : 1'd0;
         pwm_g <= (pwm_counter < duty) ? 1'd1 : 1'd0;
         pwm_b <= (pwm_counter < duty) ? 1'd1 : 1'd0;
      end
   end

   // === Instantiate XADC Wizard IP core ===
   xadc_wiz_0 xadc_inst (
			 .daddr_in(daddr),
			 .dclk_in(clk),
			 .den_in(den),
			 .di_in(di_drp),
			 .dwe_in(dwe),
			 .reset_in(rst),
			 .vauxp5(vauxp5),
			 .vauxn5(vauxn5),
			 .vp_in(vp_in),
			 .vn_in(vn_in),
			 .busy_out(busy),
			 .channel_out(channel_out),
			 .do_out(adc_data),
			 .drdy_out(drdy),
			 .eoc_out(eoc),
			 .eos_out(eos),
			 .alarm_out(alarm),
			 .muxaddr_out(muxaddr)
			 );

endmodule

