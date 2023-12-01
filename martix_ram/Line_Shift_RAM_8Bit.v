module Line_Shift_RAM_8Bit
#(
	parameter	IMG_HDISP = 640,	//640*480
    parameter	DATA_W = 8
)
(
    input          clk,
    input		   rst_n,
    input          ce,
    input   [DATA_W -1 :0]  shift_in,
    output reg [DATA_W -1 :0]  taps0x,   
    output reg [DATA_W -1 :0]  taps1x
    );
    

reg [DATA_W-1:0] data_r [((2*IMG_HDISP)-1):0];
 
 
 /*
    function integer log2b(input integer data);
        begin 
            for(log2b=0;data>0;log2b=log2b+1)  
                data = data>>1;
            log2b = log2b - 1;
        end  
    endfunction
*/


integer i;
//寄存两行数据
always@(posedge clk) begin
	if(!rst_n)
    begin
        for(i=0;i<(2*IMG_HDISP);i=i+1)
		    data_r[i]<= 0;
    end
	else if(ce)
    begin 
        data_r[0] = shift_in;
        for(i=0;i<(2*IMG_HDISP);i=i+1)
            data_r[i+1]<=data_r[i];
    end    
end
 
always@(posedge clk) begin
	if(!rst_n)
    begin
        taps0x <= 0;
        taps1x <= 0;
    end
	else if(ce)
    begin 
        taps0x <= data_r[IMG_HDISP-1];
        taps1x <= data_r[(2*IMG_HDISP)-1];
    end    
end
 
endmodule