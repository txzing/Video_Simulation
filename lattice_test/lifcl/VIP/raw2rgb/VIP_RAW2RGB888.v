`timescale 1ns/1ns
/*
����DATA_W��̬ȷ����������֧��raw8,raw10,raw12��
*/
module VIP_RAW2RGB888
#(
	parameter [1:0] BAYER_PATTERN = 2'b00,
	parameter	[12:0]	IMG_HDISP = 13'd640,	//640*480
	parameter	[12:0]	IMG_VDISP = 13'd480,
    parameter	[4:0]   DATA_W    = 5'd8
)
(
	//global clock
	input				clk,  				//cmos video pixel clock
	input				rst_n,				//global reset

	//CMOS YCbCr444 data output
	input				pre_frame_vsync,	//Prepared Image data vsync valid signal
	input				pre_frame_href,		//Prepared Image data href vaild  signal

	input		[DATA_W -1 :0]	pre_img_RAW,		//Prepared Image data 8 Bit RAW Data

	
	//CMOS RGB888 data output
	output				post_frame_vsync,	//Processed Image data vsync valid signal
	output				post_frame_href,	//Processed Image data href vaild  signal
	output		[DATA_W -1 :0]	post_img_red,		//Prepared Image green data to be processed	
	output		[DATA_W -1 :0]	post_img_green,		//Prepared Image green data to be processed
	output		[DATA_W -1 :0]	post_img_blue		//Prepared Image blue data to be processed
);

//----------------------------------------------------
//Generate 8Bit 3X3 Matrix for Video Image Processor.
	//Image data has been processd
wire				matrix_frame_vsync;	//Prepared Image data vsync valid signal
wire				matrix_frame_href;	//Prepared Image data href vaild  signal
wire		[DATA_W -1 :0]	matrix_p11, matrix_p12, matrix_p13;	//3X3 Matrix output
wire		[DATA_W -1 :0]	matrix_p21, matrix_p22, matrix_p23;
wire		[DATA_W -1 :0]	matrix_p31, matrix_p32, matrix_p33;
VIP_Matrix_Generate_3X3_8Bit	
#(
	.IMG_HDISP	(IMG_HDISP),	//640*480
    .DATA_W		(DATA_W)
)
u_VIP_Matrix_Generate_3X3_8Bit
(
	//global clock
	.clk					(clk),  				//cmos video pixel clock
	.rst_n					(rst_n),				//global reset

	//Image data prepred to be processd
	.pre_frame_vsync		(pre_frame_vsync),		//Prepared Image data vsync valid signal
	.pre_frame_href			(pre_frame_href),		//Prepared Image data href vaild  signal
	.pre_frame_clken		(pre_frame_href),            //Prepared Image data output/capture enable clock
	.pre_img_Y				(pre_img_RAW),			//Prepared Image brightness input
	//Image data has been processd
	.matrix_frame_vsync		(matrix_frame_vsync),	//Processed Image data vsync valid signal
	.matrix_frame_href		(matrix_frame_href),	//Processed Image data href vaild  signal
	.matrix_frame_clken		(matrix_frame_clken),
	.matrix_p11(matrix_p11),	.matrix_p12(matrix_p12), 	.matrix_p13(matrix_p13),	//3X3 Matrix output
	.matrix_p21(matrix_p21), 	.matrix_p22(matrix_p22), 	.matrix_p23(matrix_p23),
	.matrix_p31(matrix_p31), 	.matrix_p32(matrix_p32), 	.matrix_p33(matrix_p33)
);


//-------------------------------------------------------------
//sync the frame vsync and href signal and generate frame begin & end signal
reg		matrix_frame_href_r;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		matrix_frame_href_r <= 0;
	else
		matrix_frame_href_r <= matrix_frame_href;
end

wire	matrix_frame_href_end	=	(matrix_frame_href_r & ~matrix_frame_href) ? 1'b1 : 1'b0;	//Line over signal

//----------------------------------------
//Count the frame lines
reg	[13:0]	line_cnt;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		line_cnt <= 0;
	else if(matrix_frame_vsync == 1'b1)	//Frame valid
		begin
		if(matrix_frame_href_end)
			line_cnt <= line_cnt + 1'b1;
		else
			line_cnt <= line_cnt;
		end
	else
		line_cnt <= 0;
end

//----------------------------------------
//Count the pixels
reg	[13:0]	point_cnt;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		point_cnt <= 0;
	else if(matrix_frame_href == 1'b1)	//Line valid
		point_cnt <= point_cnt + 1'b1;
	else
		point_cnt <= 0;
end

//--------------------------------------
//Convet RAW 2 RGB888 Format
//
reg	[DATA_W -1 :0]	post_img_red_r;
reg	[DATA_W -1 :0]	post_img_green_r;
reg	[DATA_W -1 :0]	post_img_blue_r;

generate
    if(BAYER_PATTERN == 2'b00) //RGGB
    begin
        always@(posedge clk or negedge rst_n)
        begin
            if(!rst_n)
            begin
				post_img_red_r	 <=	0;
				post_img_green_r <=	0;
				post_img_blue_r	 <=	0;
            end
            else if(matrix_frame_vsync && matrix_frame_vsync)
            begin
                case({line_cnt[0], point_cnt[0]})
                2'b00:	//odd lines + odd point
                    begin	//Center Blue
						post_img_red_r	 <=	(matrix_p11 + matrix_p13 + matrix_p31 + matrix_p33)>>2;
						post_img_green_r <=	(matrix_p12 + matrix_p21 + matrix_p23 + matrix_p32)>>2;
						post_img_blue_r	 <=	 matrix_p22;			
                    end
                2'b01:	//odd lines + even point
                    begin	//Center Green
						post_img_red_r	 <=	(matrix_p12 + matrix_p32)>>1;
						post_img_green_r <=	matrix_p22;
						post_img_blue_r	 <=	(matrix_p21 + matrix_p23)>>1;
                    end
                2'b10:	//even lines + odd point
                    begin	//Center Green
						post_img_red_r	 <=	(matrix_p21 + matrix_p23)>>1;
						post_img_green_r <=	matrix_p22;
						post_img_blue_r	 <=	(matrix_p12 + matrix_p32)>>1;
                    end
                2'b11: //even lines + even point
                    begin	//Center Red
						post_img_red_r	 <=	matrix_p22;
						post_img_green_r <=	(matrix_p12 + matrix_p21 + matrix_p23 + matrix_p32)>>2;
						post_img_blue_r	 <=	(matrix_p11 + matrix_p13 + matrix_p31 + matrix_p33)>>2;
                    end
                endcase
            end
            else
            begin
				post_img_red_r	 <=	0;
				post_img_green_r <=	0;
				post_img_blue_r	 <=	0;
            end
        end
    end
    else if(BAYER_PATTERN == 2'b01)//GRBG
    begin
        always@(posedge clk or negedge rst_n)
        begin
            if(!rst_n)
            begin
				post_img_red_r	 <=	0;
				post_img_green_r <=	0;
				post_img_blue_r	 <=	0;
            end
            else if(matrix_frame_vsync && matrix_frame_vsync)
            begin
                case({line_cnt[0], point_cnt[0]})
                2'b00:	//odd lines + odd point
                    begin	
						post_img_red_r	 <=	(matrix_p12 + matrix_p32)>>1;
						post_img_green_r <=	(matrix_p11 + matrix_p13 + matrix_p31 + matrix_p33)>>2;
						post_img_blue_r	 <=	(matrix_p21 + matrix_p23)>>1;	
                    end
                2'b01:	//odd lines + even point
                    begin	
						post_img_red_r	 <=	(matrix_p11 + matrix_p13 + matrix_p31 + matrix_p33)>>2;
						post_img_green_r <=	(matrix_p12 + matrix_p21 + matrix_p23 + matrix_p32)>>2;
						post_img_blue_r	 <=	matrix_p22;	
                    end
                2'b10:	//even lines + odd point
                    begin	
						post_img_red_r	 <=	matrix_p22;
						post_img_green_r <=	(matrix_p12 + matrix_p21 + matrix_p23 + matrix_p32)>>2;
						post_img_blue_r	 <=	(matrix_p11 + matrix_p13 + matrix_p31 + matrix_p33)>>2;
                    end
                2'b11: //even lines + even point
                    begin	
						post_img_red_r	 <=	(matrix_p21 + matrix_p23)>>1;
						post_img_green_r <=	(matrix_p11 + matrix_p13 + matrix_p31 + matrix_p33)>>2;
						post_img_blue_r	 <=	(matrix_p12 + matrix_p32)>>1;
                    end
                endcase
            end
            else
            begin
				post_img_red_r	 <=	0;
				post_img_green_r <=	0;
				post_img_blue_r	 <=	0;
            end
        end
    end
    else if(BAYER_PATTERN == 2'b10)//GBRG
    begin
        always@(posedge clk or negedge rst_n)
        begin
            if(!rst_n)
            begin
				post_img_red_r	 <=	0;
				post_img_green_r <=	0;
				post_img_blue_r	 <=	0;
            end
            else if(matrix_frame_vsync && matrix_frame_vsync)
            begin
                case({line_cnt[0], point_cnt[0]})
                2'b00:	//odd lines + odd point
                    begin	
						post_img_red_r	 <=	(matrix_p21 + matrix_p23)>>1;
						post_img_green_r <=	(matrix_p11 + matrix_p13 + matrix_p31 + matrix_p33)>>2;
						post_img_blue_r	 <=	(matrix_p12 + matrix_p32)>>1;	
                    end
                2'b01:	//odd lines + even point
                    begin	
						post_img_red_r	 <=	matrix_p22;
						post_img_green_r <=	(matrix_p12 + matrix_p21 + matrix_p23 + matrix_p32)>>2;
						post_img_blue_r	 <=	(matrix_p11 + matrix_p13 + matrix_p31 + matrix_p33)>>2;
                    end
                2'b10:	//even lines + odd point
                    begin	
						post_img_red_r	 <=	(matrix_p11 + matrix_p13 + matrix_p31 + matrix_p33)>>2;
						post_img_green_r <=	(matrix_p12 + matrix_p21 + matrix_p23 + matrix_p32)>>2;
						post_img_blue_r	 <=	matrix_p22;	
                    end
                2'b11: //even lines + even point
                    begin	
						post_img_red_r	 <=	(matrix_p12 + matrix_p32)>>1;
						post_img_green_r <=	(matrix_p11 + matrix_p13 + matrix_p31 + matrix_p33)>>2;
						post_img_blue_r	 <=	(matrix_p21 + matrix_p23)>>1;
                    end
                endcase
            end
            else
            begin
				post_img_red_r	 <=	0;
				post_img_green_r <=	0;
				post_img_blue_r	 <=	0;
            end
        end
    end
    else//BGGR
    if(BAYER_PATTERN == 2'b00) //RGGB
    begin
        always@(posedge clk or negedge rst_n)
        begin
            if(!rst_n)
            begin
				post_img_red_r	 <=	0;
				post_img_green_r <=	0;
				post_img_blue_r	 <=	0;
            end
            else if(matrix_frame_vsync && matrix_frame_vsync)
            begin
                case({line_cnt[0], point_cnt[0]})
                2'b00:	//odd lines + odd point
                    begin	//Center Blue
						post_img_red_r	 <=	matrix_p22;
						post_img_green_r <=	(matrix_p12 + matrix_p21 + matrix_p23 + matrix_p32)>>2;
						post_img_blue_r	 <=	(matrix_p11 + matrix_p13 + matrix_p31 + matrix_p33)>>2;			
                    end
                2'b01:	//odd lines + even point
                    begin	//Center Green
						post_img_red_r	 <=	(matrix_p21 + matrix_p23)>>1;
						post_img_green_r <=	matrix_p22;
						post_img_blue_r	 <=	(matrix_p12 + matrix_p32)>>1;
                    end
                2'b10:	//even lines + odd point
                    begin	//Center Green
						post_img_red_r	 <=	(matrix_p12 + matrix_p32)>>1;
						post_img_green_r <=	matrix_p22;
						post_img_blue_r	 <=	(matrix_p21 + matrix_p23)>>1;					
                    end
                2'b11: //even lines + even point
                    begin	//Center Red
						post_img_red_r	 <=	(matrix_p11 + matrix_p13 + matrix_p31 + matrix_p33)>>2;
						post_img_green_r <=	(matrix_p12 + matrix_p21 + matrix_p23 + matrix_p32)>>2;
						post_img_blue_r	 <=	 matrix_p22;
                    end
                endcase
            end
            else
            begin
				post_img_red_r	 <=	0;
				post_img_green_r <=	0;
				post_img_blue_r	 <=	0;
            end
        end
    end
endgenerate


assign	post_img_red	=	post_img_red_r;
assign	post_img_green	=	post_img_green_r;
assign	post_img_blue	=	post_img_blue_r;

//------------------------------------------
//lag n clocks signal sync  	
reg	[1:0]	post_frame_vsync_r;
reg	[1:0]	post_frame_href_r;
reg	[1:0]	post_frame_clken_r;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		begin
		post_frame_vsync_r 	<= 	0;
		post_frame_href_r 	<= 	0;
		end
	else
		begin
		post_frame_vsync_r 	<= 	{post_frame_vsync_r[0], matrix_frame_vsync};
		post_frame_href_r 	<= 	{post_frame_href_r[0], 	matrix_frame_href};
		post_frame_clken_r  <=  {post_frame_clken_r[0],matrix_frame_clken};
		end
end
assign	post_frame_vsync 	= 	post_frame_vsync_r[0];
assign	post_frame_href 	= 	post_frame_href_r[0];

endmodule