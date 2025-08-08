`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2025 08:32:27 PM
// Design Name: 
// Module Name: driving_algorithm
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


module driving_algorithm(
			 input wire 	   clk,
			 input wire 	   rst,
			 input wire [15:0] origin_x,
			 input wire [15:0] target_x,
			 input wire [15:0] origin_y,
			 input wire [15:0] target_y,
			 output reg [2:0]  auto_motor_state
			 );

   localparam [2:0]
     AUTO_STOP     = 3'b000,
     AUTO_FORWARD  = 3'b001,
     AUTO_BACKWARD = 3'b010,
     AUTO_LEFT     = 3'b011,
     AUTO_RIGHT    = 3'b100;

   localparam [22:0] TURN_CYCLES  = 23'd499_999;
   localparam [22:0] PAUSE_CYCLES = 23'd899_999;
   localparam [22:0] BACK_CYCLES  = 23'd1_999_999;

   wire signed [16:0] 			   dx = $signed(target_x) - $signed(origin_x);
   wire signed [16:0] 			   dy = $signed(target_y) - $signed(origin_y);

   wire 				   forward_enable  = (target_x > 16'd100 && target_x < 16'd200 && target_y <= 16'd130);
   wire 				   backward_enable = (target_x > 16'd100 && target_x < 16'd200 && target_y > 16'd130 && target_y < 16'd200);
   wire 				   left_enable     = (target_x < 16'd101);
   wire 				   right_enable    = (target_x > 16'd199 || suspicious_corner);
   wire 				   suspicious_corner = ((target_y > 16'd200 && target_y < 16'd240) || (dx > -30 && dx < 0 && dy > -30 && dy < 0));

   reg 					   turn_phase;
   reg [22:0] 				   cnt;

   always @(posedge clk) begin
      if (rst) begin
         turn_phase       <= 1'b1;
         cnt              <= 23'd0;
         auto_motor_state <= AUTO_STOP;
      end
      else if (forward_enable) begin
         turn_phase       <= 1'b1;
         cnt              <= 23'd0;
         auto_motor_state <= AUTO_FORWARD;
      end
      else if (backward_enable) begin
         if (cnt < BACK_CYCLES) begin
            cnt              <= cnt + 1;
            auto_motor_state <= AUTO_BACKWARD;
         end else begin
            cnt              <= 23'd0;
            auto_motor_state <= AUTO_STOP;
         end
      end
      else if (left_enable || right_enable) begin
         if (turn_phase) begin
            if (cnt < TURN_CYCLES) begin
               cnt              <= cnt + 1;
               auto_motor_state <= left_enable ? AUTO_LEFT : AUTO_RIGHT;
            end else begin
               turn_phase       <= 1'b0;
               cnt              <= 23'd0;
               auto_motor_state <= AUTO_STOP;
            end
         end else begin
            if (cnt < PAUSE_CYCLES) begin
               cnt              <= cnt + 1;
               auto_motor_state <= AUTO_STOP;
            end else begin
               turn_phase       <= 1'b1;
               cnt              <= 23'd0;
               auto_motor_state <= left_enable ? AUTO_LEFT : AUTO_RIGHT;
            end
         end
      end
      else begin
         turn_phase       <= 1'b1;
         cnt              <= 23'd0;
         auto_motor_state <= AUTO_STOP;
      end
   end


endmodule
