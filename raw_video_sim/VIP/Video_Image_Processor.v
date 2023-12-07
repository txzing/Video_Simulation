`timescale 1ns/1ns
module Video_Image_Processor
#(
    parameter   [1:0]   BAYER_PATTERN = 2'b00,
	parameter	[12:0]	IMG_HDISP = 13'd640,	//640*480
	parameter	[12:0]	IMG_VDISP = 13'd480,
    parameter	[4:0]   DATA_W    = 5'd8   
)
(
	input				        clk             ,  				//cmos video pixel clock
	input				        rst_n           ,				//global reset


	//Image data prepred to be processd
	input				        pre_frame_vsync ,	//Prepared Image data vsync valid signal
	input				        pre_frame_href  ,		//Prepared Image data href vaild  signal
`ifndef RX_RGB888 // 
	input		[DATA_W -1 :0]	pre_img_data    ,		//Prepared Image data of YCbCr 4:2:2 {CbY} {CrY}
`else
    input		[23:0]	pre_img_data            ,
`endif
	//Image data has been processd
	output				        post_frame_vsync,	//Processed Image data vsync valid signal
	output				        post_frame_href ,	//Processed Image data href vaild  signal
`ifndef RX_RGB888 // 
	output		[DATA_W -1 :0]	post_img_red    ,		//Processed Image Red output
	output		[DATA_W -1 :0]	post_img_green  ,		//Processed Image Green output
	output		[DATA_W -1 :0]	post_img_blue		    //Processed Image Blue output
`else   
	output		[7:0]	post_img_red            ,		//Processed Image Red output
	output		[7:0]	post_img_green          ,		//Processed Image Green output
	output		[7:0]	post_img_blue		    //Processed Image Blue output
`endif
);




`ifndef RX_RGB888 // 

wire        ad_frame_vsync;
wire        ad_frame_href ;
wire [11:0] ad_img_data   ;

    ab 
    #(
        .horizontal(IMG_HDISP),
        .vertical  (IMG_VDISP)
    ) 
    u_ab 
    (                    
        .rstn		(rst_n),
        .clk		(clk),
        .fv_in		(pre_frame_vsync        ),
        .lv_in		(pre_frame_href         ),  
        .data_in	({pre_img_data, 4'b0}   ),                                     
                            
        .fv_out		(ad_frame_vsync),   
        .lv_out		(ad_frame_href ),
        .data_out	(ad_img_data   )
    ); 

    VIP_RAW2RGB888
    #(
        .BAYER_PATTERN (2'b00),
        .IMG_HDISP (IMG_HDISP),	
        .IMG_VDISP (IMG_VDISP),
        .DATA_W    (DATA_W)
        
    )
    u_VIP_RAW2RGB888
    (
    /*input						*/.clk				(clk),  			//cmos video pixel clock
    /*input						*/.rst_n			(rst_n),			//global reset
    /*input						*/.pre_frame_vsync	(ad_frame_vsync),	//Prepared Image data vsync valid signal
    /*input						*/.pre_frame_href	(ad_frame_href ),	//Prepared Image data href vaild  signal
    /*input						*/.pre_img_RAW		(ad_img_data   ),	//Prepared Image data 8 Bit RAW Data
    /*output					*/.post_frame_vsync	(post_frame_vsync),	//Processed Image data vsync valid signal
    /*output					*/.post_frame_href	(post_frame_href),	//Processed Image data href vaild  signal
    /*output	[DATA_W -1 :0]	*/.post_img_red		(post_img_red	),	//Prepared Image green data to be processed	
    /*output	[DATA_W -1 :0]	*/.post_img_green	(post_img_green ),	//Prepared Image green data to be processed
    /*output	[DATA_W -1 :0]	*/.post_img_blue	(post_img_blue)	    //Prepared Image blue data to be processed
    );
`else     
    post_frame_vsync    = pre_frame_vsync ;
    post_frame_href     = pre_frame_href  ;
    post_img_red        = pre_img_data[23:16]   ;
    post_img_green      = pre_img_data[15:8]    ;
    post_img_blue	    = pre_img_data[7:0]     ;
`endif

endmodule