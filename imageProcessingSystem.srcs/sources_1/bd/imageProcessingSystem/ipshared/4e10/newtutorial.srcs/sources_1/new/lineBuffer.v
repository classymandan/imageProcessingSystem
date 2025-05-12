`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.05.2025 17:07:26
// Design Name: 
// Module Name: lineBuffer
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
//  Assumptions:
//      - Writing 1 pixel at a time to line buffer
//      - Assuming fixed size of image (512 x 512), so we have to store 512 pixels in the line buffer
// in essence this is a specialised dual port ram (not strictly the same as read and write ports are diff sizes
//////////////////////////////////////////////////////////////////////////////////
 

module lineBuffer( // write port declarations in brackets
input   i_clk,          // clock signal
input   i_rst,          // reset signal, assuming active high reset
input   [7:0] i_data,   // data
input   i_data_valid,   // valid data signal
output  [23:0] o_data,  // we'll concatenate the 3 pixels' data into one output
input i_rd_data         // as this is memory, we need a signal which indicates that data should be read from the line buffer    
    );

reg [7:0] line [511:0];  // we model memory in verilog like this: reg, followed by width of mem then no of locations (line[511:0])
// the basic operation is that whenever there is a new valid data coming (new pixel) it should be stored in memory
// we need a variable (in verilog this is a register, reg) to tell us where this new data should be stored
reg [8:0] wrPntr;          // we call it write pointer because it is similar to a pointer in software, its size is log2(depth of memory, in this case 511)
reg [8:0] rdPntr;          // we need a signal for the read pointer too when we come to read for an output

//----------------------- for writing ----------------------------------------------//
always @(posedge i_clk)       // this is a process in verilog, we are working synchronously here
begin                         // this block is for doing the write operation
    if (i_data_valid)
        line[wrPntr] <= i_data; // initially pointing to address 0, if data is valid it will write input data to a location
end
    
always @(posedge i_clk)         // we make a new process block for maintainability of code instead of using process block above
begin                         // this block is for incrementing the write pointer and dealing with resets
    if (i_rst)
        wrPntr <= 'd0;          // we can write 0 or 'd0
    else if (i_data_valid)
        wrPntr <= wrPntr + 'd1;  // increment the write pointer to the next location
end
//----------------------- for writing ----------------------------------------------//

//----------------------- for reading ----------------------------------------------//


// read 3 data points, starting from the leftmost side as per the kernel overlayed on the image 
// we will assign this, it will not be clock synchronous
    // we did it this way because we don't want one clock period delay between the output and the rd_data signal 
    // in essence this is a prefetch
    // from the beginning of the code run, after reset the output will be available
    // when rdPntr increments the next three will be available for the following clock cycle, no latency
assign o_data = {line[rdPntr] , line[rdPntr + 1] , line[rdPntr + 2]};  // {} is the concatenation operator in verilog
    
always @(posedge i_clk)         
begin                         // this block is for incrementing the read pointer and dealing with resets
    if (i_rst)
        rdPntr <= 'd0;          
    else if (i_rd_data)
        rdPntr <= rdPntr + 'd1;  
end

//----------------------- for reading ----------------------------------------------//
endmodule
