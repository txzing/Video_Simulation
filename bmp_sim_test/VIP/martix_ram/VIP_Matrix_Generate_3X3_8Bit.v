module  VIP_Matrix_Generate_3X3_8Bit
#(
	parameter	IMG_HDISP = 640,	//640*480
	parameter	IMG_VDISP = 480
)
(
    input            clk,  
    input            rst_n,

    input             pre_frame_vsync,
    input             pre_frame_href,
    input             pre_frame_clken,
    input [7:0]       pre_img_Y,
    
    output           matrix_frame_vsync,
    output           matrix_frame_href,
    output           matrix_frame_clken,
    output reg [7:0] matrix_p11,
    output reg [7:0] matrix_p12, 
    output reg [7:0] matrix_p13,
    output reg [7:0] matrix_p21, 
    output reg [7:0] matrix_p22, 
    output reg [7:0] matrix_p23,
    output reg [7:0] matrix_p31, 
    output reg [7:0] matrix_p32, 
    output reg [7:0] matrix_p33
);

//wire define
wire [7:0] row1_data;  
wire [7:0] row2_data;  

//reg defie
reg  [7:0] row3_data; 
//打2拍，同步信号 
reg  [1:0] pre_frame_vsync_r;
reg  [1:0] pre_frame_href_r;
reg  [1:0] pre_frame_clken_r;

//*****************************************************
//**                    main code
//*****************************************************

assign matrix_frame_vsync = pre_frame_vsync_r[1];
assign matrix_frame_href  = pre_frame_href_r [1];
assign matrix_frame_clken = pre_frame_clken_r[1];

//当前数据放在第3行
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        row3_data <= 0;
    else if(pre_frame_href_r[0])
            if(pre_frame_clken_r[0])   
               row3_data <= pre_img_Y ;
            else
               row3_data <= row3_data ;
    else
        row3_data <= 0;
end

//用于存储列数据的RAM
line_shift_RAM_8bit  
 #(
	.IMG_HDISP	(IMG_HDISP),	 
	.IMG_VDISP	(IMG_VDISP)
)
u_Line_Shift_RAM_8Bit
(
    .clock          (clk),
    .clken          (pre_frame_clken),
    .pre_frame_href (pre_frame_href),
    
    .shiftin        (pre_img_Y),   
    .taps0x         (row2_data),   
    .taps1x         (row1_data)    
);

//将同步信号延迟两拍，用于同步化处理
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pre_frame_vsync_r <= 0;
        pre_frame_href_r  <= 0;
        pre_frame_clken_r <= 0;
    end
    else begin
        pre_frame_vsync_r <= { pre_frame_vsync_r[0], pre_frame_vsync };
        pre_frame_href_r  <= { pre_frame_href_r [0], pre_frame_href  };
        pre_frame_clken_r <= { pre_frame_clken_r[0], pre_frame_clken };
    end
end

//在同步处理后的控制信号下，输出图像矩阵
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        {matrix_p11, matrix_p12, matrix_p13} <= 24'h0;
        {matrix_p21, matrix_p22, matrix_p23} <= 24'h0;
        {matrix_p31, matrix_p32, matrix_p33} <= 24'h0;
    end
    else if(pre_frame_href_r[1]) begin
            if(pre_frame_clken_r[1]) begin
                {matrix_p11, matrix_p12, matrix_p13} <= {matrix_p12, matrix_p13, row1_data};
                {matrix_p21, matrix_p22, matrix_p23} <= {matrix_p22, matrix_p23, row2_data};
                {matrix_p31, matrix_p32, matrix_p33} <= {matrix_p32, matrix_p33, row3_data};
            end
            else begin
                {matrix_p11, matrix_p12, matrix_p13} <= {matrix_p11, matrix_p12, matrix_p13};
                {matrix_p21, matrix_p22, matrix_p23} <= {matrix_p21, matrix_p22, matrix_p23};
                {matrix_p31, matrix_p32, matrix_p33} <= {matrix_p31, matrix_p32, matrix_p33};
            end
    end
    else begin
        {matrix_p11, matrix_p12, matrix_p13} <= 24'h0;
        {matrix_p21, matrix_p22, matrix_p23} <= 24'h0;
        {matrix_p31, matrix_p32, matrix_p33} <= 24'h0;
    end
end

endmodule 