`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2024 01:45:21 PM
// Design Name: 
// Module Name: binary_to_bcd_tb
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

module tb_binary_to_bcd;

    // Inputs
    reg clk;
    reg en;
    reg [11:0] bin_d_in;

    // Outputs
    wire [15:0] bcd_d_out;
    wire rdy;

    // Instantiate the binary_to_bcd module
    binary_to_bcd uut (
        .clk(clk),
        .en(en),
        .bin_d_in(bin_d_in),
        .bcd_d_out(bcd_d_out),
        .rdy(rdy)
    );

    // Clock generation
    always #5 clk = ~clk; // 10ns clock period

    // Initialize inputs and run test cases
    initial begin
        // Initialize clock, reset, and control signals
        clk = 0;
        
        bin_d_in = 12'b0;
        en = 1;
        #20;
        en = 0;
        #620;
        
        bin_d_in = 12'd1234;
        en = 1;
        #20;
        en = 0;
        #620;
        
        bin_d_in = 12'd2234;
        en = 1;
        #20;
        en = 0;
        #1340;

       bin_d_in = 12'd2535;
        en = 1;
        #20;
        en = 0;
        #1340;

        $stop;
    end

endmodule

