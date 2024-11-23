`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2024 01:39:57 PM
// Design Name: 
// Module Name: up_counter_12bit_tb
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


module up_counter_12bit_tb;
    reg clk;
    reg reset;

    wire [11:0] count;

    up_counter_12bit uut (
        .clk(clk),
        .reset(reset),
        .count(count)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #10;
        
        reset = 0;
        
        #41000;

        reset = 1;
        #10;
        reset = 0;
        
        #100;
        
        $stop;
    end

endmodule
