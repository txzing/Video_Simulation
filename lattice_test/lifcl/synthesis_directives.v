///// Synthesis Directives for MIPI to LVDS RD /////

`define EXT_REF_CLK	// Enable this when using an external reference clock

///// Directives for RX /////
//`define RX_TYPE_DSI	// DSI or CSI2
`define RX_TYPE_CSI2	// DSI or CSI2
`define	NUM_RX_LANE_4	// 1, 2, or 4

`define RX_GEAR_8	// 8 or 16; 16 is not allowed in case of 4 lane

`define RX_CLK_MODE_HS_ONLY	// use HS only if continuous CLK cannot be generated
//`define RX_CLK_MODE_HS_LP		// use only if continuous CLK is generated

`define RX_DPHY_HARD	// Do NOT use Hard D-PHY unless absolutly necessary

`define WORD_ALIGN	// effective only for RX Hard DPHY


`define RX_RGB888
//`define RX_RGB666
//`define RX_RAW8
//`define RX_RAW10
//`define RX_RAW12

//////////

`define BAYER_PATTERN 2'b00
`define H_TX_PEL 13'd1920
`define V_TX_LINE 13'd1080
//////////////////////////////////////////////////////////

`define SYNC_POLARITY_POS	// POS or NEG
`define DE_POLARITY_POS		// POS or NEG

`define TX_PPC 1
//`define TPG_MODE