`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2024 01:44:49 PM
// Design Name: 
// Module Name: binary_to_bcd
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


//module binary_to_bcd (
//    input wire clk,               
//    input wire reset,            
//    input wire start,             
//    input wire [11:0] binary,    
//    output reg [15:0] bcd_out,    
//    output reg done               
//);
//    integer i;                    
//    reg [3:0] cycle_count;        
//    reg [27:0] bcd_in;            
//    reg busy;                  

//    always @(posedge clk or posedge reset) begin
//        if (reset) begin
//            bcd_out <= 16'b0;
//            bcd_in <= 28'b0;
//            cycle_count <= 4'd0;
//            done <= 1'b0;
//            busy <= 1'b0;
//        end
//        else if (start && !busy) begin
//            bcd_in[11:0] <= binary; 
//            bcd_in[27:12] <= 16'b0; 
//            bcd_out <= 16'b0;
//            cycle_count <= 4'b0;
//            done <= 1'b0;
//            busy <= 1'b1;
//        end
//        else if (busy) begin
//            if (bcd_in[27:24] > 4)
//                bcd_in[27:24] <= bcd_in[27:24] + 3;
//            else if (bcd_in[23:20] > 4)
//                bcd_in[23:20] <= bcd_in[23:20] + 3;
//            else if (bcd_in[19:16] > 4)
//                bcd_in[19:16] <= bcd_in[19:16] + 3;
//            else if (bcd_in[15:12] > 4)
//                bcd_in[15:12] <= bcd_in[15:12] + 3;

//            bcd_in <= bcd_in << 1;

//            cycle_count <= cycle_count + 1;

//            if (cycle_count == 4'b1011) begin
//                bcd_out <= bcd_in[27:12]; 
//                done <= 1'b1;
//                busy <= 1'b0;
//            end
//        end
//    end

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

