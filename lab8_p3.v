`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2024 03:22:11 PM
// Design Name: 
// Module Name: upCounter_multiDigitDisplay
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


module upCounter_multiDigitDisplay(
    input clk,
    //input reset,
    output [3:0]an,
    output [6:0]cat
    );
    
    reg[15:0]stat_bcd = 16'b0;
    
    wire en;
    wire done;
    wire [11:0]count;
    wire [15:0]bcd_d_out;
    wire rdy;
    
    up_counter_12bit UUT2(clk, en, done, count);
    
    binary_to_bcd UUT3(clk, done, count, bcd_d_out, rdy);
    
    multi_seg_driver UUT4(clk, stat_bcd, an, cat);
    
    clock_divider UUT(clk, en);
    
    always @(posedge clk)
        begin
            if(rdy)
                begin
                    stat_bcd<=bcd_d_out;
                end
        end 
    
endmodule

//module clock_divider(clock_in,clock_out);
//input clock_in; 
//output reg clock_out; 
//reg[1:0] counter=2'd0;


//initial begin
//    clock_out = 1'b0;
//end
//always @(posedge clock_in)
//begin
// clock_out <= counter[1];
// counter <= counter + 2'd1; 
//end
//endmodule

module clock_divider(clock_in,en
    );
input clock_in; // input clock on FPGA
output reg en; // output clock after dividing the input clock by divisor

parameter CTR_MAX = 23'd5000000;
parameter CTR_WIDTH = 23;
reg[CTR_WIDTH-1:0] counter=0;

always @(posedge clock_in)
begin
 counter <= en ? 0 : counter + 1;
end
always @* begin
    en = (counter==CTR_MAX);
end
endmodule


module up_counter_12bit(
    input wire clk,
    input en,
    output reg done,
    output reg [11:0] count = 0
);

    always @(posedge clk) begin
        done <= 0;
        if (en)
        begin
            count <= count + 1;
            done <= 1;
        end
    end

endmodule

//module up_counter_12bit(

//input clk,
//input en,
//output done,
//output [11:0] bin_cnt);

//parameter c_reg_size = 34;

//reg [c_reg_size -1:0] count = 0;
//reg fin = 0;
//reg old_b = 0;


// always @(posedge clk)
//    begin
//        if(en) begin
//        count <= count+1;
//            if((old_b && !count[c_reg_size-12]) || (!old_b && count[c_reg_size-12]))
//                begin
//                fin <=1;
//                end
//            else
//                begin
//                fin <=0;
//                end
//             old_b <=count[c_reg_size-12];
//         end
//     end
       
     
//assign bin_cnt =  count[c_reg_size-1: c_reg_size-12];
//assign done = fin;   
    
    
    
//endmodule


module binary_to_bcd(   
    input           clk,
    input           en,
    input   [11:0]  bin_d_in,
    output  [15:0]  bcd_d_out,
   output          rdy
    );
    
    //State variables
    parameter IDLE      = 3'b000;
    parameter SETUP      = 3'b001;
    parameter ADD      = 3'b010;
    parameter SHIFT      = 3'b011;
    parameter DONE      = 3'b100;
    
    
    //declare all necessary registers 
	//reg [11:0]  bin_data    = 0;
	reg [27:0] bcd_data = 0;
	reg [2:0] state = 0;
	reg busy = 0;
	reg [3:0] sh_counter = 0;
	reg [1:0] add_counter = 0;
	reg result_rdy = 0;
    
    
    
    always @(posedge clk)
        begin
        if(en)
            begin
                if(~busy)
                    begin
                    bcd_data    <= {16'b0, bin_d_in};
                    state       <= SETUP;
                    end
            end
        
        case(state)
        
            IDLE:
                begin
                    result_rdy  <= 0;
                    busy        <= 0;
                end
                
            SETUP:
                begin
                busy        <= 1;
                state       <= ADD;
                end
                    
            ADD:
                begin
                    case(add_counter)
                    0:
                    begin
                        if(bcd_data[15:12] > 4)
                            begin
                                bcd_data[27:12] <= bcd_data[27:12] + 3;
                            end
                            add_counter <= add_counter + 1;
                    end
                    1:
                    begin
                        if(bcd_data[19:16] > 4)
                            begin
                                bcd_data[27:16] <= bcd_data[27:16] + 3;
                            end
                            add_counter <= add_counter + 1;
                    end
                    2:
                    begin
                        if((add_counter == 2) && (bcd_data[23:20] > 4))
                            begin
                                bcd_data[27:20] <= bcd_data[27:20] + 3;
                            end
                            add_counter <= add_counter + 1;
                    end
                    3:
                    begin
                        if((add_counter == 3) && (bcd_data[27:24] > 4))
                            begin
                                bcd_data[27:24] <= bcd_data[27:24] + 3;
                            end
                            add_counter <= 0;
                            state   <= SHIFT;
                    end
                    endcase
				end 

                
            SHIFT:
                begin
                sh_counter  <= sh_counter + 1;
                bcd_data    <= bcd_data << 1;
                
                if(sh_counter == 11)
                    begin
                    sh_counter  <= 0;
                    state       <= DONE;
                    end
                else
                    begin
                    state   <= ADD;
                    end

                end
 
            
            DONE:
                begin
				//result_rdy should be and next state should be IDLE
                    result_rdy <= 1;
                    state <= IDLE;
                end
            default:
                begin
                state <= IDLE;
                end
            
            endcase
            
        end
		//Final output declaration and it will be bcd_data[27:12] and rdy will b1 
		assign bcd_d_out = bcd_data[27:12];
		assign rdy = result_rdy;
endmodule

module multi_seg_driver(clk,i0,sseg_a,sseg_c);
input clk;
input [15:0] i0;
output [3:0] sseg_a;
output [6:0] sseg_c;

wire en;
wire [3:0] anode, bcd_seg;

anode_gen UUT1(clk, en, anode);

Mux4_to_1 UUT2(anode, bcd_seg, en, i0, sseg_a);

Decoder_7_SEG UUT3(.clk(clk), .bcd(bcd_seg), .SEG(sseg_c));

endmodule

module anode_gen(clk, en, anode);
input clk;
output reg en;

output [3:0] anode = 4'b1000;
reg [3:0] bcd_seg = 4'b0000;
reg [3:0] anode = 4'b1000;

parameter g_s = 5;
parameter gt = 4;
reg [g_s-1:0] g_count = 0;

    always @(posedge clk)
    begin
    g_count = g_count +1;
        if(g_count == 0)
            begin
            if(anode == 4'b0001)
                begin
                anode = 4'b1000;
                end
            else
                begin
                anode = anode >>1;
                end
            end
    end
    always @(posedge clk)
    begin
        if (&g_count[g_s-1:gt])
            begin
            en = 1'b1;
            end
        else
            en = 1'b0;
    end
endmodule

module Decoder_7_SEG(clk, bcd, SEG);
    input clk;
    input [3:0] bcd;
    output reg [6:0] SEG;
    
    always @(posedge clk)
    begin
        case(bcd)
            0 : SEG = 7'b1000000;
            1 : SEG = 7'b1111001;
            2 : SEG = 7'b0100100;
            3 : SEG = 7'b0110000;
            4 : SEG = 7'b0011001;
            5 : SEG = 7'b0010010;
            6 : SEG = 7'b0000010;
            7 : SEG = 7'b1111000;
            8 : SEG = 7'b0000000;
            9 : SEG = 7'b0010000;
            default : SEG = 7'b1111111;
        endcase
    end
 endmodule 

module Mux4_to_1(anode, bcd_seg, en, i0, sseg_a);
    input en;
    input [3:0] anode;
    input [15:0] i0;
    output [3:0] sseg_a;
    output reg [3:0] bcd_seg;
    
    always @(*)
    begin
        if(en)
        begin
            case(anode)
                4'b1000 : bcd_seg = i0[15:12];
                4'b0100 : bcd_seg = i0[11:8];
                4'b0010 : bcd_seg = i0[7:4];
                4'b0001 : bcd_seg = i0[3:0];
                default : bcd_seg = 4'b1111;
            endcase
        end
    end
    assign sseg_a = ~anode;
 endmodule