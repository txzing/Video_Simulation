`timescale 1ns/1ps
module video_down_sample
   #( 
    parameter COLUMN_DOWN = 1'b1,
    parameter LINE_DOWN   = 1'b1,        
    parameter VIDEO_FORMAT = "RGB",
    parameter SAMPLES_PER_CLOCK = 8,
    parameter MAXIMUM_DATA_WIDTH = 8,
    // parameter MAXIMUM_NUMBER_OF_COLUMNS = 1280,
    // parameter MAXIMUM_NUMBER_OF_ROWS = 720,

    parameter S_AXIS_BYTES = 3,
    parameter S_AXIS_WIDTH = 24,
    parameter M_AXIS_BYTES = 3,
    parameter M_AXIS_WIDTH = 24 
   )
   (
    input                       aclk,
    input                       aresetn,
//input interface
    input                       s_axis_tvalid,
    output                      s_axis_tready,
    input  [S_AXIS_WIDTH -1:0]  s_axis_tdata,
    input                       s_axis_tlast,
    input  [0:0]                s_axis_tuser,
//output interface   
    output                      m_axis_tvalid,
    input                       m_axis_tready,
    output [M_AXIS_WIDTH -1:0]  m_axis_tdata,
    output                      m_axis_tlast,
    output [0:0]                m_axis_tuser
    );

parameter NUM_VIDEO_COMPONENTS = ((VIDEO_FORMAT == "YUV 4:2:2:") || (VIDEO_FORMAT == "YUV 4:2:0:") || (VIDEO_FORMAT == "YUVA 4:2:0:")) ? 2 : 
				((VIDEO_FORMAT == "YUV 4:4:4:") || (VIDEO_FORMAT == "RGB") || (VIDEO_FORMAT == "YUVA 4:2:2:") || (VIDEO_FORMAT == "SMPTE 352 YUV 4:2:0:")) ? 3 : 
				((VIDEO_FORMAT == "YUVA 4:4:4:") || (VIDEO_FORMAT == "RGBA") || (VIDEO_FORMAT == "YUVD 4:2:2:") || (VIDEO_FORMAT == "YUVD 4:4:4:") || (VIDEO_FORMAT == "RGBD")) ? 4 : 1;

parameter PIEXL_WIDTH = NUM_VIDEO_COMPONENTS * MAXIMUM_DATA_WIDTH;

//parameter  S_AXIS_BYTES = ((SAMPLES_PER_CLOCK*MAXIMUM_DATA_WIDTH*NUM_VIDEO_COMPONENTS+7)/8);
//parameter  S_AXIS_WIDTH = ((SAMPLES_PER_CLOCK*MAXIMUM_DATA_WIDTH*NUM_VIDEO_COMPONENTS+7)/8)*8;
//parameter  M_AXIS_BYTES = ((SAMPLES_PER_CLOCK*MAXIMUM_DATA_WIDTH*NUM_VIDEO_COMPONENTS+7)/8);
//parameter  M_AXIS_WIDTH = ((SAMPLES_PER_CLOCK*MAXIMUM_DATA_WIDTH*NUM_VIDEO_COMPONENTS+7)/8) * 8;

generate
    if(SAMPLES_PER_CLOCK==1)
    v_dsampler_1ppc 
    #(   
        .COLUMN_DOWN (COLUMN_DOWN),
        .LINE_DOWN   (LINE_DOWN  ),
        .S_AXIS_WIDTH(S_AXIS_WIDTH),
        .M_AXIS_WIDTH(M_AXIS_WIDTH),
	    .PIEXL_WIDTH(PIEXL_WIDTH)
	)
    inst0
    (
/*     input                          */.aclk          (aclk   ),
/*     input                          */.aresetn       (aresetn),
// input interface
/*     input                          */.s_axis_tvalid (s_axis_tvalid),
/*     output                         */.s_axis_tready (s_axis_tready),
/*     input  [S_AXIS_WIDTH -1:0]     */.s_axis_tdata  (s_axis_tdata ),
/*     input                          */.s_axis_tlast  (s_axis_tlast ),
/*     input  [0:0]                   */.s_axis_tuser  (s_axis_tuser ),
// output interface     
/*     output reg                     */.m_axis_tvalid (m_axis_tvalid),
/*     input                          */.m_axis_tready (m_axis_tready),
/*     output reg [M_AXIS_WIDTH -1:0] */.m_axis_tdata  (m_axis_tdata ),
/*     output                         */.m_axis_tlast  (m_axis_tlast ),
/*     output [0:0]                   */.m_axis_tuser  (m_axis_tuser )
    );

    else if (SAMPLES_PER_CLOCK==2)
    v_dsampler_2ppc 
    #(   
        .COLUMN_DOWN (COLUMN_DOWN),
        .LINE_DOWN   (LINE_DOWN  ),
        .S_AXIS_WIDTH(S_AXIS_WIDTH),
        .M_AXIS_WIDTH(M_AXIS_WIDTH),
	    .PIEXL_WIDTH(PIEXL_WIDTH)
	)
    inst0
    (
/*     input                          */.aclk          (aclk   ),
/*     input                          */.aresetn       (aresetn),
// input interface
/*     input                          */.s_axis_tvalid (s_axis_tvalid),
/*     output                         */.s_axis_tready (s_axis_tready),
/*     input  [S_AXIS_WIDTH -1:0]     */.s_axis_tdata  (s_axis_tdata ),
/*     input                          */.s_axis_tlast  (s_axis_tlast ),
/*     input  [0:0]                   */.s_axis_tuser  (s_axis_tuser ),
// output interface     
/*     output reg                     */.m_axis_tvalid (m_axis_tvalid),
/*     input                          */.m_axis_tready (m_axis_tready),
/*     output reg [M_AXIS_WIDTH -1:0] */.m_axis_tdata  (m_axis_tdata ),
/*     output                         */.m_axis_tlast  (m_axis_tlast ),
/*     output [0:0]                   */.m_axis_tuser  (m_axis_tuser )
    );

    else if (SAMPLES_PER_CLOCK==4)
    v_dsampler_4ppc 
    #(   
        .COLUMN_DOWN (COLUMN_DOWN),
        .LINE_DOWN   (LINE_DOWN  ),
        .S_AXIS_WIDTH(S_AXIS_WIDTH),
        .M_AXIS_WIDTH(M_AXIS_WIDTH),
	    .PIEXL_WIDTH(PIEXL_WIDTH)
	)
    inst0
    (
/*     input                          */.aclk          (aclk   ),
/*     input                          */.aresetn       (aresetn),
// input interface
/*     input                          */.s_axis_tvalid (s_axis_tvalid),
/*     output                         */.s_axis_tready (s_axis_tready),
/*     input  [S_AXIS_WIDTH -1:0]     */.s_axis_tdata  (s_axis_tdata ),
/*     input                          */.s_axis_tlast  (s_axis_tlast ),
/*     input  [0:0]                   */.s_axis_tuser  (s_axis_tuser ),
// output interface     
/*     output reg                     */.m_axis_tvalid (m_axis_tvalid),
/*     input                          */.m_axis_tready (m_axis_tready),
/*     output reg [M_AXIS_WIDTH -1:0] */.m_axis_tdata  (m_axis_tdata ),
/*     output                         */.m_axis_tlast  (m_axis_tlast ),
/*     output [0:0]                   */.m_axis_tuser  (m_axis_tuser )
    );

    else if (SAMPLES_PER_CLOCK==8)
    v_dsampler_8ppc 
    #(   
        .COLUMN_DOWN (COLUMN_DOWN),
        .LINE_DOWN   (LINE_DOWN  ),
        .S_AXIS_WIDTH(S_AXIS_WIDTH),
        .M_AXIS_WIDTH(M_AXIS_WIDTH),
	    .PIEXL_WIDTH(PIEXL_WIDTH)
	)
    inst0
    (
/*     input                          */.aclk          (aclk   ),
/*     input                          */.aresetn       (aresetn),
// input interface
/*     input                          */.s_axis_tvalid (s_axis_tvalid),
/*     output                         */.s_axis_tready (s_axis_tready),
/*     input  [S_AXIS_WIDTH -1:0]     */.s_axis_tdata  (s_axis_tdata ),
/*     input                          */.s_axis_tlast  (s_axis_tlast ),
/*     input  [0:0]                   */.s_axis_tuser  (s_axis_tuser ),
// output interface     
/*     output reg                     */.m_axis_tvalid (m_axis_tvalid),
/*     input                          */.m_axis_tready (m_axis_tready),
/*     output reg [M_AXIS_WIDTH -1:0] */.m_axis_tdata  (m_axis_tdata ),
/*     output                         */.m_axis_tlast  (m_axis_tlast ),
/*     output [0:0]                   */.m_axis_tuser  (m_axis_tuser )
    );

endgenerate

////////////////
endmodule
