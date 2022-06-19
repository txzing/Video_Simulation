`timescale 1ns/1ps
module v_dsampler_4ppc
   #( 
        parameter COLUMN_DOWN = 1'b1,
        parameter LINE_DOWN   = 1'b1, 
        parameter PIEXL_WIDTH = 24,       
        parameter S_AXIS_WIDTH = 24,
        parameter M_AXIS_WIDTH = 24 
        
   )
   (
    input                          aclk,
    input                          aresetn,
//input interface
    input                          s_axis_tvalid,
    output                         s_axis_tready,
    input  [S_AXIS_WIDTH -1:0]     s_axis_tdata,
    input                          s_axis_tlast,
    input  [0:0]                   s_axis_tuser,
//output interface      
    output reg                     m_axis_tvalid,
    input                          m_axis_tready,
    output reg [M_AXIS_WIDTH -1:0] m_axis_tdata,
    output                         m_axis_tlast,
    output [0:0]                   m_axis_tuser
    );
//
// assign m_axis_tvalid = s_axis_tvalid;
// assign m_axis_tdata = s_axis_tdata;
assign s_axis_tready = m_axis_tready;
assign m_axis_tuser = s_axis_tuser;
assign m_axis_tlast = s_axis_tlast;

//
reg [15:0] line_cnt;
reg [15:0] col_cnt;


always@(posedge aclk)
begin
    if(!aresetn)
    begin
        col_cnt <= 16'b0;
    end
    else
    begin
        if((s_axis_tvalid ==1'b1) && (s_axis_tlast==1'b1) && (m_axis_tready ==1'b1)) 
        begin
            col_cnt <= 16'b0;
        end
        else if((s_axis_tvalid ==1'b1) && (m_axis_tready==1'b1))
        begin
            col_cnt <= col_cnt + 1'b1;
        end
    end
end

always@(posedge aclk)
begin
    if(!aresetn)
    begin
        line_cnt <= 16'b0;
    end
    else
    begin
        if((s_axis_tvalid ==1'b1) && (s_axis_tlast==1'b1) && (m_axis_tready ==1'b1))
        begin
            line_cnt <= line_cnt+1;
        end
        else if((s_axis_tvalid ==1'b1) && (m_axis_tready==1'b1) && (m_axis_tuser[0]==1'b1))
        begin
            line_cnt <= 16'b0;    
        end
    end
end

reg  [(PIEXL_WIDTH*2)-1 : 0]  data_r;

//defalut odd 
generate
    if ((COLUMN_DOWN == 1'b1) && (LINE_DOWN == 1'b1))
    begin
         always @(*)begin 
            if(!col_cnt[0] && !line_cnt[0])
            begin
                m_axis_tvalid = 0;
                m_axis_tdata = 0;
                data_r = {s_axis_tdata[(PIEXL_WIDTH*2) -1 : PIEXL_WIDTH*1],s_axis_tdata[PIEXL_WIDTH -1 : 0]};
            end
            else if(col_cnt[0] && !line_cnt[0])
            begin
                m_axis_tvalid = s_axis_tvalid;
                m_axis_tdata = {s_axis_tdata[(PIEXL_WIDTH*2) -1 : PIEXL_WIDTH*1],s_axis_tdata[PIEXL_WIDTH -1 : 0],data_r};
            end
            else 
            begin 
               m_axis_tvalid = 0;
               m_axis_tdata = 0;
            end 
         end
    end
    else if ((COLUMN_DOWN == 1'b1) && (LINE_DOWN == 1'b0))
    begin
        always @(*)begin 
            if(!col_cnt[0])
            begin
                m_axis_tvalid = 0;
                m_axis_tdata = 0;
                data_r = {s_axis_tdata[(PIEXL_WIDTH*2) -1 : PIEXL_WIDTH*1],s_axis_tdata[PIEXL_WIDTH -1 : 0]};
            end
            else if(col_cnt[0])
            begin
                m_axis_tvalid = s_axis_tvalid;
                m_axis_tdata = {s_axis_tdata[(PIEXL_WIDTH*2) -1 : PIEXL_WIDTH*1],s_axis_tdata[PIEXL_WIDTH -1 : 0],data_r};
            end
            else 
            begin 
               m_axis_tvalid = 0;
               m_axis_tdata = 0;
            end 
        end
    end
    else if ((COLUMN_DOWN == 1'b0) && (LINE_DOWN == 1'b1))
    begin
        always @(*)begin 
            if(!line_cnt[0])
            begin
               m_axis_tvalid = s_axis_tvalid;
               m_axis_tdata = s_axis_tdata;
            end
            else 
            begin 

               m_axis_tvalid = 0;
               m_axis_tdata = 0;
            end 
        end
    end
    else           
    begin
        always @(*)begin 
            begin
               m_axis_tvalid = s_axis_tvalid;
               m_axis_tdata = s_axis_tdata;
            end
        end
    end

endgenerate

////////////////
endmodule
