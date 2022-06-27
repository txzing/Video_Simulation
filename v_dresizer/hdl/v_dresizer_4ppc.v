`timescale 1ns/1ps
module v_dresizer_4ppc
#( 
    parameter COLUMN_DOWN                       = 1'b1  ,
    parameter LINE_DOWN                         = 1'b1  ,
    parameter PIEXL_WIDTH                       = 24    ,
    parameter S_AXIS_BYTES                      = 12    ,
    parameter S_AXIS_WIDTH                      = 96    ,
    parameter M_AXIS_BYTES                      = 12    ,
    parameter M_AXIS_WIDTH                      = 96    
)
(
    aclk,
    aresetn,
//input interface
    s_axis_tdata,
    s_axis_tdest,
    s_axis_tid,
    s_axis_tkeep,
    s_axis_tlast,
    s_axis_tready,
    s_axis_tstrb,
    s_axis_tuser,
    s_axis_tvalid,
//output interface   
    m_axis_tdata,
    m_axis_tdest,
    m_axis_tid,
    m_axis_tkeep,
    m_axis_tlast,
    m_axis_tready,
    m_axis_tstrb,
    m_axis_tuser,
    m_axis_tvalid
);

input   aclk;
input   aresetn;

input       [S_AXIS_WIDTH -1:0]  s_axis_tdata;
input                            s_axis_tvalid;
output  wire                     s_axis_tready;
input       [S_AXIS_BYTES -1:0]  s_axis_tkeep;
input       [S_AXIS_BYTES -1:0]  s_axis_tstrb;
input       [0:0]                s_axis_tuser;
input       [0:0]                s_axis_tlast;
input       [0:0]                s_axis_tid;
input       [0:0]                s_axis_tdest;
output  reg [M_AXIS_WIDTH-1:0]   m_axis_tdata;
output  reg                      m_axis_tvalid;
input                            m_axis_tready;
output  reg [M_AXIS_BYTES -1:0]  m_axis_tkeep;
output  reg [M_AXIS_BYTES -1:0]  m_axis_tstrb;
output  reg [0:0]                m_axis_tuser;
output  reg [0:0]                m_axis_tlast;
output  reg [0:0]                m_axis_tid;
output  reg [0:0]                m_axis_tdest;

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
        if((m_axis_tlast ==1'b0) && (s_axis_tlast==1'b1)) 
        begin
            col_cnt <= 16'b0;
        end
        else if((s_axis_tvalid ==1'b1) && (s_axis_tready==1'b1))
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
        if((m_axis_tlast ==1'b0) && (s_axis_tlast==1'b1))
        begin
            line_cnt <= line_cnt+1;
        end
        else if((m_axis_tuser[0]==1'b0) && (s_axis_tuser[0]==1'b1))
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
         always@(posedge aclk)
         begin
            if(!aresetn)
            begin
                m_axis_tvalid <= 0;
                m_axis_tdata <= 0;
            end
            else if(s_axis_tready)
            begin
                if(!col_cnt[0] && !line_cnt[0])
                begin
                    m_axis_tvalid <= 0;
                    //m_axis_tdata <= 0;
                    data_r <= {s_axis_tdata[(PIEXL_WIDTH*2) -1 : PIEXL_WIDTH*1],s_axis_tdata[PIEXL_WIDTH -1 : 0]};
                end
                else if(col_cnt[0] && !line_cnt[0])
                begin
                    m_axis_tvalid <= s_axis_tvalid;
                    m_axis_tdata <= {s_axis_tdata[(PIEXL_WIDTH*2) -1 : PIEXL_WIDTH*1],s_axis_tdata[PIEXL_WIDTH -1 : 0],data_r};
                end
                else // if (line_cnt[0])
                begin 
                    m_axis_tvalid <= 0;
                    //m_axis_tdata <= 0;
                end
            end
         end
    end
    else if ((COLUMN_DOWN == 1'b1) && (LINE_DOWN == 1'b0))
    begin
        always@(posedge aclk)
        begin
            if(!aresetn)
            begin
                m_axis_tvalid <= 0;
                m_axis_tdata <= 0;
            end
            else if(s_axis_tready)
            begin
                if(!col_cnt[0])
                begin
                    m_axis_tvalid <= 0;
                    //m_axis_tdata <= 0;
                    data_r <= {s_axis_tdata[(PIEXL_WIDTH*2) -1 : PIEXL_WIDTH*1],s_axis_tdata[PIEXL_WIDTH -1 : 0]};
                end
                else // if(col_cnt[0])
                begin
                    m_axis_tvalid <= s_axis_tvalid;
                    m_axis_tdata <= {s_axis_tdata[(PIEXL_WIDTH*2) -1 : PIEXL_WIDTH*1],s_axis_tdata[PIEXL_WIDTH -1 : 0],data_r};
                end
            end
        end
    end
    else if ((COLUMN_DOWN == 1'b0) && (LINE_DOWN == 1'b1))
    begin
        always@(posedge aclk)
        begin
            if(!aresetn)
            begin
                m_axis_tvalid <= 0;
                m_axis_tdata <= 0;
            end
            else if(s_axis_tready)
            begin
                if(!line_cnt[0])
                begin
                    m_axis_tvalid <= s_axis_tvalid;
                    m_axis_tdata <= s_axis_tdata;
                end
                else 
                begin 
                    m_axis_tvalid <= 0;
                    //m_axis_tdata <= 0;
                end
            end
        end
    end
    else           
    begin
        always@(posedge aclk)
        begin 
            if(!aresetn)
            begin
                 m_axis_tvalid <= 0;
                 m_axis_tdata <= 0;
            end
            else if(s_axis_tready)
            begin
                 m_axis_tvalid <= s_axis_tvalid;
                 m_axis_tdata <= s_axis_tdata;
            end
        end
    end

endgenerate

//
// assign m_axis_tvalid = s_axis_tvalid;
// assign m_axis_tdata = s_axis_tdata;
assign s_axis_tready = m_axis_tready | ~m_axis_tvalid;
// assign m_axis_tuser = s_axis_tuser;
// assign m_axis_tlast = s_axis_tlast;
always@(posedge aclk)
begin
    if (s_axis_tready)
    begin
        m_axis_tkeep        <=  s_axis_tkeep ;
        m_axis_tstrb        <=  s_axis_tstrb ;
        m_axis_tuser        <=  s_axis_tuser ;
        m_axis_tlast        <=  s_axis_tlast ;
        m_axis_tid          <=  s_axis_tid   ;
        m_axis_tdest        <=  s_axis_tdest ;
    end
end


////////////////
endmodule
