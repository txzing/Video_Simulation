module shift_reg
#(
	parameter	IMG_HDISP = 640,	//640*480
	parameter	IMG_VDISP = 480
)
(
    input          clk,
    input          ce,
    input   [7:0]  shift_in,
    output  [7:0]  taps0x,   
    output  [7:0]  taps1x
    );
 
reg [7:0] data_r [((2*IMG_HDISP)-1):0];

    function integer log2b(input integer data);
        begin 
            for(log2b=0;data>0;log2b=log2b+1)  
                data = data>>1;
            log2b = log2b - 1;
        end  
    endfunction

integer i;

//寄存两行数据
always@(posedge clk) begin
	if(ce) begin
        data_r[0] = shift_in;
        for(i=0;i<(2*IMG_HDISP);i=i+1)
		    data_r[i+1]<=data_r[i];
    end    
end
 
assign taps0x = data_r[IMG_HDISP-1];
assign taps1x = data_r[(2*IMG_HDISP)-1];
 
endmodule