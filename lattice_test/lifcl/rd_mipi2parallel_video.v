//   ==================================================================
//   >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
//   ------------------------------------------------------------------
//   --------------------------------------------------------------------
`include "synthesis_directives.v"

module rd_mipi2parallel_video
//-----------------------------------------------------------------------------
// PORT DECLARATIONS
//-----------------------------------------------------------------------------
(
`ifdef EXT_REF_CLK
	input 	ref_clk_i, // for tx
`endif
	inout 	rx_clk_p_i,
	inout 	rx_clk_n_i,
	inout 	rx_d0_p_i,
	inout 	rx_d0_n_i,
`ifndef NUM_RX_LANE_1 // 2 or 4 lanes
	inout 	rx_d1_p_i,
	inout 	rx_d1_n_i,
`endif
`ifdef NUM_RX_LANE_4 // 4 lanes
	inout 	rx_d2_p_i,
	inout 	rx_d2_n_i,
	inout 	rx_d3_p_i,
	inout 	rx_d3_n_i,
`endif

	output				pix_clk_o	,
	output [23:0]       pix_data    ,
	output				v_hs		,
	output				v_vs		,
	output				v_de

);


//-----------------------------------------------------------------------------
// LOCAL PARAMETERS
//-----------------------------------------------------------------------------	
`ifdef RX_RGB888
	parameter RX_PD_BUS_WIDTH = 24;
`elsif RX_RGB666
	parameter RX_PD_BUS_WIDTH = 18;
`elsif RX_RAW8
	parameter RX_PD_BUS_WIDTH = 8;
`elsif RX_RAW10
	parameter RX_PD_BUS_WIDTH = 10;
`elsif RX_RAW12
	parameter RX_PD_BUS_WIDTH = 12;
`endif
`ifdef NUM_RX_LANE_1
	parameter RX_LANE_COUNT = 1;
	wire [RX_LANE_COUNT - 1:0] rx_d_p_i ;
	wire [RX_LANE_COUNT - 1:0] rx_d_n_i ;
`elsif NUM_RX_LANE_2
	parameter RX_LANE_COUNT = 2;
	wire [RX_LANE_COUNT - 1:0] rx_d_p_i ;
	wire [RX_LANE_COUNT - 1:0] rx_d_n_i ;
`elsif NUM_RX_LANE_4
	parameter RX_LANE_COUNT = 4;
	wire [RX_LANE_COUNT - 1:0] rx_d_p_i ;
	wire [RX_LANE_COUNT - 1:0] rx_d_n_i ;
`endif

`ifdef NUM_RX_LANE_1
	assign rx_d_p_i = rx_d0_p_i;
	assign rx_d_n_i = rx_d0_n_i;
`elsif NUM_RX_LANE_2
	assign rx_d_p_i = {rx_d1_p_i,rx_d0_p_i};
	assign rx_d_n_i = {rx_d1_n_i,rx_d0_n_i};
`elsif NUM_RX_LANE_4
	assign rx_d_p_i = {rx_d3_p_i,rx_d2_p_i,rx_d1_p_i,rx_d0_p_i};
	assign rx_d_n_i = {rx_d3_n_i,rx_d2_n_i,rx_d1_n_i,rx_d0_n_i};
`endif

`ifdef RX_GEAR_8
	parameter RX_GEAR = 8; // DPHY Rx Clock Gear
`elsif RX_GEAR_16
	parameter RX_GEAR = 16; // DPHY Rx Clock Gear
`endif

`ifdef TX_PPC 
	parameter NUM_PPC = `TX_PPC;
`else
	parameter NUM_PPC = 1;
`endif

parameter TX_PD_BUS_WIDTH = 24;

`ifdef BAYER_PATTERN
	parameter BAYER_PATTERN = `BAYER_PATTERN;
`else
	parameter BAYER_PATTERN = 2'b00;
`endif

`ifdef H_TX_PEL 
	parameter [12:0] H_TX_PEL = `H_TX_PEL;
`else
	parameter [12:0] H_TX_PEL = 13'd1920;
`endif

`ifdef V_TX_LINE 
	parameter [12:0] V_TX_LINE = `V_TX_LINE;
`else
	parameter [12:0] V_TX_LINE = 13'd1080;
`endif


//-----------------------------------------------------------------------------
// WIRE and REGISTER DECLARATIONS
//-----------------------------------------------------------------------------
`ifdef RX_TYPE_DSI
	`ifdef RX_RGB888
		wire [5:0] ref_dt = 6'h3E;
	`elsif RX_RGB666
		wire [5:0] ref_dt = 6'h1E;
	`endif
`elsif RX_TYPE_CSI2
	`ifdef RX_RGB888
		wire [5:0] ref_dt = 6'h24;
	`elsif RX_RAW8
		wire [5:0] ref_dt = 6'h2A;
	`elsif RX_RAW10
		wire [5:0] ref_dt = 6'h2B;
	`elsif RX_RAW12
		wire [5:0] ref_dt = 6'h2C;
	`endif
`endif
/////////////////////////////////////////////////////////////////////////////

wire rst_n;
wire rx_clk_byte_fr, rx_clk_byte_hs, rx_clk_lp_ctrl, rx_reset_lp_n;
reg rx_reset_byte_fr_n_meta, rx_reset_byte_fr_n_sync;
wire rx_payload_en, rx_sp_en, rx_lp_en, rx_lp_av_en;
wire [RX_LANE_COUNT*RX_GEAR-1:0]	rx_payload;
wire [5:0]	rx_dt;
wire [15:0]	rx_wc;
`ifdef NUM_RX_LANE_4
	`ifdef RX_GEAR_16
wire rx_sp2_en, rx_lp2_en, rx_lp2_av_en;
wire [5:0]	rx_dt2;
wire [15:0]	rx_wc2;
	`endif
`endif

wire [RX_PD_BUS_WIDTH*NUM_PPC-1:0]	pd;

////////////////////////////////////////////////////////////
//(1) USE OSC if SOFT DPHY is used.
//                        OR
//(2) USE OSC iF HARD DPHY and NON Continuous mode is used.
//     - If we have clk > 27 MHz available, don't use OSC.
///////////////////////////////////////////////////////////

`ifndef RX_DPHY_HARD // SOFT DPHY
wire sync_clk;
 //USE OSC 	
 int_osc int_osc_inst 
 (
 .hf_out_en_i (1'b1), 
 .hf_clk_out_o(sync_clk)
 ) ;
`else // HARD DPHY
	`ifdef RX_CLK_MODE_HS_LP // NON CONTINUOUS MODE	
	 int_osc int_osc_inst 
	 (
	 .hf_out_en_i (1'b1), 
	 .hf_clk_out_o(sync_clk)
	 ) ;
	`endif
`endif	

/////////////////////////////////////////////////////////////////////////////
///// GPLL instantiation                                                /////
///// User has to modify this if necessary                              /////
/////////////////////////////////////////////////////////////////////////////
`ifdef EXT_REF_CLK
wire clk_pixel;
wire pll_lock;
`ifdef RX_CLK_MODE_HS_LP
wire pll_byte_clk;
`endif
	`ifdef RX_CLK_MODE_HS_LP
		int_gpll pll_inst (
			.rstn_i (rst_n),
			.clki_i	(ref_clk_i),	 // ref clock       // cannot create eclk from byte clock
			.clkop_o(pll_byte_clk),  // tx edge clock 
			.clkos_o(clk_pixel),	 // byte clock      // byte clock
			.lock_o	(pll_lock)
		);
	`elsif RX_CLK_MODE_HS_ONLY
		int_gpll pll_inst (
			.rstn_i(rst_n),
			.clki_i	(ref_clk_i),	// cannot create eclk from byte clock
			.clkop_o(clk_pixel),
			.lock_o	(pll_lock)
		);
	`endif
`elsif 
RX_CLK_MODE_HS_ONLY
	int_gpll pll_inst (
		.rstn_i (rst_n),
		.CLKI	(rx_clk_byte_fr),
		.CLKOP	(clk_pixel),
		.LOCK	(pll_lock)
	);
`endif

Reset_Delay  
#(
.FREQ_HZ   (32'd50_000_000),
.RST_MS_MAX('d10          )// ¶ÔMS_CNT_MAX¼ÆÊý
)
u_Reset_Delay
(
/*input wire  */.clk	(ref_clk_i),
/*output wire */.rst_o	(),
/*output wire */.rst_n_o(rst_n)
);


`ifdef RX_CLK_MODE_HS_ONLY
	assign rx_clk_byte_fr = rx_clk_byte_hs;
	assign rx_clk_lp_ctrl = 1'b1;
	assign rx_reset_lp_n = 1'b1;
`else
// User must provide the continuous RX byte clock from ref_clk_i or somewhere
	assign rx_clk_byte_fr = pll_byte_clk;	// continuous clock as fast as rx_clk_byte_hs
	assign rx_clk_lp_ctrl = pll_byte_clk; 
	reg rx_reset_lp_n_meta, rx_reset_lp_n_sync;
	assign rx_reset_lp_n = rx_reset_lp_n_sync;

	always @(posedge rx_clk_lp_ctrl or negedge rst_n) begin
		if (~rst_n) begin
			rx_reset_lp_n_meta <= 0;
			rx_reset_lp_n_sync <= 0;
		end
		else begin
			rx_reset_lp_n_meta <= rst_n;
			rx_reset_lp_n_sync <= rx_reset_lp_n_meta;
		end
	end
`endif

reg reset_pixel_n_meta, reset_pixel_n_sync;

always @(posedge clk_pixel or negedge rst_n) begin
	if (~rst_n) begin
		reset_pixel_n_meta <= 0;
		reset_pixel_n_sync <= 0;
	end
	else begin
		reset_pixel_n_meta <= rst_n;
		reset_pixel_n_sync <= reset_pixel_n_meta;
	end
end

/*synthesis translate_off*/
GSR GSR_INST (1'b1, ref_clk_i);
/*synthesis translate_on*/


// tx pll is already locked before the rx can start data transfer
always @(posedge rx_clk_byte_fr or negedge rst_n) begin
	if (~rst_n) begin
		rx_reset_byte_fr_n_meta <= 0;
		rx_reset_byte_fr_n_sync <= 0;
	end
	else begin
		rx_reset_byte_fr_n_meta <= rst_n;
		rx_reset_byte_fr_n_sync <= rx_reset_byte_fr_n_meta;
	end
end

/////////////////////////////////////////////////////////////////////////////
///// RX D-PHY module instantiation                                     /////
///// Customer has to recreate a Soft-IP for own configuration settings /////
/////////////////////////////////////////////////////////////////////////////
///// Debug signals /////
wire rx_hs_d_en, rx_hs_sync, rx_term_clk_en;
wire [1:0] rx_lp_hs_state_clk, rx_lp_hs_state_d;
wire [1:0] p_odd;
rx_dphy rx_dphy
(
// Inouts
	.clk_n_io			(rx_clk_n_i),
	.clk_p_io			(rx_clk_p_i),
	.d_n_io				(rx_d_n_i),
	.d_p_io				(rx_d_p_i),
// Inputs
	`ifndef RX_DPHY_HARD
	.sync_clk_i			(sync_clk),
	.sync_rst_i			(~rst_n),
	.pll_lock_i			(pll_lock), 	// tie to 1 if no pll is used
	`endif
	.clk_byte_fr_i		(rx_clk_byte_fr),
	.reset_byte_fr_n_i	(rx_reset_byte_fr_n_sync),
	.reset_byte_n_i		(rx_reset_byte_fr_n_sync),
	`ifdef RX_CLK_MODE_HS_LP
	.clk_lp_ctrl_i		(rx_clk_lp_ctrl),
	.reset_lp_n_i		(rx_reset_lp_n),
	`endif
	.reset_n_i			(rst_n),
	`ifdef RX_DPHY_HARD
	.pd_dphy_i			(~rst_n),
	`endif
	.tx_rdy_i			(1'b1),	
	`ifdef RX_TYPE_DSI
	.lp_d0_tx_en_i		(1'b0),		// no need for CSI2
	.lp_d0_tx_n_i		(1'b0), 	// no need for CSI2
	.lp_d0_tx_p_i		(1'b0), 	// no need for CSI2
	`endif
// Outputs
	.clk_byte_o			(rx_clk_byte),
	.clk_byte_hs_o		(rx_clk_byte_hs),
	.cd_d0_o			(),
	.cd_clk_o                (),
	.lp_d_rx_p_o		(),
	.lp_d_rx_n_o		(),
	.ref_dt_i			(ref_dt),
	.sp_en_o			(rx_sp_en),
	.lp_en_o			(rx_lp_en),
	.lp_av_en_o			(rx_lp_av_en),
	.vc_o				(),
	.dt_o				(rx_dt),
	.wc_o				(rx_wc),
	.ecc_o				(),
	`ifndef RX_DPHY_HARD
	.ready_o			(),
	`endif
	`ifndef RX_GEAR_16
	.bd_o				(),
	`endif
	.payload_o			(rx_payload),
	.payload_en_o		(rx_payload_en),
`ifdef NUM_RX_LANE_4
	`ifdef RX_GEAR_16
	.sp2_en_o			(rx_sp2_en),
	.lp2_en_o			(rx_lp2_en),
	.lp2_av_en_o		(rx_lp2_av_en),
	.vc2_o				(),
	.dt2_o				(rx_dt2),
	.wc2_o				(rx_wc2),
	.ecc2_o				(),
	`endif
`endif
/// debug signals
	.hs_d_en_o				(rx_hs_d_en),
	.hs_sync_o				(rx_hs_sync),
	.term_d_en_o                    (),
	.term_clk_en_o			(rx_term_clk_en),
	.lp_hs_state_clk_o		(rx_lp_hs_state_clk),
	.lp_hs_state_d_o		(rx_lp_hs_state_d)
);

/////////////////////////////////////////////////////////////////////////////
///// Byte2Pixel module instantiation                                   /////
///// Customer has to recreate a Soft-IP for own configuration settings /////
/////////////////////////////////////////////////////////////////////////////
byte2pix  byte2pixel (
	.clk_byte_i			(rx_clk_byte_fr),
	.reset_byte_n_i		(rx_reset_byte_fr_n_sync),
	.clk_pixel_i		(clk_pixel),
	.reset_pixel_n_i	(reset_pixel_n_sync),
	.sp_en_i			(rx_sp_en),
	.lp_av_en_i			(rx_lp_av_en),
	.dt_i				(rx_dt),
	.wc_i				(rx_wc),
	.payload_i			(rx_payload),
	.payload_en_i		(rx_payload_en),
`ifdef NUM_RX_LANE_4
	`ifdef RX_GEAR_16
	.sp2_en_i			(rx_sp2_en),
	.lp2_av_en_i		(rx_lp2_av_en),
	.dt2_i				(rx_dt2),
	.wc2_i				(rx_wc2),
	`endif
`endif
`ifdef RX_TYPE_CSI2
	.fv_o				(rx_fv),
	.lv_o				(rx_lv),
`else
	.vsync_o			(rx_vsync),
	.hsync_o			(rx_hsync),
	.de_o				(rx_de),
`endif
	.pd_o				(pd),
	.p_odd_o			(p_odd)
);


reg clk_div;
always @(posedge clk_pixel)
begin
	if(!rst_n)
		clk_div	<=	1'b0;
	else 
		clk_div	<=	~clk_div;
end
assign pix_clk_o = clk_div;



wire [7:0] vga_r;
wire [7:0] vga_g;
wire [7:0] vga_b;
`ifdef TPG_MODE
	color_data_gen 
	#(
	//--------------------------------//
		.H_Active	(H_TX_PEL),
		.H_Sync		('d44	),
		.H_Back		('d148	),
		.H_Front	('d88	),
	//-------------------------------//
		.V_Active	(V_TX_LINE),
		.V_Sync		('d5    ),
		.V_Back		('d36   ),
		.V_Front	('d4    )

	/*
	//--------------------------------//
		.H_Active	(H_TX_PEL),
		.H_Sync		('d60	),
		.H_Back		('d60	),
		.H_Front	('d88	),
	//-------------------------------//
		.V_Active	(V_TX_LINE),
		.V_Sync		('d2    ),
		.V_Back		('d8    ),
		.V_Front	('d32   )
	*/
	/*
		//--------------------------------//
		.H_Active	(H_TX_PEL),
		.H_Sync		('d48	),
		.H_Back		('d32	),
		.H_Front	('d80	),
	//-------------------------------//
		.V_Active	(V_TX_LINE),
		.V_Sync		('d8    ),
		.V_Back		('d10   ),
		.V_Front	('d32   )
	*/
	)
	u_color_data_gen
	(
	/*input				*/.pix_clk	(clk_pixel)	,
	/*input				*/.rst_n	(rst_n && pll_lock)	,
	/*input  [3:0]    	*/.dis_mode	('d12)       , //7,12
	/*output [7:0]		*/.VGA_R	(vga_r)		,
	/*output [7:0]		*/.VGA_G	(vga_g)		,
	/*output [7:0]		*/.VGA_B	(vga_b)		,
	/*output			*/.VGA_HS	(v_hs)		,
	/*output			*/.VGA_VS	(v_vs)		,
	/*output			*/.VGA_DE	(v_de)

	);
	
`else //csi
	Video_Image_Processor
	#(
		.BAYER_PATTERN (BAYER_PATTERN),
		.IMG_HDISP (H_TX_PEL),	
		.IMG_VDISP (V_TX_LINE),
		.DATA_W    (RX_PD_BUS_WIDTH)
	)
	u_Video_Image_Processor
	(
	/*input		*/.clk             (clk_pixel),  				//cmos video pixel clock
	/*input		*/.rst_n           (reset_pixel_n_sync && pll_lock),				//global reset
	//Image data prepred to be processd
	/*input		*/.pre_frame_vsync (rx_fv),	//Prepared Image data vsync valid signal
	/*input		*/.pre_frame_href  (rx_lv),		//Prepared Image data href vaild  signal
	/*input		*/.pre_img_data    (pd),		//Prepared Image data of YCbCr 4:2:2 {CbY} {CrY}
	//Image data has been processd
	/*output	*/.post_frame_vsync(v_vs),	//Processed Image data vsync valid signal
	/*output	*/.post_frame_href (v_de),	//Processed Image data href vaild  signal
	/*output	*/.post_img_red    (vga_r),		//Processed Image Red output
	/*output	*/.post_img_green  (vga_g),		//Processed Image Green output
	/*output	*/.post_img_blue   (vga_b)	    //Processed Image Blue output
	);
	assign v_hs	    = v_de;
	
`endif

//assign pix_data = {vga_r,vga_g,vga_b};
assign pix_data = {vga_r,vga_b,vga_g};

endmodule 
