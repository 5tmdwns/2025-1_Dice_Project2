`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2025 08:34:19 PM
// Design Name: 
// Module Name: top
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


module top(
	   input wire 	     clk,
	   input wire 	     rst,
	   input wire 	     btn0,
	   input wire 	     rx_bluetooth,
	   input wire 	     rx_husky,
	   input wire 	     vauxp5,
	   input wire 	     vauxn5,
	   input wire 	     echo,
	   output wire 	     tx_bluetooth,
	   output wire 	     tx_husky,
	   output wire 	     tx_pc,
	   output wire 	     A_1A,
	   output wire 	     A_1B,
	   output wire 	     B_1A,
	   output wire 	     B_1B,
	   output wire [3:0] led,
	   output wire 	     right_pwm_r,
	   output wire 	     right_pwm_g,
	   output wire 	     right_pwm_b,
	   output wire 	     left_pwm_r,
	   output wire 	     left_pwm_g,
	   output wire 	     left_pwm_b,
	   output wire 	     trig,
	   output wire 	     buzzer
	   );

   assign tx_pc = rx_husky;
   assign right_pwm_r = pwm_r;
   assign right_pwm_g = pwm_g;
   assign right_pwm_b = pwm_b;
   assign left_pwm_r = pwm_r;
   assign left_pwm_g = pwm_g;
   assign left_pwm_b = pwm_b;
   
   wire 		     req_husky_start;
   wire 		     req_husky_done;
   wire 		     req_husky_arrow_en;
   wire [7:0] 		     req_husky_cmd;
   wire [7:0] 		     req_husky_data_len;
   wire 		     req_bluetooth_done;
   wire 		     req_bluetooth_start;
   wire [7:0] 		     req_bluetooth_data;
   wire [2:0] 		     man_motor_state;
   wire [2:0] 		     auto_motor_state;
   wire [15:0] 		     origin_x;
   wire [15:0] 		     target_x;
   wire [15:0] 		     origin_y;
   wire [15:0] 		     target_y;
   wire [15:0] 		     distance;
   wire 		     valid;
   wire 		     obstacle_stop;
   


   husky_cmd_set 
     husky_cmd_set_inst (
			 .clk(clk),
			 .rst(rst),
			 .btn0(btn0),
			 .req_husky_done(req_husky_done),
			 .req_husky_arrow_en(req_husky_arrow_en),
			 .req_husky_start(req_husky_start),
			 .req_husky_cmd(req_husky_cmd),
			 .req_husky_data_len(req_husky_data_len));

   husky_request
     husky_request_inst (
			 .clk(clk),
			 .rst(rst),
			 .req_husky_start(req_husky_start),
			 .req_husky_cmd(req_husky_cmd),
			 .req_husky_data_len(req_husky_data_len),
			 .req_husky_done(req_husky_done),
			 .tx_husky(tx_husky));

   husky_parser
     husky_parser_inst (
			.clk(clk),
			.rst(rst),
			.rx_husky(rx_husky),
			.req_bluetooth_done(req_bluetooth_done),
			.req_bluetooth_start(req_bluetooth_start),
			.req_bluetooth_data(req_bluetooth_data),
			.origin_x(origin_x),
			.target_x(target_x),
			.origin_y(origin_y),
			.target_y(target_y));
   
   driving_algorithm
     driving_algo_inst (
			.clk(clk),
			.rst(rst),
			.origin_x(origin_x),
			.target_x(target_x),
			.origin_y(origin_y),
			.target_y(target_y),
			.auto_motor_state(auto_motor_state));

   bluetooth_request
     bluetooth_request_inst (
			     .clk(clk),
			     .rst(rst),
			     .req_bluetooth_start(req_bluetooth_start),
			     .req_bluetooth_data(req_bluetooth_data),
			     .req_bluetooth_done(req_bluetooth_done),
			     .tx_bluetooth(tx_bluetooth));

   bluetooth_parser
     bluetooth_parser_inst (
			    .clk(clk),
			    .rst(rst),
			    .rx_bluetooth(rx_bluetooth),
			    .req_husky_done(req_husky_done),
			    .req_husky_arrow_en(req_husky_arrow_en),
			    .man_motor_state(man_motor_state),
			    .led(led));

   motor_controller
     motor_controller_inst (
			    .clk(clk),
			    .rst(rst),
			    .man_motor_state(man_motor_state),
			    .auto_motor_state(auto_motor_state),
				 .obstacle_stop(obstacle_stop),
			    .A_1A(A_1A),
			    .A_1B(A_1B),
			    .B_1A(B_1A),
			    .B_1B(B_1B));

   buzzer
     buzzer_inst (
		  .clk(clk),
		  .rst(rst),
		  .distance(distance),
		  .valid(valid),
		  .buzzer(buzzer));
   
   ultrasonic
     ultrasonic_inst (
		      .clk(clk),
		      .rst(rst),
		      .trig(trig),
		      .echo(echo),
		      .distance(distance),
		      .valid(valid),
		      .obstacle_stop(obstacle_stop));

   xadc_parser
     xadc_parser (
		  .clk(clk),
		  .rst(rst),
		  .vauxp5(vauxp5),
		  .vauxn5(vauxn5),
		  .pwm_r(pwm_r),
		  .pwm_g(pwm_g),
		  .pwm_b(pwm_b));


endmodule
