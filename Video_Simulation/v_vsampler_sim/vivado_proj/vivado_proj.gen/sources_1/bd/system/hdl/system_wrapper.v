//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
//Date        : Wed Jun 22 18:03:47 2022
//Host        : TX running 64-bit major release  (build 9200)
//Command     : generate_target system_wrapper.bd
//Design      : system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module system_wrapper
   (aclk_50MHz,
    aresetn_0,
    tdata,
    tlast,
    tready,
    tuser,
    tvalid);
  input aclk_50MHz;
  input aresetn_0;
  output [31:0]tdata;
  output [0:0]tlast;
  input tready;
  output [0:0]tuser;
  output tvalid;

  wire aclk_50MHz;
  wire aresetn_0;
  wire [31:0]tdata;
  wire [0:0]tlast;
  wire tready;
  wire [0:0]tuser;
  wire tvalid;

  system system_i
       (.aclk_50MHz(aclk_50MHz),
        .aresetn_0(aresetn_0),
        .tdata(tdata),
        .tlast(tlast),
        .tready(tready),
        .tuser(tuser),
        .tvalid(tvalid));
endmodule
