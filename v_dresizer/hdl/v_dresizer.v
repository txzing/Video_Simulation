`timescale 1ns/1ps
module v_dresizer
#( 
    parameter COLUMN_DOWN                       = 1'b1,
    parameter LINE_DOWN                         = 1'b1,        
    parameter VIDEO_FORMAT                      = "RGB",
    parameter SAMPLES_PER_CLOCK                 = 1,
    parameter MAXIMUM_DATA_WIDTH                = 8,
//    parameter MAXIMUM_NUMBER_OF_COLUMNS = 1280,
//    parameter MAXIMUM_NUMBER_OF_ROWS = 720,
    parameter S_AXIS_BYTES                      = 3,
    parameter S_AXIS_WIDTH                      = 24,
    parameter M_AXIS_BYTES                      = 3,
    parameter M_AXIS_WIDTH                      = 24 
)
(
    aclk,
    aresetn,
//input interface
    s_axis_tdata,
    s_axis_tdest,
    s_axis_tid,
    s_axis_tkeep,
    s_axis_tlast,
    s_axis_tready,
    s_axis_tstrb,
    s_axis_tuser,
    s_axis_tvalid,
//output interface   
    m_axis_tdata,
    m_axis_tdest,
    m_axis_tid,
    m_axis_tkeep,
    m_axis_tlast,
    m_axis_tready,
    m_axis_tstrb,
    m_axis_tuser,
    m_axis_tvalid
);

parameter NUM_VIDEO_COMPONENTS = ((VIDEO_FORMAT == "YUV 4:2:2:") || (VIDEO_FORMAT == "YUV 4:2:0:") || (VIDEO_FORMAT == "YUVA 4:2:0:")) ? 2 : 
				((VIDEO_FORMAT == "YUV 4:4:4:") || (VIDEO_FORMAT == "RGB") || (VIDEO_FORMAT == "YUVA 4:2:2:") || (VIDEO_FORMAT == "SMPTE 352 YUV 4:2:0:")) ? 3 : 
				((VIDEO_FORMAT == "YUVA 4:4:4:") || (VIDEO_FORMAT == "RGBA") || (VIDEO_FORMAT == "YUVD 4:2:2:") || (VIDEO_FORMAT == "YUVD 4:4:4:") || (VIDEO_FORMAT == "RGBD")) ? 4 : 1;

parameter PIEXL_WIDTH = NUM_VIDEO_COMPONENTS * MAXIMUM_DATA_WIDTH;

//parameter  S_AXIS_BYTES = ((SAMPLES_PER_CLOCK*MAXIMUM_DATA_WIDTH*NUM_VIDEO_COMPONENTS+7)/8);
//parameter  S_AXIS_WIDTH = ((SAMPLES_PER_CLOCK*MAXIMUM_DATA_WIDTH*NUM_VIDEO_COMPONENTS+7)/8)*8;
//parameter  M_AXIS_BYTES = ((SAMPLES_PER_CLOCK*MAXIMUM_DATA_WIDTH*NUM_VIDEO_COMPONENTS+7)/8);
//parameter  M_AXIS_WIDTH = ((SAMPLES_PER_CLOCK*MAXIMUM_DATA_WIDTH*NUM_VIDEO_COMPONENTS+7)/8)*8;

input   aclk;
input   aresetn;

input  [S_AXIS_WIDTH -1:0]  s_axis_tdata;
input                       s_axis_tvalid;
output                      s_axis_tready;
input  [S_AXIS_BYTES -1:0]  s_axis_tkeep;
input  [S_AXIS_BYTES -1:0]  s_axis_tstrb;
input  [0:0]                s_axis_tuser;
input  [0:0]                s_axis_tlast;
input  [0:0]                s_axis_tid;
input  [0:0]                s_axis_tdest;
output [M_AXIS_WIDTH-1:0]   m_axis_tdata;
output                      m_axis_tvalid;
input                       m_axis_tready;
output [M_AXIS_BYTES -1:0]  m_axis_tkeep;
output [M_AXIS_BYTES -1:0]  m_axis_tstrb;
output [0:0]                m_axis_tuser;
output [0:0]                m_axis_tlast;
output [0:0]                m_axis_tid;
output [0:0]                m_axis_tdest;


generate
    if(SAMPLES_PER_CLOCK==1)
    v_dresizer_1ppc 
    #(   
        .COLUMN_DOWN (COLUMN_DOWN),
        .LINE_DOWN   (LINE_DOWN  ),
        .S_AXIS_WIDTH(S_AXIS_WIDTH),
        .M_AXIS_WIDTH(M_AXIS_WIDTH),
	    .PIEXL_WIDTH(PIEXL_WIDTH)
	)
    inst0
    (
        .aclk           (aclk           ),
        .aresetn        (aresetn        ),
        .s_axis_tdata   (s_axis_tdata   ),
        .s_axis_tvalid  (s_axis_tvalid  ),
        .s_axis_tready  (s_axis_tready  ),
        .s_axis_tkeep   (s_axis_tkeep   ),
        .s_axis_tstrb   (s_axis_tstrb   ),
        .s_axis_tuser   (s_axis_tuser   ),
        .s_axis_tlast   (s_axis_tlast   ),
        .s_axis_tid     (s_axis_tid     ),
        .s_axis_tdest   (s_axis_tdest   ),
        .m_axis_tdata   (m_axis_tdata   ),
        .m_axis_tvalid  (m_axis_tvalid  ),
        .m_axis_tready  (m_axis_tready  ),
        .m_axis_tkeep   (m_axis_tkeep   ),
        .m_axis_tstrb   (m_axis_tstrb   ),
        .m_axis_tuser   (m_axis_tuser   ),
        .m_axis_tlast   (m_axis_tlast   ),
        .m_axis_tid     (m_axis_tid     ),
        .m_axis_tdest   (m_axis_tdest   )
    );

    else if (SAMPLES_PER_CLOCK==2)
    v_dresizer_2ppc 
    #(   
        .COLUMN_DOWN (COLUMN_DOWN),
        .LINE_DOWN   (LINE_DOWN  ),
        .S_AXIS_WIDTH(S_AXIS_WIDTH),
        .M_AXIS_WIDTH(M_AXIS_WIDTH),
	    .PIEXL_WIDTH(PIEXL_WIDTH)
	)
    inst0
    (
        .aclk           (aclk           ),
        .aresetn        (aresetn        ),
        .s_axis_tdata   (s_axis_tdata   ),
        .s_axis_tvalid  (s_axis_tvalid  ),
        .s_axis_tready  (s_axis_tready  ),
        .s_axis_tkeep   (s_axis_tkeep   ),
        .s_axis_tstrb   (s_axis_tstrb   ),
        .s_axis_tuser   (s_axis_tuser   ),
        .s_axis_tlast   (s_axis_tlast   ),
        .s_axis_tid     (s_axis_tid     ),
        .s_axis_tdest   (s_axis_tdest   ),
        .m_axis_tdata   (m_axis_tdata   ),
        .m_axis_tvalid  (m_axis_tvalid  ),
        .m_axis_tready  (m_axis_tready  ),
        .m_axis_tkeep   (m_axis_tkeep   ),
        .m_axis_tstrb   (m_axis_tstrb   ),
        .m_axis_tuser   (m_axis_tuser   ),
        .m_axis_tlast   (m_axis_tlast   ),
        .m_axis_tid     (m_axis_tid     ),
        .m_axis_tdest   (m_axis_tdest   )
    );

    else if (SAMPLES_PER_CLOCK==4)
    v_dresizer_4ppc 
    #(   
        .COLUMN_DOWN (COLUMN_DOWN),
        .LINE_DOWN   (LINE_DOWN  ),
        .S_AXIS_WIDTH(S_AXIS_WIDTH),
        .M_AXIS_WIDTH(M_AXIS_WIDTH),
	    .PIEXL_WIDTH(PIEXL_WIDTH)
	)
    inst0
    (
        .aclk           (aclk           ),
        .aresetn        (aresetn        ),
        .s_axis_tdata   (s_axis_tdata   ),
        .s_axis_tvalid  (s_axis_tvalid  ),
        .s_axis_tready  (s_axis_tready  ),
        .s_axis_tkeep   (s_axis_tkeep   ),
        .s_axis_tstrb   (s_axis_tstrb   ),
        .s_axis_tuser   (s_axis_tuser   ),
        .s_axis_tlast   (s_axis_tlast   ),
        .s_axis_tid     (s_axis_tid     ),
        .s_axis_tdest   (s_axis_tdest   ),
        .m_axis_tdata   (m_axis_tdata   ),
        .m_axis_tvalid  (m_axis_tvalid  ),
        .m_axis_tready  (m_axis_tready  ),
        .m_axis_tkeep   (m_axis_tkeep   ),
        .m_axis_tstrb   (m_axis_tstrb   ),
        .m_axis_tuser   (m_axis_tuser   ),
        .m_axis_tlast   (m_axis_tlast   ),
        .m_axis_tid     (m_axis_tid     ),
        .m_axis_tdest   (m_axis_tdest   )
    );

    else if (SAMPLES_PER_CLOCK==8)
    v_dresizer_8ppc 
    #(   
        .COLUMN_DOWN (COLUMN_DOWN),
        .LINE_DOWN   (LINE_DOWN  ),
        .S_AXIS_WIDTH(S_AXIS_WIDTH),
        .M_AXIS_WIDTH(M_AXIS_WIDTH),
	    .PIEXL_WIDTH(PIEXL_WIDTH)
	)
    inst0
    (
        .aclk           (aclk           ),
        .aresetn        (aresetn        ),
        .s_axis_tdata   (s_axis_tdata   ),
        .s_axis_tvalid  (s_axis_tvalid  ),
        .s_axis_tready  (s_axis_tready  ),
        .s_axis_tkeep   (s_axis_tkeep   ),
        .s_axis_tstrb   (s_axis_tstrb   ),
        .s_axis_tuser   (s_axis_tuser   ),
        .s_axis_tlast   (s_axis_tlast   ),
        .s_axis_tid     (s_axis_tid     ),
        .s_axis_tdest   (s_axis_tdest   ),
        .m_axis_tdata   (m_axis_tdata   ),
        .m_axis_tvalid  (m_axis_tvalid  ),
        .m_axis_tready  (m_axis_tready  ),
        .m_axis_tkeep   (m_axis_tkeep   ),
        .m_axis_tstrb   (m_axis_tstrb   ),
        .m_axis_tuser   (m_axis_tuser   ),
        .m_axis_tlast   (m_axis_tlast   ),
        .m_axis_tid     (m_axis_tid     ),
        .m_axis_tdest   (m_axis_tdest   )
    );

endgenerate

////////////////
endmodule
