//****************************************************************************//
//# @Author: 碎碎思
//# @Date:   2019-10-30 22:03:48
//# @Last Modified by:   zlk
//# @WeChat Official Account: OpenFPGA
//# @Last Modified time: 2019-10-31 21:30:06
//# Description: 
//# @Modification History: 2017-04-22 09:19:50
//# Date			    By			   Version			   Change Description: 
//# ========================================================================= #
//# 2017-04-22 09:19:50
//# ========================================================================= #
//# |                                          								| #
//# |                                OpenFPGA     							| #
//****************************************************************************//

`timescale 1ns/1ns
module Image_RGB888_YCbCr444
(
	//global clock
	input				clk,  				//cmos video pixel clock
	input				rst_n,				//global reset

	//Image data prepred to be processd
	input				per_frame_vsync,	//Prepared Image data vsync valid signal
	input				per_frame_href,		//Prepared Image data href vaild  signal
	input				per_frame_clken,	//Prepared Image data output/capture enable clock	
	input		[7:0]	per_img_red,		//Prepared Image red data to be processed
	input		[7:0]	per_img_green,		//Prepared Image green data to be processed
	input		[7:0]	per_img_blue,		//Prepared Image blue data to be processed
	
	//Image data has been processd
	output				post_frame_vsync,	//Processed Image data vsync valid signal
	output				post_frame_href,	//Processed Image data href vaild  signal
	output				post_frame_clken,	//Processed Image data output/capture enable clock	
	output		[7:0]	post_img_Y,			//Processed Image brightness output
	output		[7:0]	post_img_Cb,		//Processed Image blue shading output
	output		[7:0]	post_img_Cr			//Processed Image red shading output
);

//--------------------------------------------
/*********************************************
　　Y = 0.299 R + 0.587 G + 0.114 B
　　U = - 0.1687 R - 0.3313 G + 0.5 B + 128
　　V = 0.5 R - 0.4187 G - 0.0813 B + 128
--->
	Y 	=	(77 *R 	+ 	150*G 	+ 	29 *B)>>8
	Cb 	=	(-43*R	- 	85 *G	+ 	128*B + 32768)>>8
	Cr 	=	(128*R 	-	107*G  	-	21 *B + 32768)>>8
	
	Y = 0.257*R + 0.504*G + 0.098*B + 16
　　Cb = -0.148*R - 0.291*G + 0.439*B + 128
　　Cr = 0.439*R - 0.368*G - 0.071*B + 128
--->
　　	Y = (66*R + 129*G + 25*B + 4096)>>8
　　Cb = (-38*R - 74*G + 112*B + 32768)>>8
　　Cr = (112*R - 94*G - 18*B + 32768)>>8
**********************************************/
//Step 1
reg	[15:0]	img_red_r0,		img_red_r1,		img_red_r2;	
reg	[15:0]	img_green_r0,	img_green_r1,	img_green_r2; 
reg	[15:0]	img_blue_r0,	img_blue_r1,	img_blue_r2; 
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		img_red_r0		<=	0; 		
		img_red_r1		<=	0; 		
		img_red_r2		<=	0; 	
		img_green_r0	<=	0; 		
		img_green_r1	<=	0; 		
		img_green_r2	<=	0; 	
		img_blue_r0		<=	0; 		
		img_blue_r1		<=	0; 		
		img_blue_r2		<=	0; 			
		end
	else
		begin
		img_red_r0		<=	per_img_red 	* 	8'd66; 		
		img_red_r1		<=	per_img_red 	* 	8'd38; 	
		img_red_r2		<=	per_img_red 	* 	8'd112; 		
		img_green_r0	<=	per_img_green 	* 	8'd129; 		
		img_green_r1	<=	per_img_green 	* 	8'd74; 			
		img_green_r2	<=	per_img_green 	* 	8'd94; 
		img_blue_r0		<=	per_img_blue 	* 	8'd25; 		
		img_blue_r1		<=	per_img_blue 	* 	8'd112; 			
		img_blue_r2		<=	per_img_blue 	* 	8'd18; 		
		end
end

//--------------------------------------------------
//Step 2
reg	[15:0]	img_Y_r0;	
reg	[15:0]	img_Cb_r0; 
reg	[15:0]	img_Cr_r0; 
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		img_Y_r0	<=	0; 		
		img_Cb_r0	<=	0; 		
		img_Cr_r0	<=	0; 	
		end
	else
		begin
		img_Y_r0	<=	img_red_r0 	+ 	img_green_r0 	+ 	img_blue_r0		+	16'd4096; 		
		img_Cb_r0	<=	img_blue_r1 - 	img_red_r1 		- 	img_green_r1	+	16'd32768; 		
		img_Cr_r0	<=	img_red_r2 	- 	img_green_r2 	- 	img_blue_r2		+	16'd32768; 		
		end
end

//--------------------------------------------------
//Step 3
reg	[7:0]	img_Y_r1;	
reg	[7:0]	img_Cb_r1; 
reg	[7:0]	img_Cr_r1; 
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		img_Y_r1	<=	0; 		
		img_Cb_r1	<=	0; 		
		img_Cr_r1	<=	0; 	
		end
	else
		begin
		img_Y_r1	<=	img_Y_r0[15:8];
		img_Cb_r1	<=	img_Cb_r0[15:8];
		img_Cr_r1	<=	img_Cr_r0[15:8]; 
		end
end



//------------------------------------------
//lag 3 clocks signal sync  
reg	[2:0]	per_frame_vsync_r;
reg	[2:0]	per_frame_href_r;	
reg	[2:0]	per_frame_clken_r;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		per_frame_vsync_r <= 0;
		per_frame_href_r <= 0;
		per_frame_clken_r <= 0;
		end
	else
		begin
		per_frame_vsync_r 	<= 	{per_frame_vsync_r[1:0], 	per_frame_vsync};
		per_frame_href_r 	<= 	{per_frame_href_r[1:0], 	per_frame_href};
		per_frame_clken_r 	<= 	{per_frame_clken_r[1:0], 	per_frame_clken};
		end
end
assign	post_frame_vsync 	= 	per_frame_vsync_r[2];
assign	post_frame_href 	= 	per_frame_href_r[2];
assign	post_frame_clken 	= 	per_frame_clken_r[2];
assign	post_img_Y 	= 	post_frame_href ? img_Y_r1 : 8'd0;
assign	post_img_Cb =	post_frame_href ? img_Cb_r1: 8'd0;
assign	post_img_Cr = 	post_frame_href ? img_Cr_r1: 8'd0;
endmodule
