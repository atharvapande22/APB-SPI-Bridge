// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Tue Feb 20 20:59:27 2024
// Host        : PC running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/Vivado_projects/APBtoSPI/APBtoSPI.srcs/sources_1/ip/WRITE_FIFO/WRITE_FIFO_stub.v
// Design      : WRITE_FIFO
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7vx485tffg1157-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_3,Vivado 2018.3" *)
module WRITE_FIFO(rst, wr_clk, rd_clk, din, wr_en, rd_en, dout, full, 
  wr_ack, empty, valid, wr_rst_busy, rd_rst_busy)
/* synthesis syn_black_box black_box_pad_pin="rst,wr_clk,rd_clk,din[16:0],wr_en,rd_en,dout[16:0],full,wr_ack,empty,valid,wr_rst_busy,rd_rst_busy" */;
  input rst;
  input wr_clk;
  input rd_clk;
  input [16:0]din;
  input wr_en;
  input rd_en;
  output [16:0]dout;
  output full;
  output wr_ack;
  output empty;
  output valid;
  output wr_rst_busy;
  output rd_rst_busy;
endmodule
