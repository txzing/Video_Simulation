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

Ϊ�˷�����ֲ��������ip��ͨ��verilog����˫�˿�ram
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

//���ݴ���ķֱ���ȷ��ram����ȺͿ�ȣ���Խ�ʡ��Դ�����˴���Ȳ����޸�
//���磬IMG_HDISP=640����ADDR_W=9, �Ѽ�һ
//��������
localparam  ADDR_W = log2b(IMG_HDISP);

//function����
/************* ��ȡ�����ķ��������ַָ���λ�� ************************/

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


tp_ram 
#(
	.ADDR_W	(ADDR_W),
	.DATA_W	(DATA_W-1)
)
u_tp_ram_0
(
    .clock       (clock), //ram clk
    .wren        (clken_dly[2]), //ram дʹ��
    .rden        (1'b1), //ram ��ʹ��
    .wr_address  (ram_rd_addr_d1), //ram д��ַ
    .rd_address  (ram_rd_addr), //ram д��ַ
    .data        (shiftin_d2), //ram д����
    .q           (taps0x)//ram ������
);

tp_ram 
#(
	.ADDR_W	(ADDR_W),
	.DATA_W	(DATA_W-1)
)
u_tp_ram_1
(
    .clock       (clock), //ram clk
    .wren        (clken_dly[1] || clken_dly[2]), //ram дʹ��
    .rden        (1'b1), //ram ��ʹ��
    .wr_address  (ram_rd_addr_d1), //ram д��ַ
    .rd_address  (ram_rd_addr), //ram д��ַ
    .data        (taps0x), //ram д����
    .q           (taps1x)//ram ������
);

endmodule 