//****************************************************************************//
//# @Author: 纰庣鎬?
//# @Date:   2019-11-03 01:23:11
//# @Last Modified by:   zlk
//# @WeChat Official Account: OpenFPGA
//# @Last Modified time: 2017-04-22 09:19:50
//# Description: 
//# @Modification History: 2017-04-22 09:19:50
//# Date			    By			   Version			   Change Description: 
//# ========================================================================= #
//# 2017-04-22 09:19:50 CrazyBingo	1.0	
//# ========================================================================= #
//# |                                          								| #
//# |                                OpenFPGA     							| #
//****************************************************************************//

`timescale 1ns/1ns
module Image_YCbCr444_YCbCr422
(
	//global clock
	input				clk,  				//cmos video pixel clock
	input				rst_n,				//global reset

	//CMOS 16Bit YCbCr data input:	{CbYCrYCbYCrY}
	input				per_frame_vsync,	//Prepared Image data vsync valid signal
	input				per_frame_href,		//Prepared Image data href vaild  signal
	input				per_frame_clken,	//Prepared Image data output/capture enable clock	
	input		[7:0]	per_img_Y,			//Prepared Image data of YCbCr 4:4:4
	input		[7:0]	per_img_Cb,			//Prepared Image data of YCbCr 4:4:4
	input		[7:0]	per_img_Cr,			//Prepared Image data of YCbCr 4:4:4
	
	//CMOS YCbCr444 data output
	output				post_frame_vsync,	//Processed Image data vsync valid signal
	output				post_frame_href,	//Processed Image data href vaild  signal
	output				post_frame_clken,	//Processed Image data output/capture enable clock	
	output	reg	[15:0]	post_img_YCbCr		//Processed Image data of YCbCr 4:2:2 {CbY} {CrY}
);

//------------------------------------------
//lag n pixel clocks	 
reg	[4:0]	post_frame_vsync_r;
reg	[4:0]	post_frame_href_r;
reg	[4:0]	post_frame_clken_r;
//reg [8:0]   cb_sum = {9{1'b0}};
//reg [8:0]   cr_sum = {9{1'b0}};
reg [7:0]   per_img_Y_r [0:4];
reg [7:0]   per_img_Cb_r [0:4];
reg [7:0]   per_img_Cr_r [0:4];
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		post_frame_vsync_r 	<= 	0;
		post_frame_href_r 	<= 	0;
		post_frame_clken_r 	<= 	0;
		per_img_Y_r[0]      <=  7'b0;
		per_img_Y_r[1]      <=  7'b0;
		per_img_Y_r[2]      <=  7'b0;
		per_img_Y_r[3]      <=  7'b0;
		per_img_Y_r[4]      <=  7'b0;
		per_img_Cb_r[0]      <=  7'b0;
		per_img_Cb_r[1]      <=  7'b0;
		per_img_Cb_r[2]      <=  7'b0;
		per_img_Cb_r[3]      <=  7'b0;
		per_img_Cb_r[4]      <=  7'b0;
		per_img_Cr_r[0]      <=  7'b0;
		per_img_Cr_r[1]      <=  7'b0;
		per_img_Cr_r[2]      <=  7'b0;
		per_img_Cr_r[3]      <=  7'b0;
		per_img_Cr_r[4]      <=  7'b0;
	end
	else
	begin
		post_frame_vsync_r 	<= 	{post_frame_vsync_r[3:0], per_frame_vsync};
		post_frame_href_r 	<= 	{post_frame_href_r[3:0], per_frame_href};
		post_frame_clken_r 	<= 	{post_frame_clken_r[3:0], per_frame_clken};
		per_img_Y_r[4]      <=  per_img_Y_r[3];
		per_img_Y_r[3]      <=  per_img_Y_r[2];
		per_img_Y_r[2]      <=  per_img_Y_r[1];
		per_img_Y_r[1]      <=  per_img_Y_r[0];
		per_img_Y_r[0]      <=  per_img_Y;
		per_img_Cb_r[4]     <=  per_img_Cb_r[3];
		per_img_Cb_r[3]     <=  per_img_Cb_r[2];
		per_img_Cb_r[2]     <=  per_img_Cb_r[1];
		per_img_Cb_r[1]     <=  per_img_Cb_r[0];
		per_img_Cb_r[0]     <=  per_img_Cb;
		per_img_Cr_r[4]     <=  per_img_Cr_r[3];
		per_img_Cr_r[3]     <=  per_img_Cr_r[2];
		per_img_Cr_r[2]     <=  per_img_Cr_r[1];
		per_img_Cr_r[1]     <=  per_img_Cr_r[0];
		per_img_Cr_r[0]     <=  per_img_Cr;
	end
end
assign	post_frame_vsync 	= 	post_frame_vsync_r[2];
assign	post_frame_href 	= 	post_frame_href_r[2];
assign	post_frame_clken 	= 	post_frame_clken_r[2];
//wire	yuv_process_href	= 	per_frame_href || post_frame_href_r[3];  // width = per_frame_href + taps
//wire	yuv_process_clken	= 	per_frame_clken || post_frame_clken_r[3];

//assign cb_sum = {1'b0, per_img_Cb} + {1'b0, per_img_Cb_r[0]};
//assign cr_sum = {1'b0, per_img_Cr} + {1'b0, per_img_Cr_r[0]};

//-------------------------------------------
//convert YCbCr444 to YCbCr422
/*

0	1	2		    3		    4		    5		    6		    7		8
i0	i1	i2		    i3		    i4		    i5		    0		    0		0

0	i0	i1		    i2		    i3		    i4		    i5		    0		0
0	0	i0		    i1		    i2		    i3		    i4		    i5		0
0	0	0		    i0		    i1		    i2		    i3		    i4		i5
0	0	0		    0		    i0		    i1		    i2		    i3		i4

0	0	(i0+i1)/2	(i1+i2)/2	(i2+i2)/2	(i3+i4)/2	(i4+i5)/2	i5		0
0	0	0		    i0'		    i1'		    i2'		    i3'		    i4'		i5'
0	0	0		    1		    0		    1		    0		    1		0
*/
reg [7:0]   cb = {8{1'b0}};
reg [7:0]   cr = {8{1'b0}};
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		cb  <=  {8{1'b0}};
		cr  <=  {8{1'b0}};
	end
	else if(post_frame_href_r[0])
	begin
		if(post_frame_clken_r[0])
		begin
		    if(post_frame_href)
		    begin
			    cb  <= ({1'b0, per_img_Cb} + {1'b0, per_img_Cb_r[0]})>>1; // divid by 2
                cr  <= ({1'b0, per_img_Cr} + {1'b0, per_img_Cr_r[0]})>>1;
            end
            else
            begin
                cb  <= {1'b0, per_img_Cb_r[0]}; 
                cr  <= {1'b0, per_img_Cr_r[0]};
            end
		end
		else
		begin
			cb  <=  cb;
			cr  <=  cr;
		end
	end
	else
	begin
		cb  <=  {8{1'b0}};
		cr  <=  {8{1'b0}};
	end
end

reg cb_flag;
always@(posedge clk or negedge rst_n)
begin
	if((!rst_n) || (post_frame_href_r[0]&~post_frame_href_r[1]))
	begin
		cb_flag <= 1'b0;
		post_img_YCbCr <= 16'b0;
	end
	else if(post_frame_href_r[1])
	begin
		if(post_frame_clken_r[1])
		begin
			cb_flag <= ~cb_flag;
			post_img_YCbCr <= {cb_flag ? cb : cr, per_img_Y_r[1]};
		end
		else
		begin
			cb_flag <= cb_flag;
			post_img_YCbCr <= post_img_YCbCr;
		end
	end
	else
	begin
		cb_flag <= 1'b0;
		post_img_YCbCr <= 16'b0;
	end
end

endmodule
