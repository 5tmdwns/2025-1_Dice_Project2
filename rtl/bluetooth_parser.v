`timescale 1ns / 1ps

module bluetooth_parser(
    input  wire        clk,
    input  wire        rst,
    input  wire        rx_bluetooth,
    input  wire        req_husky_done,
    output reg         req_husky_arrow_en,
    output reg  [2:0]  man_motor_state,
    output reg  [3:0]  led
);

    localparam 
        MAN_STOP     = 3'b000,
        MAN_FORWARD  = 3'b001,
        MAN_BACKWARD = 3'b010,
        MAN_LEFT     = 3'b011,
        MAN_RIGHT    = 3'b100,
        AUTO         = 3'b110;

    localparam [22:0] TIMER_MAX = 23'd1_499_999;

    wire        rx_bluetooth_done;
    wire [7:0]  rx_bluetooth_data;
    reg  [7:0]  prev_rx_bluetooth_data;

    reg         periodic_mode;
    reg [22:0]  timer_cnt;

    uart_rx uart_rx_bluetooth_inst (
        .clk      (clk),
        .rst      (rst),
        .rx       (rx_bluetooth),
        .rx_done  (rx_bluetooth_done),
        .rx_data  (rx_bluetooth_data)
    );

    always @(posedge clk) begin
        if (rst) begin
            periodic_mode          <= 1'b0;
            man_motor_state        <= MAN_STOP;
            prev_rx_bluetooth_data <= 8'd0;
        end else begin
             if (rx_bluetooth_done) begin
                case (rx_bluetooth_data)
                    8'h46: man_motor_state <= MAN_FORWARD;
                    8'h52: man_motor_state <= MAN_RIGHT;
                    8'h42: man_motor_state <= MAN_BACKWARD;
                    8'h4C: man_motor_state <= MAN_LEFT;
                    8'h53: man_motor_state <= MAN_STOP;
                    8'h56: man_motor_state <= man_motor_state;
                    8'h41: 
                        if (!periodic_mode) begin
                            periodic_mode <= 1'b1;
                            man_motor_state <= AUTO;
                        end else begin
                            periodic_mode <= 1'b0;
                            man_motor_state <= MAN_STOP;
                        end 
                    default: if (!periodic_mode)
                                 man_motor_state <= MAN_STOP;
                endcase
                prev_rx_bluetooth_data <= rx_bluetooth_data;
            end
        end
    end

    always @(posedge clk) begin
        if (rst)
            timer_cnt <= 23'd0;
        else if (!periodic_mode)
            timer_cnt <= 23'd0;
        else if (timer_cnt == TIMER_MAX)
            timer_cnt <= 23'd0;
        else
            timer_cnt <= timer_cnt + 1;
    end

    always @(posedge clk) begin
        if (rst)
            req_husky_arrow_en <= 1'b0;
        else begin
            req_husky_arrow_en <= 1'b0;
            if (periodic_mode && (timer_cnt == TIMER_MAX))
                req_husky_arrow_en <= 1'b1;
            if (rx_bluetooth_done && rx_bluetooth_data == 8'h56 && prev_rx_bluetooth_data != 8'h56)
                req_husky_arrow_en <= 1'b1;
        end
    end

    always @(posedge clk) begin
        if (rst)
            led <= 4'd0;
        else begin
            if (periodic_mode)
                led <= 4'b0111;
            else 
                led <= 4'b0000;
            if (rx_bluetooth_done) begin
                case (rx_bluetooth_data)
                    8'h46: led <= 4'b1000;
                    8'h52: led <= 4'b0001;
                    8'h42: led <= 4'b0100;
                    8'h4C: led <= 4'b0010;
                    8'h53: led <= 4'b0000;
                    8'h56: led <= 4'b0011;
                    default: led <= 4'b0000;
                endcase
            end
        end
    end

endmodule
