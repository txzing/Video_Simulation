module tp_ram 
#(
parameter	ADDR_W = 13 ,	
parameter	DATA_W = 8  ,
parameter   DEEPTH = 1<<(ADDR_W+1)
)
(
input clock     , //ram clk
input wren      , //ram 写使能
input rden      , //ram 读使能
input [ADDR_W:0]  wr_address , //ram 写地址
input [ADDR_W:0]  rd_address , //ram 写地址
input [DATA_W:0]  data , //ram 写数据
output reg [DATA_W:0] q //ram 读数据
);


reg [DATA_W:0] ram [DEEPTH-1:0] ; //ram 数据
reg [DATA_W:0] rd_data = 0;
reg [DATA_W:0] data_r = 0;

//reg define
//initiallization
integer  i ;
initial begin
for (i = 0; i <= DEEPTH-1; i = i + 1)
    begin
        ram[i]  = 0;
    end
end 

//*****************************************************
//** main code
//*****************************************************
always @(posedge clock) 
begin
    if(wren)
        ram[wr_address] <= data;
end

always @(posedge clock) 
begin
    if(wren)
        data_r <= data;
    else
        data_r <= 0;
end

always @(posedge clock) 
begin
    if(rden)
        rd_data <= ram[rd_address];
    else
        rd_data <= 0;
end

reg conflict = 1'b0;
always @ (posedge clock) 
begin
    if (wren && rden && (wr_address == rd_address))
        conflict <= 1'b1;
    else
        conflict <= 1'b0;
end

always @ (posedge clock) 
begin
    if (conflict)
        q <= data_r;
    else
        q <= rd_data;
end

endmodule