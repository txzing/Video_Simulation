/**************************************���ܽ���***********************************
Copyright:			
Date     :			
Author   :			
Version  :			
Description:�ԻҶ�ͼ���ֵ�˲�		
*********************************************************************************/
module gray_median_filter
#(
	parameter	IMG_HDISP = 640,	//640*480
	parameter	IMG_VDISP = 480
)
(
    input        clk,  
    input        rst_n,
    
    //Ԥ����Ҷ�����
    input         pre_gray_vsync,   //Ԥ����Ҷȳ�ͬ��
    input         pre_gray_valid,    //Ԥ����Ҷ�������Ч�ź�
    input         pre_gray_clken,    //Ԥ����Ҷ�ʱ��ʹ���ź�
    input [7:0]   pre_gray_data,    //Ԥ����Ҷ�����
    
    //�����Ҷ�����
    output        post_gray_vsync,  //�����Ҷȳ�ͬ���ź�
    output        post_gray_valid,  //�����Ҷ�������Ч�ź�
    output        post_gray_clken,  //�����Ҷ�ʱ��ʹ���ź�
    output [7:0]  post_pixel_data   //�����Ҷ�����
);

//wire define
wire        matrix_frame_vsync;
wire        matrix_frame_href;
wire        matrix_frame_clken;
wire [7:0]  matrix_p11; //3X3 ��������
wire [7:0]  matrix_p12; 
wire [7:0]  matrix_p13;
wire [7:0]  matrix_p21; 
wire [7:0]  matrix_p22; 
wire [7:0]  matrix_p23;
wire [7:0]  matrix_p31; 
wire [7:0]  matrix_p32; 
wire [7:0]  matrix_p33;
wire [7:0]  mid_value ;

//*****************************************************
//**                    main code
//*****************************************************

assign post_pixel_data = post_gray_valid ? mid_value : 8'd0;

 VIP_Matrix_Generate_3X3_8Bit 
 #(
	.IMG_HDISP	(IMG_HDISP),	//640*480
	.IMG_VDISP	(IMG_VDISP)
)
u_VIP_Matrix_Generate_3X3_8Bit(
    .clk        (clk), 
    .rst_n      (rst_n),
    
    //Ԥ����Ҷ�����
    .pre_frame_vsync    (pre_gray_vsync),
    .pre_frame_href     (pre_gray_valid), 
    .pre_frame_clken    (pre_gray_clken),
    .pre_img_Y          (pre_gray_data),
    
    //���3x3����
    .matrix_frame_vsync (matrix_frame_vsync),
    .matrix_frame_href  (matrix_frame_href),
    .matrix_frame_clken (matrix_frame_clken),
    .matrix_p11         (matrix_p11),    
    .matrix_p12         (matrix_p12),    
    .matrix_p13         (matrix_p13),
    .matrix_p21         (matrix_p21),    
    .matrix_p22         (matrix_p22),    
    .matrix_p23         (matrix_p23),
    .matrix_p31         (matrix_p31),    
    .matrix_p32         (matrix_p32),    
    .matrix_p33         (matrix_p33)
);

//3x3������ֵ��ȡ
median_3x3  u_median_3x3(
    .clk                (clk),
    .rst_n              (rst_n),
    
    .median_frame_vsync (matrix_frame_vsync),
    .median_frame_href  (matrix_frame_href),
    .median_frame_clken (matrix_frame_clken),
    
    //�����һ������
    .data11     (matrix_p11), 
    .data12     (matrix_p12), 
    .data13     (matrix_p13),
    //����ڶ�������
    .data21     (matrix_p21), 
    .data22     (matrix_p22), 
    .data23     (matrix_p23),
    //�������������
    .data31     (matrix_p31), 
    .data32     (matrix_p32), 
    .data33     (matrix_p33),
    
    .post_frame_vsync (post_gray_vsync),
    .post_frame_href  (post_gray_valid),
    .post_frame_clken (post_gray_clken),
    .target_data      (mid_value)
);

endmodule 