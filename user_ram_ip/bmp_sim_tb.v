`timescale 1ns / 1ns
 
module bmp_tb;

//图片的分辨率,参数不指定位宽情况下默认32位
//不同的图片根据其格式修改此处
parameter  IMG_HDISP 		= 400;
parameter  IMG_VDISP 		= 400;
parameter  FILE_PATH		= "./PIC/test_1.bmp";
parameter  OUTPUT_BMP		= "./PIC/test_1_out.bmp";

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
       cmos_index   <=  0;
       cmos_data    <=  24'd0;
   end
   else begin          
       cmos_index   <=  y_pos * 3 *IMG_HDISP  + x_pos*3 + BMP_HEAD;        //  3*(y*IMG_HDISP + x) + 54
       cmos_data    <=  {rBmpData[cmos_index], rBmpData[cmos_index+1] , rBmpData[cmos_index+2]};
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
wire [7:0]	post0_img_Cb     	;   
wire [7:0]	post0_img_Cr     	;  


VIP_RGB888_YCbCr444	u_VIP_RGB888_YCbCr444
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
	.post_img_Y			(post0_image_data ),			//Processed Image brightness output
	.post_img_Cb		(post0_img_Cb),			//Processed Image blue shading output
	.post_img_Cr		(post0_img_Cr)			//Processed Image red shading output
);

//--------------------------------------
//VIP 算法——中值滤波模块
wire 		post1_image_vsync  	;
wire 		post1_data_valid   	;
wire 		post1_image_clken  	;
wire [7:0]	post1_image_data   	;

gray_median_filter #(
	.IMG_HDISP	(IMG_HDISP),	 
	.IMG_VDISP	(IMG_VDISP)
) u_gray_median_filter(
    .clk            (clk),  
    .rst_n          (rst_n),

//预处理图像
    .pre_gray_vsync (post0_image_vsync),
    .pre_gray_valid (post0_data_valid ),
    .pre_gray_clken (post0_image_clken),
    .pre_gray_data  (post0_image_data ),

//处理后图像
    .post_gray_vsync (post1_image_vsync),
    .post_gray_valid (post1_data_valid ),
    .post_gray_clken (post1_image_clken),
    .post_pixel_data (post1_image_data )
);


//--------------------------------------
//VIP 算法——Sobel边缘检测

wire			post2_frame_vsync;	 
wire			post2_frame_href;	 
wire			post2_frame_clken;	 
wire			post2_img_Bit;		 

VIP_Sobel_Edge_Detector #(
	.IMG_HDISP	(IMG_HDISP),	 
	.IMG_VDISP	(IMG_VDISP)
) u_VIP_Sobel_Edge_Detector (
	.clk					(clk),  				
	.rst_n					(rst_n),				

	//Image data prepred to be processd
	.pre_frame_vsync		(post0_image_vsync),	
	.pre_frame_href			(post0_data_valid ),		
	.pre_frame_clken		(post0_image_clken),	
	.pre_img_Y				(post0_image_data ),			

	//Image data has been processd
	.post_frame_vsync		(post2_frame_vsync),	
	.post_frame_href		(post2_frame_href ),		
	.post_frame_clken		(post2_frame_clken),	
	.post_img_Bit			(post2_img_Bit    ),		
	
	//User interface
	.Sobel_Threshold		(8'd128)					
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
//输出median
// assign vip_out_frame_vsync = post1_image_vsync;   
// assign vip_out_frame_href  = post1_data_valid ;   
// assign vip_out_frame_clken = post1_image_clken;    
// assign vip_out_img_R       = post1_image_data;   
// assign vip_out_img_G       = post1_image_data;   
// assign vip_out_img_B       = post1_image_data;  

//输出sobel
assign vip_out_frame_vsync = post2_frame_vsync;   
assign vip_out_frame_href  = post2_frame_href ;   
assign vip_out_frame_clken = post2_frame_clken;    
assign vip_out_img_R       = {8{post2_img_Bit}};   
assign vip_out_img_G       = {8{post2_img_Bit}};   
assign vip_out_img_B       = {8{post2_img_Bit}};  



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
end

always@(posedge clk or negedge rst_n)begin
   if(!rst_n) begin
        vip_cnt <=  32'd0;
   end
   else if(vip_out_en) begin
        if(vip_out_frame_href & vip_out_frame_clken) begin
            vip_cnt <=  vip_cnt + 3;
            vip_pixel_data[vip_cnt+0] <= vip_out_img_R;
            vip_pixel_data[vip_cnt+1] <= vip_out_img_G;
            vip_pixel_data[vip_cnt+2] <= vip_out_img_B;
        end
   end
end
 
endmodule 
