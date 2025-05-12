`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.05.2025 01:56:30
// Design Name: 
// Module Name: conv
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
// This source will do the MAC operation
//////////////////////////////////////////////////////////////////////////////////


module conv(
input               i_clk,
input   [72:0]      i_pixel_data,   // recall that for inputs in verilog we have to flatten them, so a 3 input data will be concatenated to avoid additional wires/ regs
                            // hence 24 * 3 for each pixel in the being MAC'd would give 72 = 71:0
input               i_pixel_data_valid,
output reg [7:0]    o_convolved_data,
output reg          o_convolved_data_valid  // we will need to pipeline a signal to get this signal at the correct time
    );

// kernel declaration
// it can be declared as a 2 dimensional array or 1 dimensional array

reg [7:0] kernel [8:0];  // 8 bit wide, depth of 9
integer i;
reg [15:0] multData[8:0]; // max size of a value can be 16 bit as two 8 bit numbers so width of 16 due to operands
reg [15:0] sumDataInt, sumData;
reg multDataValid;
reg sumDataValid;

// lets intialise the value

initial     // we can use initial because the kernel will stay fixed
begin
    for(i=0;i<9;i=i+1)      // this for loop will be unrolled by vivado
    begin
        kernel[i] = 1;
    end
end

// lets do the multiplication, the first level of the pipeline
always @(posedge i_clk)
begin
    for(i=0;i<9;i=i+1)      // this for loop will be unrolled by vivado
        begin
            multData[i] <= kernel[i]*i_pixel_data[i*8 +:8]; // i*8 gives the start index, +:8 means take the next 8 bits ("width of 8"). This ensures we always pick up the next pixel without overlapping another pixel's data
        end
    multDataValid <= i_pixel_data_valid;
end

// lets add it
//always @(posedge i_clk)   // one thing to note is the problem of using an operand on LHS and RHS of equals, due to clock delay before propagation
                            // this will lead to XX of RHS operand. We can avoid with the assign = which is instant. You can not mix = and <= within
                            // the same process/ always block in vivado however (blocking and non blocking assignment statements)
                            // hence we will make the circuit below combinational logic with always @(*)
                            
always @(*)
begin
    sumDataInt = 0;
    for(i=1;i<9;i=i+1)
    begin
        sumDataInt = sumDataInt + multData[i];
    end
end

        // lets store that sum in the next clock cycle as the next level of the pipeline
always @(posedge i_clk)
begin
    sumData <= sumDataInt;
    sumDataValid <= multDataValid;
end

// lets divide to create the output at the next pipeline
always @(posedge i_clk)
begin
    o_convolved_data <= sumData/9;
    o_convolved_data_valid <= sumDataValid;
end

endmodule
