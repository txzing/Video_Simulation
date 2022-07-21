// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Wed Jul 20 10:10:30 2022
// Host        : TX running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/txzing/Desktop/example/ZYNQ_7020_SDK/27_ov5640_median_filter/ip/blk_mem_gen_0/blk_mem_gen_0_sim_netlist.v
// Design      : blk_mem_gen_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "blk_mem_gen_0,blk_mem_gen_v8_4_4,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2020.2" *) 
(* NotValidForBitStream *)
module blk_mem_gen_0
   (clka,
    wea,
    addra,
    dina,
    clkb,
    addrb,
    doutb);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [11:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [7:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [11:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [7:0]doutb;

  wire [11:0]addra;
  wire [11:0]addrb;
  wire clka;
  wire clkb;
  wire [7:0]dina;
  wire [7:0]doutb;
  wire [0:0]wea;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [7:0]NLW_U0_douta_UNCONNECTED;
  wire [11:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [11:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [7:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "12" *) 
  (* C_ADDRB_WIDTH = "12" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "1" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     4.862099 mW" *) 
  (* C_FAMILY = "zynq" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "0" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "1" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "blk_mem_gen_0.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "1" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "4096" *) 
  (* C_READ_DEPTH_B = "4096" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "8" *) 
  (* C_READ_WIDTH_B = "8" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "4096" *) 
  (* C_WRITE_DEPTH_B = "4096" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "8" *) 
  (* C_WRITE_WIDTH_B = "8" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  blk_mem_gen_0_blk_mem_gen_v8_4_4 U0
       (.addra(addra),
        .addrb(addrb),
        .clka(clka),
        .clkb(clkb),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(NLW_U0_douta_UNCONNECTED[7:0]),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(1'b0),
        .enb(1'b0),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[11:0]),
        .regcea(1'b0),
        .regceb(1'b0),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[11:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[7:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2020.2"
`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`pragma protect key_block
QGLtnqZzRetDH6gCWT4Js6wuLlZfrNx/VJp3sfR2NF+cxypO5AxN0oDKLJJtmdrtE/ueNDg+Qf7Z
TqBNRojORA==

`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
B6Ger3hRvfjHkaJ+W8639Kl3TzC9TogLuklOXEiMNdc4Im+DjEUzxb3DKlzu0VW3zxZqjJ3+wsW/
LnRmPCESi5Y9eRJaLFXg79EMfoj4X+nTdHAP6yCfltBADKegZ12gpnB/8ey5yn2KA74LUtPC7jna
iyjqSfsWLGnz6UdXzwk=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
BX+DxgMPRyZbYojCUR9Sk8Lq+3ZigBz4yMFHQkmurfdfDzyTPJCE827eGiPyTenK1QPVhEtf9g06
0BFXq/0COPuU1BWJwdkz1c4dE6/exDwhvEh+hPx3vRY6z8fDEf6aGVIXrHDvrmddehe7yMSIpo+k
aXHR06EEdfHCFY4TggYwhcJVXjkE+ApsVuyfmEfPmYjo8hCWyQyBsUWIOY03q1+MvUjjsmTwgs9g
fh5MY9ToaLfoJxPKdCpsqrBX4LJ+VDGFlAqIcqHTE2jCmPiToZAFXB7fzf1wDjFCBlJyFVDBGi0i
m+CouLSb7X1mvVhdDZgNrZDJMV688Bu3o54vew==

`pragma protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
DaIU/Ddc8USbZ2mURzujJDWDH1JbHl5tFVOOQ2aVaUPIA71yyE38OXVLEtF8rNmujYH30nEeQ+FV
LVJ16aaHw+iiuaqorTM3K5KLohVlN+WlcEtSXHuPNHjw8ddqtzpaX7pH1zqZH+YmfCL5oaNLqDH4
rkBnUl0/Gm/hzSwKjYhXGQFYQ+gGP99OjXakzrAqZzp/Iq4gt+Z5902/JV9thd/isHQImJ0QyK8M
EKM579iPAfXGes2mbiNYHcvDmSPYmW1zlhOE++N1EKeea7j/msnKeyhlC+hGE4Xfn4TVvqgQexCT
rp/wS/MosY6WH1aKFQlFH2hEppA7KXUaQlvG+w==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
XmWoAt4X8hrCJ5yTyug4ajJW5UhfkLNibzjihWzZ4Cr9hQSvWZoTc8rjGsLPbz6Le+/9iI5KxecS
eR0wiAO+G2IkwhZgVBeZdKoFnlnTVAyLjk9wMAFXNyJZM6b1NDbfXlPcUsC6JePvPlwwdWknkSsC
r3KvgkWAS+O3xvRmaNw=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Hw3Y+rShKrXiUViyNU1/O2qv6TgheLHBnFMj1i9MUGrHYqh9pLfLYUgWR7S2vj4jv4S+Ks0BpP4p
dKEqVAFmTCfQNEUHaVcFPkOHgig6L4mhLY6HUUKJoRgiQepgLi/W3V+ZZPQSQFkB3CU4MsJzhXvR
yLcpDriZy8cnAHD87Zi5DrNGBzj3kigJeM0du6lCQbxtF5aEdoaNP+YTnIFtcqYhoYnswQlYt0sV
HKgFA8VzqzL5WYnpH7+1IKmFkJBHkyqHCa9wPK0qCKnxkuDj70YzPVqQ+cocdKU+/gNdpCOdZlci
F2HTxrgfrXndJru3TiDqu4UavqAe0MNuFp3t0w==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
XPVggoWL6aXz+MpODTOZhEUQDa0vfEnUDaYeEHXm2vGyqKJujN2c/FFAFBeBYdJATLsIsQ+BqoPc
pBbcFYXDBfOtFIW2dH6Y1OoD65KyJ/hAq8coa21kFgq4hFat5vzZ2iIfkCpTUr4vDZO7Xne8cZO9
WsHffoTCt5rS59wWm2b8I5R8Eh2TUbQg3RCyrcnD66cvcEnlXe1CNMQ4/loVJpA4IBinBf820Wjc
vw2fZbGI0jXC+ACSHOviH63Xwmn+aRV5Ppkup7IYoon/ieKapRQeASu3TTY37xSBXiInSdtMTzJ6
+4GfO4eSHVriCk/sWbuTBzfRzoSShrnHjzz5LA==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2020_08", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
L78XuiswVcgO2gtebzL7SA9BC/jJGAM0v6S9pzmyqL+QYzRneiYeGyDmsW33jEVVSTuNjTXkBLY7
yTOKQruatwe4V0OLi6174saSAmPgerSV1GyLP7KhmusLV/N61avC9TPam+tekhKeE0tds4EnJ3et
4JdLh+SE4Z4pcuqCjB5MFneIYKKWDx7siU6oesAQtoSJOesfMchX63MhOjOHFP/ch+1gHv3T45hg
IGF7V7TrdREVE4f9631tlVJ1o2Dypsmo/76Itz5WCGlTMjAnWXN8IXxKN+PZ3dyt1wjrZm2P/td+
xiGszFnSLrRvw/HferwtSmRx8q0fiHZ88roGTw==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
kDX5kq2QEe25429T6vQqBCFvV1McKTJRYfK99ymVNK2GGvGLXSzgwJHwB2fj9rM0wme3zYYY0vQR
x+9F4L7KLlOVY6qY3LB59uDzyXBI3mMZaS905HXHJkdZHWtQWpfHhl27LqL+8FSluaD6F+KFfYOV
CwIOVuCIp/XjxFXpNBik7YiPt4kHOlDA97IXNLnYUn/g1csGqeNWce4UTne50ggWvLYGbTFGmTjT
N67TpUiGRVRCSv8Tax72GWFIMFZk3Tlp68ZUSQEybZMWX1U9XdMdtxfvNGhf8mi5jQJ2SupSzKu4
T/+53IN9T8aLePAiGBKKG1ZBj4y1ZyYA7XYvjw==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 26832)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
