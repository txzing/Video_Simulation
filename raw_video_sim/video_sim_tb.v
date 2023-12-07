`timescale 1ns / 1ns
 
module video_sim_tb;

`define TPG_MODE


//图片的分辨率,参数不指定位宽情况下默认32位
//不同的图片根据其格式修改此处
parameter  IMG_HDISP 		= 400;
parameter  IMG_VDISP 		= 400;
parameter  FILE_PATH		= "./PIC/test_1.bmp";
`ifdef TPG_MODE
	parameter  OUTPUT_BMP		= "./PIC/raw2rgb_out_tpg_ab.bmp";
`else
	parameter  OUTPUT_BMP		= "./PIC/raw2rgb_out.bmp";
`endif

// `define  WRITE_TXT

`ifdef WRITE_TXT
parameter  OUTPUT_TXT		= "./PIC/test_1_out.txt";
`endif
//
parameter  BMP_HEAD  		= 54;
parameter  BMP_DATA  		= IMG_HDISP*IMG_VDISP*3;//24位深图片
parameter  PIC_TOTAL_SIZE   = BMP_HEAD + BMP_DATA;
parameter  CYCLE_TIME       = 20;
 
integer iBmpFileId;                 //输入BMP图片
integer oBmpFileId;                 //输出BMP图片
integer oTxtFileId;                 //输入TXT文本
        
integer iIndex = 0;                 //输出BMP数据索引
integer pixel_index = 0;            //输出像素数据索引 
        
integer iCode;      
        
integer iBmpWidth;                  //输入BMP 宽度
integer iBmpHight;                  //输入BMP 高度
integer iBmpSize;                   //输入BMP 字节数
integer iDataStartIndex;            //输入BMP 像素数据偏移量
    
reg [ 7:0] rBmpData [0:PIC_TOTAL_SIZE-1];    //用于寄存输入BMP图片中的字节数据（包括54字节的文件头）
reg [ 7:0] Vip_BmpData [0:PIC_TOTAL_SIZE-1]; //用于寄存视频图像处理之后 的BMP图片 数据 
reg [ 7:0] vip_pixel_data [0:BMP_DATA-1];   //320x240x3
reg [31:0] rBmpWord;                //输出BMP图片时用于寄存数据（以word为单位，即4byte）


reg 	clk;
reg 	rst_n;
reg     vip_out_en;     //寄存VIP处理图像的使能信号，仅维持一帧的时间
//产生50MHz时钟
always #(CYCLE_TIME/2) clk = ~clk;
 

initial begin
	clk     = 1'b1;
    rst_n   = 1'b0;

    //分别打开 输入/输出BMP图片，以及输出的Txt文本
	// iBmpFileId = $fopen("C:\\Users\\tangx\\Desktop\\bmp_sim_test\\PIC\\nut_320x240.bmp","rb");
	// oBmpFileId = $fopen("C:\\Users\\tangx\\Desktop\\bmp_sim_test\\PIC\\output_file.bmp","wb+");
	// oTxtFileId = $fopen("C:\\Users\\tangx\\Desktop\\bmp_sim_test\\PIC\\output_file.txt","w+");

    //分别打开 输入/输出BMP图片，以及输出的Txt文本，绝对路径
	// iBmpFileId = $fopen("C:\\Users\\tangx\\Desktop\\bmp_sim_test\\PIC\\fengjing_320x240.bmp","rb");
	// oBmpFileId = $fopen("C:\\Users\\tangx\\Desktop\\bmp_sim_test\\PIC\\fengjing_320x240_out.bmp","wb+");
	// oTxtFileId = $fopen("C:\\Users\\tangx\\Desktop\\bmp_sim_test\\PIC\\fengjing_320x240.txt","w+");


    // 分别打开 输入/输出BMP图片，以及输出的Txt文本，相对路劲
	iBmpFileId = $fopen(FILE_PATH,"rb");
	oBmpFileId = $fopen(OUTPUT_BMP,"wb+");

`ifdef WRITE_TXT
	oTxtFileId = $fopen(OUTPUT_TXT,"w+");
	//将数组中的数据写到输出Txt文本中
	$fwrite(oTxtFileId,"%p",rBmpData);
    //关闭Txt文本
    $fclose(oTxtFileId);
`endif

	$display("PIC_TOTAL_SIZE is %d\n",PIC_TOTAL_SIZE);

    //将输入BMP图片加载到数组中
	iCode = $fread(rBmpData,iBmpFileId);
 
    //根据BMP图片文件头的格式，分别计算出图片的 宽度 /高度 /像素数据偏移量 /图片字节数
	iBmpWidth       = {rBmpData[21],rBmpData[20],rBmpData[19],rBmpData[18]};
	iBmpHight       = {rBmpData[25],rBmpData[24],rBmpData[23],rBmpData[22]};
	iBmpSize        = {rBmpData[ 5],rBmpData[ 4],rBmpData[ 3],rBmpData[ 2]};
	iDataStartIndex = {rBmpData[13],rBmpData[12],rBmpData[11],rBmpData[10]};

    //关闭输入BMP图片
	$fclose(iBmpFileId);
    
    #(5*CYCLE_TIME);
    rst_n   = 1'b1;
	$display("start \n");     
    
    //等待第一帧VIP处理结束
	@(negedge vip_out_en);
	@(negedge vip_out_en);
	@(negedge vip_out_en);

	#(5*CYCLE_TIME);
    //加载图像处理后，BMP图片的文件头和像素数据
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 1) begin
		if(iIndex < BMP_HEAD)
            Vip_BmpData[iIndex] = rBmpData[iIndex];
        else
            Vip_BmpData[iIndex] = vip_pixel_data[iIndex-BMP_HEAD];
	end
    
    //将数组中的数据写到输出BMP图片中    
	for (iIndex = 0; iIndex < iBmpSize; iIndex = iIndex + 4) begin
		rBmpWord = {Vip_BmpData[iIndex+3],Vip_BmpData[iIndex+2],Vip_BmpData[iIndex+1],Vip_BmpData[iIndex]};
		// $display("rBmpWord = %u\n",rBmpWord);
		$fwrite(oBmpFileId,"%u",rBmpWord);
	end

    //关闭输出BMP图片
	$fclose(oBmpFileId);
	$display("end \n"); 
	$stop;  

end


// reg [ 7:0] pixel_data;              //输出视频流时的像素数据
//可在时钟驱动下，从数组中读出像素数据
// always@(posedge clk or negedge rst_n)begin
//     if(!rst_n) begin
//         pixel_data  <=  8'd0;
//         pixel_index <=  0;
//     end
//     else begin
//         pixel_data  <=  rBmpData[pixel_index];
//         pixel_index <=  pixel_index+1;
//     end
// end


/*


*/

wire		cmos_vsync ;
reg			cmos_href;
wire        cmos_clken;
reg	[23:0]	cmos_data;			 

reg [31:0]  cmos_index;

localparam H_SYNC = 14'd5;		
localparam H_BACK = 14'd5;		
localparam H_DISP = IMG_HDISP;	
localparam H_FRONT = 14'd5;		
localparam H_TOTAL = H_SYNC + H_BACK + H_DISP + H_FRONT;	

localparam V_SYNC = 14'd1;		
localparam V_BACK = 14'd0;		
localparam V_DISP = IMG_VDISP;	
localparam V_FRONT = 14'd1;		
localparam V_TOTAL = V_SYNC + V_BACK + V_DISP + V_FRONT;

//---------------------------------------------
//水平计数器
reg	[13:0]	hcnt;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		hcnt <= 14'd0;
	else
		hcnt <= (hcnt < H_TOTAL - 1'b1) ? hcnt + 1'b1 : 14'd0;
end

//---------------------------------------------
//竖直计数器
reg	[13:0]	vcnt;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		vcnt <= 14'd0;		
	else begin
		if(hcnt == H_TOTAL - 1'b1)
			vcnt <= (vcnt < V_TOTAL - 1'b1) ? vcnt + 1'b1 : 14'd0;
		else
			vcnt <= vcnt;
    end
end

//---------------------------------------------
//场同步
reg	cmos_vsync_r;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_vsync_r <= 1'b0;		//H: Vaild, L: inVaild
	else begin
		if(vcnt <= V_SYNC - 1'b1)
			cmos_vsync_r <= 1'b0; 	//H: Vaild, L: inVaild
		else
			cmos_vsync_r <= 1'b1; 	//H: Vaild, L: inVaild
    end
end
assign	cmos_vsync	= cmos_vsync_r;

//---------------------------------------------
//Image data href vaild  signal
wire	frame_valid_ahead =  ( vcnt >= V_SYNC + V_BACK  && vcnt < V_SYNC + V_BACK + V_DISP
                            && hcnt >= H_SYNC + H_BACK  && hcnt < H_SYNC + H_BACK + H_DISP ) 
						? 1'b1 : 1'b0;
      
reg			cmos_href_r;      
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_href_r <= 0;
	else begin
		if(frame_valid_ahead)
			cmos_href_r <= 1;
		else
			cmos_href_r <= 0;
    end
end

always@(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cmos_href <= 0;
	else
        cmos_href <= cmos_href_r;
end

assign cmos_clken = cmos_href;//一个clock,一个data

//-------------------------------------
//从数组中以视频格式输出像素数据
wire [13:0] x_pos;
wire [13:0] y_pos;

assign x_pos = frame_valid_ahead ? (hcnt - (H_SYNC + H_BACK )) : 0;
assign y_pos = frame_valid_ahead ? (vcnt - (V_SYNC + V_BACK )) : 0;


always@(posedge clk or negedge rst_n)begin
   if(!rst_n) begin
       cmos_index   <=  BMP_HEAD;
       cmos_data    <=  24'd0;
   end
   else begin          
       cmos_index   <=  y_pos * 3 *IMG_HDISP  + x_pos*3 + BMP_HEAD;        //  3*(y*IMG_HDISP + x) + 54
       cmos_data    <=  {rBmpData[cmos_index+2],rBmpData[cmos_index+1],rBmpData[cmos_index]};//RGB
   end
end
 
//-------------------------------------
//VIP算法——彩色转灰度

wire 		pre_frame_vsync	=	cmos_vsync ;	
wire 		pre_frame_href	=	cmos_href;	
wire 		pre_frame_clken	=	cmos_clken;	
wire [7:0]	pre_img_red		=	cmos_data[23:16];	   	
wire [7:0]	pre_img_green	=	cmos_data[15: 8];   	            
wire [7:0]	pre_img_blue	=	cmos_data[ 7: 0];   	            


wire 		post0_image_vsync	;   
wire 		post0_data_valid 	;   
wire 		post0_image_clken	;    
wire [7:0]	post0_image_data    ;   


`ifdef TPG_MODE
wire v_hs;
wire v_vs;
wire v_de;
wire [7:0] vga_r;
wire [7:0] vga_g;
wire [7:0] vga_b;
color_data_gen 
#(
//--------------------------------//
	.H_Active	(IMG_HDISP),
	.H_Sync		('d2	),
	.H_Back		('d2	),
	.H_Front	('d2	),
//-------------------------------//
	.V_Active	(IMG_VDISP),
	.V_Sync		('d2    ),
	.V_Back		('d2   ),
	.V_Front	('d2    )
)
u_color_data_gen
(
/*input				*/.pix_clk	(clk)	,
/*input				*/.rst_n	(rst_n)	,
/*input  [3:0]    	*/.dis_mode	(4'd12)       , //7,12
/*output [7:0]		*/.VGA_R	(vga_r)		,
/*output [7:0]		*/.VGA_G	(vga_g)		,
/*output [7:0]		*/.VGA_B	(vga_b)		,
/*output			*/.VGA_HS	(v_hs)		,
/*output			*/.VGA_VS	(v_vs)		,
/*output			*/.VGA_DE	(v_de)

);
`endif

`ifdef TPG_MODE
	rgb2raw	
	#(
		.BAYER_PATTERN(2'b00)
	)
	u_rgb2raw
	(
		//global clock
		.clk				(clk),					//cmos video pixel clock
		.rst_n				(rst_n),				//system reset

		//Image data prepred to be processd
		.pre_frame_vsync	(v_vs),		//Prepared Image data vsync valid signal
		.pre_frame_href		(v_de),		//Prepared Image data href vaild  signal
		.pre_frame_clken	(v_de),		//Prepared Image data output/capture enable clock
		.pre_img_red		(vga_r),			//Prepared Image red data input
		.pre_img_green		(vga_g),		//Prepared Image green data input
		.pre_img_blue		(vga_b),			//Prepared Image blue data input
		
		//Image data has been processd
		.post_frame_vsync	(post0_image_vsync),		//Processed Image frame data valid signal
		.post_frame_href	(post0_data_valid ),		//Processed Image hsync data valid signal
		.post_frame_clken	(post0_image_clken),		//Processed Image data output/capture enable clock
		.post_data_raw		(post0_image_data )			//Processed Image brightness output
	);
`else
	rgb2raw	
	#(
		.BAYER_PATTERN(2'b00)
	)
	u_rgb2raw
	(
		//global clock
		.clk				(clk),					//cmos video pixel clock
		.rst_n				(rst_n),				//system reset

		//Image data prepred to be processd
		.pre_frame_vsync	(pre_frame_vsync),		//Prepared Image data vsync valid signal
		.pre_frame_href		(pre_frame_href),		//Prepared Image data href vaild  signal
		.pre_frame_clken	(pre_frame_clken),		//Prepared Image data output/capture enable clock
		.pre_img_red		(pre_img_red),			//Prepared Image red data input
		.pre_img_green		(pre_img_green),		//Prepared Image green data input
		.pre_img_blue		(pre_img_blue),			//Prepared Image blue data input
		
		//Image data has been processd
		.post_frame_vsync	(post0_image_vsync),		//Processed Image frame data valid signal
		.post_frame_href	(post0_data_valid ),		//Processed Image hsync data valid signal
		.post_frame_clken	(post0_image_clken),		//Processed Image data output/capture enable clock
		.post_data_raw		(post0_image_data )			//Processed Image brightness output
	);

`endif


//--------------------------------------
//VIP 算法
wire 		post1_image_vsync  	;
wire 		post1_data_valid   	;
wire 		post1_image_clken  	;
wire [7:0]	post1_image_data_r  ;
wire [7:0]	post1_image_data_g  ;
wire [7:0]	post1_image_data_b  ;

Video_Image_Processor
#(
	.IMG_HDISP (IMG_HDISP),	
	.IMG_VDISP (IMG_VDISP),
	.DATA_W    (8)
)
u_Video_Image_Processor
(
/*input		*/.clk             (clk),  				//cmos video pixel clock
/*input		*/.rst_n           (rst_n),				//global reset
//Image data prepred to be processd
/*input		*/.pre_frame_vsync (post0_image_vsync),	//Prepared Image data vsync valid signal
/*input		*/.pre_frame_href  (post0_data_valid),  //Prepared Image data href vaild  signal
/*input		*/.pre_img_data    (post0_image_data),		
//Image data has been processd
/*output	*/.post_frame_vsync(post1_image_vsync),	//Processed Image data vsync valid signal
/*output	*/.post_frame_href (post1_data_valid),	//Processed Image data href vaild  signal
/*output	*/.post_img_red    (post1_image_data_r),//Processed Image Red output
/*output	*/.post_img_green  (post1_image_data_g),//Processed Image Green output
/*output	*/.post_img_blue   (post1_image_data_b)	//Processed Image Blue output
);



//-------------------------------------
//寄存图像处理之后的像素数据

wire 		vip_out_frame_vsync;   
wire 		vip_out_frame_href ;   
wire 		vip_out_frame_clken;    
wire [7:0]	vip_out_img_R     ;   
wire [7:0]	vip_out_img_G     ;   
wire [7:0]	vip_out_img_B     ;  

/*****
修改此处决定输出经过哪种处理的图片
*****/
//输出

// assign vip_out_frame_vsync = v_vs;   
// assign vip_out_frame_href  = v_de ;   
// assign vip_out_frame_clken = v_de;    
// assign vip_out_img_R       = vga_r;   
// assign vip_out_img_G       = vga_g;   
// assign vip_out_img_B       = vga_b;


assign vip_out_frame_vsync = post1_image_vsync;   
assign vip_out_frame_href  = post1_data_valid ;   
assign vip_out_frame_clken = post1_data_valid;    
assign vip_out_img_R       = post1_image_data_r;   
assign vip_out_img_G       = post1_image_data_g;   
assign vip_out_img_B       = post1_image_data_b;  
 



reg [31:0] vip_cnt;
 
reg         vip_vsync_r;    //寄存VIP输出的场同步 
wire        vsync_n_edge;

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) 
        vip_vsync_r <=  1'b0;
   else 
        vip_vsync_r <=  vip_out_frame_vsync;
end

assign      vsync_n_edge = vip_vsync_r & (!vip_out_frame_vsync);//检测下降沿，即一帧结束

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) 
        vip_out_en <=  1'b1;
   else if(vsync_n_edge)  //第一帧结束之后，使能拉低
        vip_out_en <=  1'b0;
	else
		vip_out_en <=  1'b1;
end

//tpg  G B R
//ppm  R G B
//bmp  B G R


wire [7:0]	vip_out_data        ;  
reg [ 7:0] vip_pixel_data_ppm [0:(IMG_HDISP*IMG_VDISP)-1];  

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) begin
        vip_cnt <=  32'd0;
   end
   else if(vsync_n_edge) 
   begin
		vip_cnt <=  32'd0;
   end
   else if(vip_out_en) begin
        if(vip_out_frame_href & vip_out_frame_clken) begin
            vip_cnt <=  vip_cnt + 3;
            vip_pixel_data[vip_cnt+0] <= vip_out_img_B;
            vip_pixel_data[vip_cnt+1] <= vip_out_img_G;
            vip_pixel_data[vip_cnt+2] <= vip_out_img_R;
        end
   end
/*
    else if(vip_out_en) begin
        if(vip_out_frame_href & vip_out_frame_clken) begin
            vip_cnt <=  vip_cnt + 1;
            vip_pixel_data_ppm[vip_cnt+0] <= vip_out_data;
        end
   end
*/
end


/*
//ppm
//用于生成bayer的灰度图

assign vip_out_frame_vsync = post0_image_vsync;   
assign vip_out_frame_href  = post0_data_valid ;   
assign vip_out_frame_clken = post0_data_valid;    
assign vip_out_data       = post0_image_data;   

integer output_file;
initial begin
	clk     = 1'b1;
    rst_n   = 1'b0;

    #(5*CYCLE_TIME);
    rst_n   = 1'b1;
	$display("start \n");     
    
    //等待第一帧VIP处理结束
	@(negedge vip_out_en);
	#(5*CYCLE_TIME);

    output_file = $fopen("./PIC/bayer.ppm","w");
    $fwrite(output_file,"P2\n");//灰度图
    $fwrite(output_file,"%0d %0d\n",IMG_HDISP, IMG_VDISP);
    $fwrite(output_file,"%0d\n",2**8-1); // 8bit 255
	for (iIndex = 0; iIndex < (IMG_HDISP*IMG_VDISP); iIndex = iIndex + 1) 
	begin
		$fwrite(output_file,"%0d\n",(vip_pixel_data_ppm[iIndex]));
	end
    $fclose(output_file);
    $display("Image written");

	$stop;
end
*/

endmodule 
