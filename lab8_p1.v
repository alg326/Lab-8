`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2024 01:38:14 PM
// Design Name: 
// Module Name: up_counter_12bit
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


module up_counter_12bit(
    input wire clk,
    input wire reset,
    output reg [11:0] count
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            count <= 12'd0;
        else if (count == 12'd4095) 
            count <= 12'd0;
        else
            count <= count + 1;
    end

endmodule
