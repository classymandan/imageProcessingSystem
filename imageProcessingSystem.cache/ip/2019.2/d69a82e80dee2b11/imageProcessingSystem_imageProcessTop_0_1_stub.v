// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Mon May 12 20:58:41 2025
// Host        : DansLaptop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ imageProcessingSystem_imageProcessTop_0_1_stub.v
// Design      : imageProcessingSystem_imageProcessTop_0_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "imageProcessTop,Vivado 2019.2" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(axi_clk, axi_reset_n, i_data_valid, i_data, 
  o_data_ready, o_data_valid, o_data, i_data_ready, o_intr)
/* synthesis syn_black_box black_box_pad_pin="axi_clk,axi_reset_n,i_data_valid,i_data[7:0],o_data_ready,o_data_valid,o_data[7:0],i_data_ready,o_intr" */;
  input axi_clk;
  input axi_reset_n;
  input i_data_valid;
  input [7:0]i_data;
  output o_data_ready;
  output o_data_valid;
  output [7:0]o_data;
  input i_data_ready;
  output o_intr;
endmodule
