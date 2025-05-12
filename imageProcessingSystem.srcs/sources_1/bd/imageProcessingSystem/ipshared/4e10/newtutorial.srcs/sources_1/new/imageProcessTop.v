`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.05.2025 20:02:46
// Design Name: 
// Module Name: imageProcessTop
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
// this module will be interfaced with the DMA controller which has an AXI stream interface
//      data comes and goes through the AXI stream interface
// we also have an interrupt signal coming from the IP to be added here
//////////////////////////////////////////////////////////////////////////////////


module imageProcessTop(
// we will follow the AXI stream interface for the port
input           axi_clk,
input           axi_reset_n,
// slave interface
input           i_data_valid,
input     [7:0] i_data,
output          o_data_ready, // we might connect the slave ready to the master but there is pipelining (3 pipelines) with the IP core so there is a 3 clock cycle delay between changes and effects
                              // therefore we must solve this in a different way than directly connecting
                              // adding an output buffer (a fifo) at the end of the data output stream from the slave would fix this as it would take the 3 output pixels and hold them while the ready signal comes through
// master interface
output          o_data_valid,
output    [7:0] o_data,
input           i_data_ready,
// interrupt
output          o_intr

    );

wire    [71:0]  pixel_data;
wire            pixel_data_valid;
wire            axis_prog_full;
wire    [7:0]   convolved_data;
wire            convolved_data_valid;

assign o_data_ready = !axis_prog_full;

//------AXI stream interfacing with buffer at output (Slave port -> IC -> conv -> buffer -> master port)------------

imageControl IC(
    .i_clk(axi_clk),
    .i_rst(!axi_reset_n),
    .i_pixel_data(i_data),
    .i_pixel_data_valid(i_data_valid), 
    .o_pixel_data(pixel_data),       
    .o_pixel_data_valid(pixel_data_valid),
    .o_intr(o_intr)
);

conv conv(
    .i_clk(axi_clk),
    .i_pixel_data(pixel_data),                               
    .i_pixel_data_valid(pixel_data_valid),
    .o_convolved_data(convolved_data),
    .o_convolved_data_valid(convolved_data_valid)  
);
 
outputBuffer OB (
  .wr_rst_busy(),        // output wire wr_rst_busy
  .rd_rst_busy(),        // output wire rd_rst_busy
  .s_aclk(axi_clk),                  // input wire s_aclk
  .s_aresetn(axi_reset_n),            // input wire s_aresetn
  .s_axis_tvalid(convolved_data_valid),    // input wire s_axis_tvalid
  .s_axis_tready(),    // output wire s_axis_tready // there is no case the fifo wont be ready so we dont need to worry about overlflow
  .s_axis_tdata(convolved_data),      // input wire [7 : 0] s_axis_tdata
  .m_axis_tvalid(o_data_valid),    // output wire m_axis_tvalid
  .m_axis_tready(i_data_ready),    // input wire m_axis_tready
  .m_axis_tdata(o_data),      // output wire [7 : 0] m_axis_tdata
  .axis_prog_full(axis_prog_full)  // output wire axis_prog_full
);

//------AXI stream interfacing with buffer at output (Slave port -> IC -> conv -> buffer -> master port)------------
    
endmodule
