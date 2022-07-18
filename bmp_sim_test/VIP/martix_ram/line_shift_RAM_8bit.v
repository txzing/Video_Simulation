/**************************************功能介绍***********************************
Copyright:			
Date     :			
Author   :			
Version  :			
Description:可通过调用ram IP核实现两行数据寄存,使能寄存一拍输出( RAM 中的数据会寄存一个周期后输出)	
两个双端口RAM
注意：根据图像分辨率的不同需修改ram的相应深度
可通过修改底层原语，也可使用分布式ram(即纯逻辑编写ram接口)
*********************************************************************************/
module line_shift_RAM_8bit
#(
	parameter	IMG_HDISP = 640,	//640*480
	parameter	IMG_VDISP = 480
)
(
    input          clock,
    input          clken,
    input          pre_frame_href,
    
    input   [7:0]  shiftin,  
    output  [7:0]  taps0x,   
    output  [7:0]  taps1x    
);

//根据传入的分辨率确定ram的深度和宽度（相对节省资源），此处宽度不用修改
//比如，IMG_HDISP=640，则ADDR_W=9, 已减一
//参数声明
    localparam  ADDR_W = log2b(IMG_HDISP);
    localparam  DATA_W = 7;

//function声明
/************* 用取对数的方法计算地址指针的位宽 ************************/

    function integer log2b(input integer data);
        begin 
            for(log2b=0;data>0;log2b=log2b+1)  
                data = data>>1;
            log2b = log2b - 1;
        end  
    endfunction

//reg define
reg  [2:0]  clken_dly;
reg  [ADDR_W :0]  ram_rd_addr;
reg  [ADDR_W :0]  ram_rd_addr_d0;
reg  [ADDR_W :0]  ram_rd_addr_d1;
reg  [DATA_W :0]  shiftin_d0;
reg  [DATA_W :0]  shiftin_d1;
reg  [DATA_W :0]  shiftin_d2;
reg  [DATA_W :0]  taps0x_d0;



//*****************************************************
//**                    main code
//*****************************************************

//在数据来到时，ram地址累加
always@(posedge clock)begin
    if(pre_frame_href)
        if(clken)
            ram_rd_addr <= ram_rd_addr + 1 ;
        else
            ram_rd_addr <= ram_rd_addr ;
    else
        ram_rd_addr <= 0 ;
end

//时钟使能信号延迟三拍
always@(posedge clock) begin
    clken_dly <= { clken_dly[1:0] , clken };
end


//将ram地址延迟二拍
always@(posedge clock ) begin
    ram_rd_addr_d0 <= ram_rd_addr;
    ram_rd_addr_d1 <= ram_rd_addr_d0;
end

//输入数据延迟三拍
always@(posedge clock)begin
    shiftin_d0 <= shiftin;
    shiftin_d1 <= shiftin_d0;
    shiftin_d2 <= shiftin_d1;
end

//用于存储前一行图像的RAM
blk_mem_gen_0  
 #(
	.ADDR_W	(ADDR_W),
	.DATA_W	(DATA_W)
)
u_ram_1024x8_0(
    .data      (shiftin_d2),     //在延迟的第三个时钟周期，当前行的数据写入RAM0
    .clock     (clock),
    .rdaddress (ram_rd_addr),
    .wraddress (ram_rd_addr_d1),
    .wren      (clken_dly[2]),
    .q         (taps0x)          //延迟一个时钟周期，输出RAM0中前一行图像的数据
);  

//用于存储前前一行图像的RAM
blk_mem_gen_0  
 #(
	.ADDR_W	(ADDR_W),	 
	.DATA_W	(DATA_W)
)
u_ram_1024x8_1(
    .data      (taps0x),     //在延迟的第二个时钟周期，将前一行图像的数据写入RAM1
    .clock     (clock     ),
    .wraddress (ram_rd_addr_d0),
    .wren      (clken_dly[1]),    
    
    .rdaddress (ram_rd_addr),
    .q         (taps1x)           //延迟一个时钟周期，输出RAM1中前前一行图像的数据
);

endmodule 