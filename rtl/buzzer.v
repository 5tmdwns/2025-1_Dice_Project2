`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2025 08:32:27 PM
// Design Name: 
// Module Name: buzzer
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


module buzzer(
	      input wire 	clk, // 12MHz clock
	      input wire 	rst, // Active high reset
	      input wire [15:0] distance, // Distance in cm
	      input wire 	valid, // Valid distance update
	      output reg 	buzzer          // PWM output to buzzer
	      );

   reg [31:0] 			tone_cnt = 0;
   reg [31:0] 			tone_period = 15000; // 800Hz → 12MHz / 800Hz = 15000

   reg [31:0] 			beep_cnt = 0;
   reg [31:0] 			beep_period = 0;
   reg 				tone_en = 0;

   // Update beep period every time distance is updated
   always @(posedge clk) begin
      if (rst) begin
         beep_period <= 0;
      end else if (valid) begin
         if (distance < 10)
           beep_period <= 100000;   // very fast beep (~8ms)
         else if (distance < 15)
           beep_period <= 300000;   // ~25ms
         else if (distance < 20)
           beep_period <= 600000;   // 50ms
         else if (distance < 25)
           beep_period <= 1200000;  // 100ms
         else if (distance < 30)
           beep_period <= 2400000;  // 200ms
         else
           beep_period <= 32'hFFFFFFFF; // disable
      end
   end

   // Beep ON/OFF timing control
   always @(posedge clk) begin
      if (rst) begin
         beep_cnt <= 0;
         tone_en <= 0;
      end else if (beep_period == 32'hFFFFFFFF) begin
         tone_en <= 0;               // no sound
         beep_cnt <= 0;
      end else begin
         beep_cnt <= beep_cnt + 1;
         if (beep_cnt >= beep_period) begin
            beep_cnt <= 0;
            tone_en <= ~tone_en;    // toggle ON/OFF
         end
      end
   end

   // 800Hz tone generation
   always @(posedge clk) begin
      if (rst) begin
         tone_cnt <= 0;
         buzzer <= 0;
      end else if (!tone_en) begin
         tone_cnt <= 0;
         buzzer <= 0;
      end else begin
         tone_cnt <= tone_cnt + 1;
         if (tone_cnt < tone_period / 2)
           buzzer <= 1;
         else if (tone_cnt < tone_period)
           buzzer <= 0;
         else
           tone_cnt <= 0;
      end
   end
endmodule

