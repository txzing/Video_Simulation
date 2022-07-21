/**************************************���ܽ���***********************************
Copyright:			
Date     :			
Author   :			
Version  :			
Description:��ͨ������ram IP��ʵ���������ݼĴ�,ʹ�ܼĴ�һ�����( RAM �е����ݻ�Ĵ�һ�����ں����)	
����˫�˿�RAM
ע�⣺����ͼ��ֱ��ʵĲ�ͬ���޸�ram����Ӧ���
��ͨ���޸ĵײ�ԭ�Ҳ��ʹ�÷ֲ�ʽram(�����߼���дram�ӿ�,���˷���ռ�õ���Դ�϶࣬LUT�����Դ���٣����Ƽ�)
�ӳ�3��clock,����3��1������
*********************************************************************************/
module Line_Shift_RAM_8Bit
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
    output  [7:0]  taps1x,
    output  [7:0]  taps2x    
);

//���ݴ���ķֱ���ȷ��ram����ȺͿ�ȣ���Խ�ʡ��Դ�����˴���Ȳ����޸�
//���磬IMG_HDISP=640����ADDR_W=9, �Ѽ�һ
//��������
    localparam  ADDR_W = log2b(IMG_HDISP);
    localparam  DATA_W = 7;

//function����
/************* ��ȡ�����ķ��������ַָ���λ�� ************************/

    function integer log2b(input integer data);
        begin 
            for(log2b=0;data>0;log2b=log2b+1)  
                data = data>>1;
            log2b = log2b - 1;
        end  
    endfunction

//reg define
reg  [2:0]  clken_dly;
reg  [11 :0]  ram_rd_addr;
reg  [11 :0]  ram_rd_addr_d0;
reg  [11 :0]  ram_rd_addr_d1;
reg  [ 7 :0]  shiftin_d0;
reg  [ 7 :0]  shiftin_d1;
reg  [ 7 :0]  shiftin_d2;


//*****************************************************
//**                    main code
//*****************************************************

//����������ʱ��ram��ַ�ۼ�
always@(posedge clock)begin
    if(pre_frame_href)
        if(clken)
            ram_rd_addr <= ram_rd_addr + 1 ;
        else
            ram_rd_addr <= ram_rd_addr ;
    else
        ram_rd_addr <= 0 ;
end

//ʱ��ʹ���ź��ӳ�����
always@(posedge clock) begin
    clken_dly <= { clken_dly[1:0] , clken };
end

//��ram��ַ�ӳٶ���
always@(posedge clock ) begin
    ram_rd_addr_d0 <= ram_rd_addr;
    ram_rd_addr_d1 <= ram_rd_addr_d0;
end

//���������ӳ�����
always@(posedge clock)begin
    shiftin_d0 <= shiftin;
    shiftin_d1 <= shiftin_d0;
    shiftin_d2 <= shiftin_d1;
end

assign taps2x = shiftin_d2;

//���ڴ洢ǰһ��ͼ���RAM
blk_mem_gen_0  
//  #(
// 	.ADDR_W	(ADDR_W),
// 	.DATA_W	(DATA_W)
// )
u_ram_1024x8_0(
    .clka  (clock),
    .dina  (shiftin_d2),     	
    .addra (ram_rd_addr_d1),
    .wea   (clken_dly[2]),

	.clkb  (clock),  
	.addrb (ram_rd_addr),
    .doutb (taps0x)          
);  

//���ڴ洢ǰǰһ��ͼ���RAM
blk_mem_gen_0  
//  #(
// 	.ADDR_W	(ADDR_W),	 
// 	.DATA_W	(DATA_W)
// )
u_ram_1024x8_1(
	.clka  (clock),
    .dina  (taps0x),     
    .addra (ram_rd_addr_d1),
    .wea   (clken_dly[1] || clken_dly[2]), 

	.clkb  (clock),   
    .addrb (ram_rd_addr),
    .doutb (taps1x)           
);


endmodule 