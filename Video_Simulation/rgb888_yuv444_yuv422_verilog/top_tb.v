`timescale 1ns/1ns
`define clk_period 20

module top_tb;

	reg Clk;
	reg Rst_n;
    
    reg [23:0] data_i;
    
    wire [23:0] data;
    wire href;
    wire vsync;
    wire rden;
    
    integer fd;
    integer fd2;
    integer fd3;
    integer fd4;
    integer fd5;
    integer ret;
    integer count;
    integer frame_cnt;
    integer img_writing;
    integer rgb_writing;
    integer yuv422_writing;
    integer yuv444_writing;
    
    localparam  F_START = 0;
    localparam  F_CURR = 1;
    localparam  F_END = 2;

colorbar_gen #
(
    .word_width    ('d24    ),
    .h_active      ('d640  ),
	.h_total       ('d800  ),
	.v_active      ('d480  ),
	.v_total       ('d525  ),
	.H_FRONT_PORCH ('d16   ),
	.H_SYNCH       ('d96   ),
	.H_BACK_PORCH  ('d48   ),
	.V_FRONT_PORCH ('d10   ),
	.V_SYNCH       ('d2    ),
    .V_BACK_PORCH  ('d33   ),
    .input_mode    ('b1    )
) colorbar_gen_inst
(
    .reset_n        (Rst_n  ), 
    .clk            (Clk    ), 
    .data_i         (data_i ),
    .rden           (rden   ),
    .pattern_mode   (4'd0   ), 
    .fv             (       ), 
    .lv             (       ), 
    .data           (data   ),
    .de             (href   ),
    .vsync          (vsync  ),
    .hsync          (       ),
    .x_cnt          (       ),
    .y_cnt          (       ),
    .h_cnt          (       ),
    .v_cnt          (       ),
    .ready          (       )
);

wire href_o;
wire vsync_o;
wire clken_o;
wire [7:0] Y;
wire [7:0] Cb;
wire [7:0] Cr;
wire [23:0] YCbCr;
assign YCbCr={Y,Cb,Cr};
Image_RGB888_YCbCr444 VIP_inst0
(
    .clk                 (Clk),  				//cmos video pixel clock
    .rst_n               (Rst_n),				//global reset
    .per_frame_vsync     (vsync),	//Prepared Image data vsync valid signal
    .per_frame_href      (href),		//Prepared Image data href vaild  signal
    .per_frame_clken     (1'b1),	//Prepared Image data output/capture enable clock	
    .per_img_red         (data[23:16]),		//Prepared Image red data to be processed
    .per_img_green       (data[15:8]),		//Prepared Image green data to be processed
    .per_img_blue        (data[7:0]),		//Prepared Image blue data to be processed
    .post_frame_vsync    (vsync_o),	//Processed Image data vsync valid signal
    .post_frame_href     (href_o),	//Processed Image data href vaild  signal
    .post_frame_clken    (clken_o),	//Processed Image data output/capture enable clock	
    .post_img_Y          (Y),			//Processed Image brightness output
    .post_img_Cb         (Cb),		//Processed Image blue shading output
    .post_img_Cr         (Cr)			//Processed Image red shading output
);

wire [7:0] Y1;
wire [7:0] CbCr;
wire rgb_de1;
wire rgb_vsync1;
wire clken1;
Image_YCbCr444_YCbCr422 VIP_inst2
(
	.clk                (Clk),  				//cmos video pixel clock
	.rst_n              (Rst_n),				//global reset
	.per_frame_vsync    (vsync_o),	//Prepared Image data vsync valid signal
	.per_frame_href     (href_o),		//Prepared Image data href vaild  signal
	.per_frame_clken    (clken_o),	//Prepared Image data output/capture enable clock	
	.per_img_Y          (Y),			//Prepared Image data of YCbCr 4:4:4
	.per_img_Cb         (Cb),			//Prepared Image data of YCbCr 4:4:4
	.per_img_Cr         (Cr),			//Prepared Image data of YCbCr 4:4:4
	.post_frame_vsync   (rgb_vsync1),	//Processed Image data vsync valid signal
	.post_frame_href    (rgb_de1),	//Processed Image data href vaild  signal
	.post_frame_clken   (clken1),	//Processed Image data output/capture enable clock	
	.post_img_YCbCr     ({CbCr,Y1})		//Processed Image data of YCbCr 4:2:2 {CbY} {CrY}
);

wire [7:0] R;
wire [7:0] G;
wire [7:0] B;
wire rgb_de;
wire rgb_vsync;
Image_YCbCr444_RGB888 VIP_inst1
(
	.clk                (Clk        ),  				//cmos video pixel clock
	.rst_n              (Rst_n      ),				//global reset
	.per_frame_vsync    (vsync_o    ),	//Prepared Image data vsync valid signal
	.per_frame_href     (href_o     ),		//Prepared Image data href vaild  signal
	.per_frame_clken    (clken_o    ),	//Prepared Image data output/capture enable clock	
	.per_img_Y          (Y          ),			//Prepared Image data of Y
	.per_img_Cb         (Cb         ),			//Prepared Image data of Cb
	.per_img_Cr         (Cr         ),			//Prepared Image data of Cr
	.post_frame_vsync   (rgb_vsync  ),	//Processed Image data vsync valid signal
	.post_frame_href    (rgb_de     ),	//Processed Image data href vaild  signal
	.post_frame_clken   (           ),	//Processed Image data output/capture enable clock
	.post_img_red       (R          ),		//Prepared Image green data to be processed	
	.post_img_green     (G          ),		//Prepared Image green data to be processed
	.post_img_blue      (B          )		//Prepared Image blue data to be processed
);

wire vsync2;
wire href2;
wire clken2;
wire [7:0] Y2;
wire [7:0] Cb2;
wire [7:0] Cr2;
Image_YCbCr422_YCbCr444 VIP_inst3
(
	.clk                (Clk),  				//cmos video pixel clock
	.rst_n              (Rst_n),				//global reset
	.per_frame_vsync    (rgb_vsync1),	//Prepared Image data vsync valid signal
	.per_frame_href     (rgb_de1),		//Prepared Image data href vaild  signal
	.per_frame_clken    (clken1),	//Prepared Image data output/capture enable clock	
	.per_frame_YCbCr    ({CbCr,Y1}),	//Prepared Image data of YCbCr 4:2:2 {CbY} {CrY}
	.post_frame_vsync   (vsync2),	//Processed Image data vsync valid signal
	.post_frame_href    (href2),	//Processed Image data href vaild  signal
	.post_frame_clken   (clken2),	//Processed Image data output/capture enable clock	
	.post_img_Y         (Y2),			//Processed Image data of YCbCr 4:4:4
	.post_img_Cb        (Cb2),		//Processed Image data of YCbCr 4:4:4
	.post_img_Cr        (Cr2)			//Processed Image data of YCbCr 4:4:4
);

	initial Clk = 1;
	always#(`clk_period/2)Clk = ~Clk;
	
	initial begin
        fd = $fopen("rgb888.ppm","r");
        if(fd == 0)
        begin
            $display("$open file failed") ;
            $stop;
        end
        $display("\n ============= file opened... ============= ") ;
		Rst_n = 1'b0;

		#(`clk_period*20 + 1 );
		Rst_n = 1'b1;

		//@(posedge vsync)
		//#(`clk_period*5000);
        
        ret = $fseek(fd, 14, F_START);
        if($signed(ret) == -1)
        begin
            $display("$fseek failed") ;
            $stop;
        end
        $display("position = ", $ftell(fd)) ;
        frame_cnt=0;
        while(frame_cnt<5)
        begin
            while(! $feof(fd))
            begin
                if(rden)
                    begin
                    count=$fscanf(fd,"%0d\n%0d\n%0d\n" ,data_i[23:16],data_i[15:8],data_i[7:0]) ;
                    //$display("%0d" , data_i) ;
                    //$display("%0d %0d %0d count=%0d" , data_i[23:16],data_i[15:8],data_i[7:0], count) ;
                    $display("%0d %0d %0d" , data_i[23:16],data_i[15:8],data_i[7:0]) ;
                end
                #(`clk_period*1);
            end
            $fseek(fd, 14, F_START);
            frame_cnt=frame_cnt+1;
        end
        
        @(negedge vsync)
        #(`clk_period*100);
        $fclose(fd);
        $display("simulation stop\n");
		$stop;	
	end


initial begin
    img_writing = 1;
    fd2 = $fopen("yuv444.yuv","wb+");
    while(img_writing == 1) begin
    @(posedge Clk)
        if(href_o) begin
            // $fdisplay (fd2, "%c", y);
            //$fwrite(fd2,"%02x\n%02x\n%02x\n", Y, Cb, Cr);
            $fwrite(fd2,"%c%c%c", Y, Cr, Cb);
        end
        else if (vsync) begin
            img_writing = 0;
        end
    end
    @(negedge vsync)
    #(`clk_period*100);
    $fclose(fd2);
end

initial begin
    rgb_writing = 1;
    fd3 = $fopen("rgb888_out.ppm","w+");
    $fwrite(fd3,"P3\n");
    $fwrite(fd3,"%0d %0d\n",640, 480);
    $fwrite(fd3,"%0d\n",2**8-1); // 8bit 255
    while(rgb_writing == 1) begin
    @(posedge Clk)
        if(rgb_de) begin
            $fwrite(fd3,"%0d\n%0d\n%0d\n", R, G, B);
        end
        else if (rgb_vsync) begin
            rgb_writing = 0;
        end
    end
    @(negedge rgb_vsync)
    #(`clk_period*100);
    $fclose(fd3);
end

initial begin
    yuv422_writing = 1;
    fd4 = $fopen("yuv422.yuv","wb+");
    while(yuv422_writing == 1) begin
    @(posedge Clk)
        if(rgb_de1) begin
            $fwrite(fd4,"%c%c", CbCr, Y);
        end
        else if (rgb_vsync1) begin
            yuv422_writing = 0;
        end
    end
    @(negedge rgb_vsync1)
    #(`clk_period*100);
    $fclose(fd4);
end

initial begin
    yuv444_writing = 1;
    fd5 = $fopen("yuv444b.yuv","wb+");
    while(yuv444_writing == 1) begin
    @(posedge Clk)
        if(href2) begin
            $fwrite(fd5,"%c%c%c", Y2, Cr2, Cb2);
        end
        else if (vsync2) begin
            yuv444_writing = 0;
        end
    end
    @(negedge vsync2)
    #(`clk_period*100);
    $fclose(fd5);
end

endmodule
