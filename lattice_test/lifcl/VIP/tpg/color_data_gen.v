`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/*
//1920x1080 @ 60fps @ 148.5MHz
    .h_active      ('d1920 ),
	.h_total       ('d2200 ),
	.v_active      ('d1080 ),
	.v_total       ('d1125 ),
	.H_FRONT_PORCH ('d88   ),
	.H_SYNCH       ('d44   ),
	.H_BACK_PORCH  ('d148  ),
	.V_FRONT_PORCH ('d4    ),
	.V_SYNCH       ('d5    ),
    .V_BACK_PORCH  ('d36   )


//1280 x 720 @ 60Hz @ 74.25MHz
    .h_active      ('d1280 ),
	.h_total       ('d1650 ),
	.v_active      ('d720  ),
	.v_total       ('d750  ),
	.H_FRONT_PORCH ('d110  ),
	.H_SYNCH       ('d40   ),
	.H_BACK_PORCH  ('d220  ),
	.V_FRONT_PORCH ('d5    ),
	.V_SYNCH       ('d5    ),
    .V_BACK_PORCH  ('d20   )
    
    
//1024 x 768 @ 60Hz @ 65MHz
    .h_active      ('d1024 ),
	.h_total       ('d1344 ),
	.v_active      ('d768  ),
	.v_total       ('d806  ),
	.H_FRONT_PORCH ('d24   ),
	.H_SYNCH       ('d136  ),
	.H_BACK_PORCH  ('d160  ),
	.V_FRONT_PORCH ('d3    ),
	.V_SYNCH       ('d6    ),
    .V_BACK_PORCH  ('d29   )
    
    
//800 x 600 @ 60Hz @ 40MHz
    .h_active      ('d800  ),
	.h_total       ('d1056 ),
	.v_active      ('d600  ),
	.v_total       ('d628  ),
	.H_FRONT_PORCH ('d40   ),
	.H_SYNCH       ('d128  ),
	.H_BACK_PORCH  ('d88   ),
	.V_FRONT_PORCH ('d1    ),
	.V_SYNCH       ('d4    ),
    .V_BACK_PORCH  ('d23   )


//640x480 @ 60fps @25.175MHz
    .h_active      ('d640  ),
	.h_total       ('d800  ),
	.v_active      ('d480  ),
	.v_total       ('d525  ),
	.H_FRONT_PORCH ('d16   ),
	.H_SYNCH       ('d96   ),
	.H_BACK_PORCH  ('d48   ),
	.V_FRONT_PORCH ('d10   ),
	.V_SYNCH       ('d2    ),
    .V_BACK_PORCH  ('d33   )

*/
//////////////////////////////////////////////////////////////////////////////////

module color_data_gen
(
	input				pix_clk		,
	input				rst_n		,
	input  [3:0]    	dis_mode	,
	output [7:0]		VGA_R		,
	output [7:0]		VGA_G		,
	output [7:0]		VGA_B		,
	output	reg			VGA_HS		,
	output	reg			VGA_VS		,
	output	reg			VGA_DE

);

//---------------------------------//
// 水平扫描参数的设定1280*720  60HZ
/*
H_Sync + H_Back == H_Start
H_Start + H_Active == H_End
H_End + H_Front == H_Total
*/
//--------------------------------//
parameter H_Sync		=	40;
parameter H_Back		=	220;
parameter H_Active		=	1280;
parameter H_Front		=	110;

parameter H_Start		=	H_Sync + H_Back;
parameter H_End			=	H_Start + H_Active;
parameter H_Total		=	H_End + H_Front;
//-------------------------------//
// 垂直扫描参数的设定1280*720	60HZ  	
//-------------------------------//
parameter V_Sync		=	5;
parameter V_Back		=	20;
parameter V_Active		=	720;
parameter V_Front		=	5;

parameter V_Start		=	V_Sync + V_Back;
parameter V_End			=	V_Start + V_Active;
parameter V_Total		=	V_End + V_Front;


reg[13:0]	x_cnt;
always @(posedge pix_clk)		//水平计数
begin
	if(!rst_n)
		x_cnt	<=	1;
	else if(x_cnt==H_Total)
		x_cnt	<=	1;
	else
		x_cnt	<=	x_cnt	+	1;
end

reg	hsync_r;

always @(posedge pix_clk)
begin
	if(!rst_n)
		hsync_r	<=	1'b0;
	else if(x_cnt==1)
		hsync_r	<=	1'b1;
	else if(x_cnt==H_Sync)
		hsync_r	<=	1'b0;

end

reg	hs_de;
always @(posedge pix_clk)
begin
	if(!rst_n)
		hs_de	<=	1'b0;
	else if(x_cnt==H_Start)
		hs_de	<=	1'b1;
	else if(x_cnt==H_End)
		hs_de	<=	1'b0;
end

reg[13:0]	y_cnt;
always @(posedge pix_clk)
begin
	if(!rst_n)
		y_cnt	<=	1;
	else if(y_cnt==V_Total)
		y_cnt	<=	1;
	else if(x_cnt==H_Total)
		y_cnt	<=	y_cnt	+	1;
end

reg	vsync_r;
reg	vs_de;
always @(posedge pix_clk)
begin
	if(!rst_n)
		vsync_r	<=	1'b0;
	else if(y_cnt==1)
		vsync_r	<=	1'b1;
	else if(y_cnt==V_Sync)
		vsync_r	<=	1'b0;
end

always @(posedge pix_clk)
begin
	if(!rst_n)
		vs_de	<=	1'b0;
	else if(y_cnt==V_Start)
		vs_de	<=	1'b1;
	else if(y_cnt==V_End)
		vs_de	<=	1'b0;
end

reg[7:0]	grid_data_1;
reg[7:0]	grid_data_2;
always @(posedge pix_clk)			//格子图像
begin
	if((x_cnt[4]==1'b1)^(y_cnt[4]==1'b1))
		grid_data_1	<=	8'h00;
	else
		grid_data_1	<=	8'hff;
	
	if((x_cnt[6]==1'b1)^(y_cnt[6]==1'b1))
		grid_data_2	<=	8'h00;
	else
		grid_data_2	<=	8'hff;
end

reg[23:0]	color_bar;
always @(posedge pix_clk)
begin
	if(x_cnt==(H_Start+(H_Active/8)*0))
		color_bar	<=	24'hff0000;
	else if(x_cnt==(H_Start+(H_Active/8)*1))
		color_bar	<=	24'h00ff00;
	else if(x_cnt==(H_Start+(H_Active/8)*2))
		color_bar	<=	24'h0000ff;
	else if(x_cnt==(H_Start+(H_Active/8)*3))
		color_bar	<=	24'hff00ff;
	else if(x_cnt==(H_Start+(H_Active/8)*4))
		color_bar	<=	24'hffff00;
	else if(x_cnt==(H_Start+(H_Active/8)*5))
		color_bar	<=	24'h00ffff;
	else if(x_cnt==(H_Start+(H_Active/8)*6))
		color_bar	<=	24'hffffff;
	else if(x_cnt==(H_Start+(H_Active/8)*7))
		color_bar	<=	24'h000000;
	else
		color_bar	<=	color_bar;
end

reg[7:0]	VGA_R_reg;
reg[7:0]	VGA_G_reg;
reg[7:0]	VGA_B_reg;
always @(pix_clk)
begin  
	if(!rst_n) 
	begin 
		VGA_R_reg<=0; 
	   	VGA_G_reg<=0;
	   	VGA_B_reg<=0;		 
	end
   else
	case(dis_mode)
		4'd0:begin
			VGA_R_reg<=0;            //LCD显示黑色
			VGA_G_reg<=0;
			VGA_B_reg<=0;
		end
		4'd1:begin
			VGA_R_reg<=8'b11111111;                 //LCD显示全白
			VGA_G_reg<=8'b11111111;
			VGA_B_reg<=8'b11111111;
		end
		4'd2:begin
			VGA_R_reg<=8'b11111111;                //LCD显示全红
			VGA_G_reg<=0;
			VGA_B_reg<=0;  
		end			  
		4'd3:begin
			VGA_R_reg<=0;                          //LCD显示全绿
			VGA_G_reg<=8'b11111111;
			VGA_B_reg<=0; 
		end					  
		4'd4:begin     
			VGA_R_reg<=0;                         //LCD显示全蓝
			VGA_G_reg<=0;
			VGA_B_reg<=8'b11111111;
		end
		4'd5:begin     
			VGA_R_reg<=grid_data_1;               // LCD显示方格1
			VGA_G_reg<=grid_data_1;
			VGA_B_reg<=grid_data_1;
		end					  
		4'd6:begin     
			VGA_R_reg<=grid_data_2;               // LCD显示方格2
			VGA_G_reg<=grid_data_2;
			VGA_B_reg<=grid_data_2;
		end
		4'd7:begin     
			VGA_R_reg<=x_cnt[7:0];                //LCD显示水平渐变色
			VGA_G_reg<=x_cnt[7:0];
			VGA_B_reg<=x_cnt[7:0];
		end
		4'd8:begin     
			VGA_R_reg<=y_cnt[8:1];                 //LCD显示垂直渐变色
			VGA_G_reg<=y_cnt[8:1];
			VGA_B_reg<=y_cnt[8:1];
		end
		4'd9:begin     
			VGA_R_reg<=x_cnt[7:0];                 //LCD显示红水平渐变色
			VGA_G_reg<=0;
			VGA_B_reg<=0;
		end
		4'd10:begin     
			VGA_R_reg<=0;                          //LCD显示绿水平渐变色
			VGA_G_reg<=x_cnt[7:0];
			VGA_B_reg<=0;
		end
		4'd11:begin     
			VGA_R_reg<=0;                          //LCD显示蓝水平渐变色
			VGA_G_reg<=0;
			VGA_B_reg<=x_cnt[7:0];			
		end
		4'd12:begin     
			VGA_R_reg<=color_bar[23:16];            //LCD显示彩色条
			VGA_G_reg<=color_bar[15:8];
			VGA_B_reg<=color_bar[7:0];			
		end
		default:begin
			VGA_R_reg<=8'b11111111;                //LCD显示全白
			VGA_G_reg<=8'b11111111;
			VGA_B_reg<=8'b11111111;
		end					  
	endcase
end

always @(posedge pix_clk)
begin  
	if(!rst_n) 
	begin 
		VGA_HS <= 1'b0; 
	   	VGA_VS <= 1'b0;
	   	VGA_DE <= 1'b0;		 
	end
	else
	begin
		VGA_HS <= hsync_r; 
	   	VGA_VS <= vsync_r;
	   	VGA_DE <= hs_de	&	vs_de;
	end
end

assign VGA_R	=	(hs_de & vs_de)?VGA_R_reg:8'h0;
assign VGA_G	=	(hs_de & vs_de)?VGA_G_reg:8'h0;
assign VGA_B	=	(hs_de & vs_de)?VGA_B_reg:8'h0;


endmodule

