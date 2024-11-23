`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2024 03:43:57 PM
// Design Name: 
// Module Name: upCounter_multiDigitDisplay_tb
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


module upCounter_multiDigitDisplay_tb();
    reg clk;
   // reg reset;
    
    wire [3:0]an;
    wire [6:0]cat;
    
    upCounter_multiDigitDisplay uut(.clk(clk),  .an(an), .cat(cat));
    
    // Clock generation
    always #5 clk = ~clk; // 10ns clock period
    
    initial begin
        // Initialize clock, reset, and control signals
        clk = 0;
//        reset = 1; #300
//        reset = 0;
        
        #2000;
        $finish;
    end
    
endmodule
