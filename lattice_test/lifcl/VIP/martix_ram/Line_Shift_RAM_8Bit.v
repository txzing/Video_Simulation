/**************************************功能介绍***********************************
Copyright:			
Date     :			
Author   :			
Version  :			
Description:可通过调用ram IP核实现两行数据寄存,使能寄存一拍输出( RAM 中的数据会寄存一个周期后输出)	
两个双端口RAM
注意：根据图像分辨率的不同需修改ram的相应深度
可通过修改底层原语，也可使用分布式ram(即纯逻辑编写ram接口,但此方法占用的资源较多，LUT如果资源较少，不推荐)
延迟3个clock,生成3行1列数据

为了方便移植，不调用ip，通过verilog生成双端口ram
*********************************************************************************/
module Line_Shift_RAM_8Bit
#(
	parameter	[12:0]	IMG_HDISP = 13'd640,	//640*480
    parameter	[4:0]   DATA_W    = 5'd8
)
(
    input          clock,
    input          clken,
    input          pre_frame_href,
    
    input   [DATA_W -1:0]  shiftin,
    output  [DATA_W -1:0]  taps0x,   
    output  [DATA_W -1:0]  taps1x,
    output  [DATA_W -1:0]  taps2x    
);

//根据传入的分辨率确定ram的深度和宽度（相对节省资源），此处宽度不用修改
//比如，IMG_HDISP=640，则ADDR_W=9, 已减一
//参数声明
localparam  ADDR_W = log2b(IMG_HDISP);

//function声明
/************* 用取对数的方法计算地址指针的位宽 ************************/

function integer log2b(input integer data);
    begin 
        for(log2b=0;data>0;log2b=log2b+1)  
            data = data>>1;
        log2b = log2b;
    end  
endfunction

//reg define
reg  [2:0]  clken_dly;
reg  [ADDR_W :0]  ram_rd_addr;
reg  [ADDR_W :0]  ram_rd_addr_d0;
reg  [ADDR_W :0]  ram_rd_addr_d1;
reg  [DATA_W-1 :0]  shiftin_d0;
reg  [DATA_W-1 :0]  shiftin_d1;
reg  [DATA_W-1 :0]  shiftin_d2;


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

assign taps2x = shiftin_d2;


tp_ram 
#(
	.ADDR_W	(ADDR_W),
	.DATA_W	(DATA_W-1)
)
u_tp_ram_0
(
    .clock       (clock), //ram clk
    .wren        (clken_dly[2]), //ram 写使能
    .rden        (1'b1), //ram 读使能
    .wr_address  (ram_rd_addr_d1), //ram 写地址
    .rd_address  (ram_rd_addr), //ram 写地址
    .data        (shiftin_d2), //ram 写数据
    .q           (taps0x)//ram 读数据
);

tp_ram 
#(
	.ADDR_W	(ADDR_W),
	.DATA_W	(DATA_W-1)
)
u_tp_ram_1
(
    .clock       (clock), //ram clk
    .wren        (clken_dly[1] || clken_dly[2]), //ram 写使能
    .rden        (1'b1), //ram 读使能
    .wr_address  (ram_rd_addr_d1), //ram 写地址
    .rd_address  (ram_rd_addr), //ram 写地址
    .data        (taps0x), //ram 写数据
    .q           (taps1x)//ram 读数据
);

endmodule 