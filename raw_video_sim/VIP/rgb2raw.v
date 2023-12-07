`timescale 1ns/1ns
module rgb2raw
(
	//global clock
	input				clk,  				//cmos video pixel clock
	input				rst_n,				//global reset

	//Image data prepred to be processd
	input				pre_frame_vsync,	//Prepared Image data vsync valid signal
	input				pre_frame_href,		//Prepared Image data href vaild  signal
	input				pre_frame_clken,	//Prepared Image data output/capture enable clock	
	input		[7:0]	pre_img_red,		//Prepared Image red data to be processed
	input		[7:0]	pre_img_green,		//Prepared Image green data to be processed
	input		[7:0]	pre_img_blue,		//Prepared Image blue data to be processed
	
	//Image data has been processd
	output				post_frame_vsync,	//Processed Image data vsync valid signal
	output				post_frame_href,	//Processed Image data href vaild  signal
	output				post_frame_clken,	//Processed Image data output/capture enable clock	
	output		[7:0]	post_data_raw		//Processed Image brightness output
);
parameter [1:0] BAYER_PATTERN = 2'b00;

//-------------------------------------------------------------
//sync the frame vsync and href signal and generate frame begin & end signal
reg		frame_href;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		frame_href <= 0;
	else
		frame_href <= pre_frame_href;
end

wire	frame_href_end	=	(frame_href & ~pre_frame_href) ? 1'b1 : 1'b0;	//Line over signal

//----------------------------------------
//Count the frame lines
//---------------------------------------------
//竖直计数器
reg	[13:0]	vcnt;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		vcnt <= 0;
	else if(pre_frame_vsync == 1'b1)	//Frame valid
		begin
		if(frame_href_end)
			vcnt <= vcnt + 1'b1;
		else
			vcnt <= vcnt;
		end
	else
		vcnt <= 0;
end

//----------------------------------------
//Count the pixels
//---------------------------------------------
//水平计数器
reg	[13:0]	hcnt;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		hcnt <= 0;
	else if(pre_frame_href == 1'b1)	//Line valid
		hcnt <= hcnt + 1'b1;
	else
		hcnt <= 0;
end

reg [7:0] post_img_data_r	;
generate
    if(BAYER_PATTERN == 2'b00) //RGGB
    begin
        always@(posedge clk or negedge rst_n)
        begin
            if(!rst_n)
            begin
                post_img_data_r <= 0;
            end
            else if(pre_frame_href && pre_frame_vsync)
            begin
                case({vcnt[0], hcnt[0]})
                2'b00:	//odd lines + odd point
                    begin	
                        post_img_data_r	<=	pre_img_red;	
                    end
                2'b01:	//odd lines + even point
                    begin	
                        post_img_data_r	<=	pre_img_green;
                    end
                2'b10:	//even lines + odd point
                    begin	
                        post_img_data_r	<=	pre_img_green;
                    end
                2'b11: //even lines + even point
                    begin	
                        post_img_data_r	<=	pre_img_blue;
                    end
                endcase
            end
            else
            begin
                post_img_data_r <= 0;
            end
        end
    end
    else if(BAYER_PATTERN == 2'b01)//GRBG
    if(BAYER_PATTERN == 2'b00) //RGGB
    begin
        always@(posedge clk or negedge rst_n)
        begin
            if(!rst_n)
            begin
                post_img_data_r <= 0;
            end
            else if(pre_frame_href && pre_frame_vsync)
            begin
                case({vcnt[0], hcnt[0]})
                2'b00:	//odd lines + odd point
                    begin	
                        post_img_data_r	<=	pre_img_green;	
                    end
                2'b01:	//odd lines + even point
                    begin	
                        post_img_data_r	<=	pre_img_red;
                    end
                2'b10:	//even lines + odd point
                    begin	
                        post_img_data_r	<=	pre_img_blue;
                    end
                2'b11: //even lines + even point
                    begin	
                        post_img_data_r	<=	pre_img_green;
                    end
                endcase
            end
            else
            begin
                post_img_data_r <= 0;
            end
        end
    end
    else if(BAYER_PATTERN == 2'b10)//GBRG
    if(BAYER_PATTERN == 2'b00) //RGGB
    begin
        always@(posedge clk or negedge rst_n)
        begin
            if(!rst_n)
            begin
                post_img_data_r <= 0;
            end
            else if(pre_frame_href && pre_frame_vsync)
            begin
                case({vcnt[0], hcnt[0]})
                2'b00:	//odd lines + odd point
                    begin	
                        post_img_data_r	<=	pre_img_green;	
                    end
                2'b01:	//odd lines + even point
                    begin	
                        post_img_data_r	<=	pre_img_blue;
                    end
                2'b10:	//even lines + odd point
                    begin	
                        post_img_data_r	<=	pre_img_red;
                    end
                2'b11: //even lines + even point
                    begin	
                        post_img_data_r	<=	pre_img_green;
                    end
                endcase
            end
            else
            begin
                post_img_data_r <= 0;
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
                post_img_data_r <= 0;
            end
            else if(pre_frame_href && pre_frame_vsync)
            begin
                case({vcnt[0], hcnt[0]})
                2'b00:	//odd lines + odd point
                    begin	
                        post_img_data_r	<=	pre_img_blue;	
                    end
                2'b01:	//odd lines + even point
                    begin	
                        post_img_data_r	<=	pre_img_green;
                    end
                2'b10:	//even lines + odd point
                    begin	
                        post_img_data_r	<=	pre_img_green;
                    end
                2'b11: //even lines + even point
                    begin	
                        post_img_data_r	<=	pre_img_red;
                    end
                endcase
            end
            else
            begin
                post_img_data_r <= 0;
            end
        end
    end
endgenerate

//------------------------------------------
//lag 1 clocks signal sync  
reg	pre_frame_vsync_r;
reg	pre_frame_href_r;	
reg	pre_frame_clken_r;
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
		pre_frame_vsync_r 	<= 	pre_frame_vsync;
		pre_frame_href_r 	<= 	pre_frame_href ;
		pre_frame_clken_r 	<= 	pre_frame_clken;
		end
end

assign	post_frame_vsync 	= 	pre_frame_vsync_r;
assign	post_frame_href 	= 	pre_frame_href_r ;
assign	post_frame_clken 	= 	pre_frame_clken_r;
assign	post_data_raw 	= 	post_frame_href ? post_img_data_r : 8'd0;

endmodule
