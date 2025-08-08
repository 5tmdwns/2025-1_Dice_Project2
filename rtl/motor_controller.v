`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2025 08:34:19 PM
// Design Name: 
// Module Name: motor_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: PWM added for AUTO mode
// 
//////////////////////////////////////////////////////////////////////////////////

module motor_controller(
			input wire 	 clk,
			input wire 	 rst,
			input wire [2:0] man_motor_state,
			input wire [2:0] auto_motor_state,
			input wire 	 obstacle_stop,
			output reg 	 A_1A,
			output reg 	 A_1B,
			output reg 	 B_1A,
			output reg 	 B_1B
			);

   // manual mode states
   localparam MAN_STOP    = 3'b000;
   localparam MAN_FORWARD = 3'b001;
   localparam MAN_BACKWARD= 3'b010;
   localparam MAN_LEFT    = 3'b011;
   localparam MAN_RIGHT   = 3'b100;
   localparam AUTO        = 3'b110;

   // auto mode states
   localparam AUTO_STOP    = 3'b000;
   localparam AUTO_FORWARD = 3'b001;
   localparam AUTO_BACKWARD= 3'b010;
   localparam AUTO_LEFT    = 3'b011;
   localparam AUTO_RIGHT   = 3'b100;

   // PWM counter
   reg [7:0] 				 counter;

   always @(posedge clk or posedge rst) begin
      if (rst)
        counter <= 8'd0;
      else
        counter <= (counter == 8'd255) ? 8'd0 : counter + 8'd1;
   end

   // control logic
   always @(*) begin
      case (man_motor_state)
        MAN_STOP : begin
           A_1A = 1'b0;
           A_1B = 1'b0;
           B_1A = 1'b0;
           B_1B = 1'b0;
        end
        MAN_FORWARD : begin
           A_1A = 1'b1;
           A_1B = 1'b0;
           B_1A = 1'b1;
           B_1B = 1'b0;
        end
        MAN_BACKWARD : begin
           A_1A = 1'b0;
           A_1B = 1'b1;
           B_1A = 1'b0;
           B_1B = 1'b1;
        end
        MAN_LEFT : begin
           A_1A = 1'b0;
           A_1B = 1'b1;
           B_1A = 1'b1;
           B_1B = 1'b0;
        end
        MAN_RIGHT : begin
           A_1A = 1'b1;
           A_1B = 1'b0;
           B_1A = 1'b0;
           B_1B = 1'b1;
        end
        AUTO : begin
	   if (obstacle_stop) begin
	      // Immediate stop when obstacle detected
	      A_1A = 1'b0;
	      A_1B = 1'b0;
	      B_1A = 1'b0;
	      B_1B = 1'b0;
	   end
	   else begin
              case (auto_motor_state)
		AUTO_STOP : begin
                   A_1A = 1'b0;
                   A_1B = 1'b0;
                   B_1A = 1'b0;
                   B_1B = 1'b0;
		end
		AUTO_FORWARD : begin
                   A_1A = (counter < 8'd185) ? 1'b1 : 1'b0;
                   A_1B = 1'b0;
                   B_1A = (counter < 8'd185) ? 1'b1 : 1'b0;
                   B_1B = 1'b0;
		end
		AUTO_BACKWARD : begin
                   A_1A = 1'b0;
                   A_1B = (counter < 8'd180) ? 1'b1 : 1'b0;
                   B_1A = 1'b0;
                   B_1B = (counter < 8'd180) ? 1'b1 : 1'b0;
		end
		AUTO_LEFT : begin
                   A_1A = 1'b0;
                   A_1B = (counter < 8'd200) ? 1'b1 : 1'b0;
                   B_1A = (counter < 8'd200) ? 1'b1 : 1'b0;
                   B_1B = 1'b0;
		end
		AUTO_RIGHT : begin
                   A_1A = (counter < 8'd200) ? 1'b1 : 1'b0;
                   A_1B = 1'b0;
                   B_1A = 1'b0;
                   B_1B = (counter < 8'd200) ? 1'b1 : 1'b0;
		end
		default : begin
                   A_1A = 1'b0;
                   A_1B = 1'b0;
                   B_1A = 1'b0;
                   B_1B = 1'b0;
		end
              endcase
	   end
        end
        default : begin
           A_1A = 1'b0;
           A_1B = 1'b0;
           B_1A = 1'b0;
           B_1B = 1'b0;
        end
      endcase
   end

endmodule
