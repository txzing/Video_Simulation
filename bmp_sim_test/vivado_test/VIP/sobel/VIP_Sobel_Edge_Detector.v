/*-----------------------------------------------------------------------
								 \\\|///
							   \\  - -  //
								(  @ @  )
+-----------------------------oOOo-(_)-oOOo-----------------------------+
CONFIDENTIAL IN CONFIDENCE
This confidential and proprietary software may be only used as authorized
by a licensing agreement from CrazyBingo (Thereturnofbingo).
In the event of publication, the following notice is applicable:
Copyright (C) 2011-20xx CrazyBingo Corporation
The entire notice above must be reproduced on all authorized copies.
Author				:		CrazyBingo
Technology blogs 	: 		www.crazyfpga.com
Email Address 		: 		crazyfpga@vip.qq.com
Filename			:		VIP_Sobel_Edge_Detector.v
Date				:		2013-05-26
Description			:		Image edge detector with Sobel.
							Give up the 1th and 2th row edge data caculate for simple process
							Give up the 1th and 2th point of 1 line for simple process
Modification History	:
Date			By			Version			Change Description
=========================================================================
13/05/26		CrazyBingo	1.0				Original
14/03/16		CrazyBingo	2.0				Modification
-------------------------------------------------------------------------
|                                     Oooo								|
+-------------------------------oooO--(   )-----------------------------+
                               (   )   ) /
                                \ (   (_/
                                 \_)
-----------------------------------------------------------------------*/ 

`timescale 1ns/1ns
module VIP_Sobel_Edge_Detector
#(
	parameter	IMG_HDISP = 640,	//640*480
	parameter	IMG_VDISP = 480
)
(
	//global clock
	input				clk,  				//cmos video pixel clock
	input				rst_n,				//global reset

	//Image data prepred to be processd
	input				pre_frame_vsync,	//Prepared Image data vsync valid signal
	input				pre_frame_href,		//Prepared Image data href vaild  signal
	input				pre_frame_clken,	//Prepared Image data output/capture enable clock
	input		[7:0]	pre_img_Y,			//Prepared Image brightness input
	
	//Image data has been processd
	output				post_frame_vsync,	//Processed Image data vsync valid signal
	output				post_frame_href,	//Processed Image data href vaild  signal
	output				post_frame_clken,	//Processed Image data output/capture enable clock
	output				post_img_Bit,		//Processed Image Bit flag outout(1: Value, 0:inValid)
	
	//user interface
	input		[7:0]	Sobel_Threshold		//Sobel Threshold for image edge detect
);

//----------------------------------------------------
//Generate 8Bit 3X3 Matrix for Video Image Processor.
	//Image data has been processd
wire				matrix_frame_vsync;	//Prepared Image data vsync valid signal
wire				matrix_frame_href;	//Prepared Image data href vaild  signal
wire				matrix_frame_clken;	//Prepared Image data output/capture enable clock	
wire		[7:0]	matrix_p11, matrix_p12, matrix_p13;	//3X3 Matrix output
wire		[7:0]	matrix_p21, matrix_p22, matrix_p23;
wire		[7:0]	matrix_p31, matrix_p32, matrix_p33;
VIP_Matrix_Generate_3X3_8Bit	
#(
	.IMG_HDISP	(IMG_HDISP),	//640*480
	.IMG_VDISP	(IMG_VDISP)
)
u_VIP_Matrix_Generate_3X3_8Bit
(
	//global clock
	.clk					(clk),  				//cmos video pixel clock
	.rst_n					(rst_n),				//global reset

	//Image data prepred to be processd
	.pre_frame_vsync		(pre_frame_vsync),		//Prepared Image data vsync valid signal
	.pre_frame_href			(pre_frame_href),		//Prepared Image data href vaild  signal
	.pre_frame_clken		(pre_frame_clken),		//Prepared Image data output/capture enable clock
	.pre_img_Y				(pre_img_Y),			//Prepared Image brightness input

	//Image data has been processd
	.matrix_frame_vsync		(matrix_frame_vsync),	//Processed Image data vsync valid signal
	.matrix_frame_href		(matrix_frame_href),	//Processed Image data href vaild  signal
	.matrix_frame_clken		(matrix_frame_clken),	//Processed Image data output/capture enable clock	
	.matrix_p11(matrix_p11),	.matrix_p12(matrix_p12), 	.matrix_p13(matrix_p13),	//3X3 Matrix output
	.matrix_p21(matrix_p21), 	.matrix_p22(matrix_p22), 	.matrix_p23(matrix_p23),
	.matrix_p31(matrix_p31), 	.matrix_p32(matrix_p32), 	.matrix_p33(matrix_p33)
);


//Add you arithmetic here
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//-------------------------------------------
//Sobel Parameter
//         Gx                  Gy				  Pixel
// [   -1  0   +1  ]   [   +1  +2   +1 ]     [   P11  P12   P13 ]
// [   -2  0   +2  ]   [   0   0    0  ]     [   P21  P22   P23 ]
// [   -1  0   +1  ]   [   -1  -2   -1 ]     [   P31  P32   P33 ]

// localparam	P11 = 8'd15,	P12 = 8'd94,	P13 = 8'd136;
// localparam	P21 = 8'd31,	P22 = 8'd127,	P23 = 8'd231;
// localparam	P31 = 8'd44,	P32 = 8'd181,	P33 = 8'd249;
//Caculate horizontal Grade with |abs|
//Step 1-2
reg	[9:0]	Gx_temp1;	//postive result
reg	[9:0]	Gx_temp2;	//negetive result
reg	[9:0]	Gx_data;	//Horizontal grade data
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		Gx_temp1 <= 0;
		Gx_temp2 <= 0;
		Gx_data <= 0;
		end
	else
		begin
		Gx_temp1 <= matrix_p13 + (matrix_p23 << 1) + matrix_p33;	//postive result
		Gx_temp2 <= matrix_p11 + (matrix_p21 << 1) + matrix_p31;	//negetive result
		Gx_data <= (Gx_temp1 >= Gx_temp2) ? Gx_temp1 - Gx_temp2 : Gx_temp2 - Gx_temp1;
		end
end

//---------------------------------------
//Caculate vertical Grade with |abs|
//Step 1-2
reg	[9:0]	Gy_temp1;	//postive result
reg	[9:0]	Gy_temp2;	//negetive result
reg	[9:0]	Gy_data;	//Vertical grade data
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		Gy_temp1 <= 0;
		Gy_temp2 <= 0;
		Gy_data <= 0;
		end
	else
		begin
		Gy_temp1 <= matrix_p11 + (matrix_p12 << 1) + matrix_p13;	//postive result
		Gy_temp2 <= matrix_p31 + (matrix_p32 << 1) + matrix_p33;	//negetive result
		Gy_data <= (Gy_temp1 >= Gy_temp2) ? Gy_temp1 - Gy_temp2 : Gy_temp2 - Gy_temp1;
		end
end

//---------------------------------------
//Caculate the square of distance = (Gx^2 + Gy^2)
//Step 3
reg	[23:0]	Gxy_square;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		Gxy_square <= 0;
	else
		Gxy_square <= Gx_data * Gx_data + Gy_data * Gy_data;
end

//---------------------------------------
//Caculate the distance of P5 = (Gx^2 + Gy^2)^0.5
//Step 4
wire	[15:0]	Dim;
wire    m_axis_dout_tvalid;
//在Altera平台下
// SQRT	u_SQRT
// (
// 	.radical	(Gxy_square),
// 	.q			(Dim),
// 	.remainder	()
// );
//在Xilinx平台下
//cordic需要11个clock delay出结果
cordic_0   u_cordic_0
(
	.aclk 					(clk),
	.s_axis_cartesian_tvalid(1'b1),
	.s_axis_cartesian_tdata	(Gxy_square),
	.m_axis_dout_tvalid 	(m_axis_dout_tvalid),
	.m_axis_dout_tdata 		(Dim)
);
/*
由于cordic的数据输出是有时钟延时的
假设第1个clock进数据
则第11个clock出结果
故在第12个clock采集结果
*/


//---------------------------------------
//Compare and get the Sobel_data
//Step 5
reg	post_img_Bit_r;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		post_img_Bit_r <= 1'b0;	//Default None
	else if(Dim[10:0] >= Sobel_Threshold)
		post_img_Bit_r <= 1'b1;	//Edge Flag
	else
		post_img_Bit_r <= 1'b0;	//Not Edge
end


//------------------------------------------
//lag 16 clocks signal sync  
reg	[15:0]	pre_frame_vsync_r;
reg	[15:0]	pre_frame_href_r;	
reg	[15:0]	pre_frame_clken_r;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		pre_frame_vsync_r <= 0;
		pre_frame_href_r <= 0;
		pre_frame_clken_r <= 0;
		end
	else
		begin
		pre_frame_vsync_r 	<= 	{pre_frame_vsync_r[14:0], 	matrix_frame_vsync};
		pre_frame_href_r 	<= 	{pre_frame_href_r [14:0], 	matrix_frame_href };
		pre_frame_clken_r 	<= 	{pre_frame_clken_r[14:0], 	matrix_frame_clken};
		end
end
assign	post_frame_vsync 	= 	pre_frame_vsync_r[15];
assign	post_frame_href 	= 	pre_frame_href_r [15];
assign	post_frame_clken 	= 	pre_frame_clken_r[15];
assign	post_img_Bit		=	post_frame_href ? post_img_Bit_r : 1'b0;

endmodule
