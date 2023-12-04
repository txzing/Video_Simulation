#tcl脚本  自动化仿真                         
#创建工作库 名为work                       
vlib work                       
                                    
#映射工作库 work 到 work                   
vmap work work                           
   
#编译testbench文件                     
vlog bmp_sim_tb.v                       
                                                    
#若要仿真IP核必须添加该文件                                 
vlog altera_mf.v                                   
                                                          
#编译被仿真文件                                                                               
vlog  ./VIP/*.v   
vlog  ./VIP/median/*.v   
vlog  ./VIP/martix_ram/*.v 
vlog  ./VIP/sobel/*.v   
     
                                                                         
#对IP核进行仿真                                               
#vlog ../par/ipcore/pll.v                                    
                                                             
#指定仿真顶层                                                 
vsim -voptargs=+acc work.bmp_tb

                                                            
#添加testbench顶层模块中的信号到波形窗    
#add wave -position insertpoint sim:/bmp_tb/*
                                                            
#表示让该tb_clk信号显示黄色									
#add wave -noupdate -color Yellow /follow_led_tb/tb_clk		

add wave -position insertpoint sim:/bmp_tb/u_gray_median_filter/u_VIP_Matrix_Generate_3X3_8Bit/*

#add wave -position insertpoint sim:/bmp_tb/u_gray_median_filter/u_VIP_Matrix_Generate_3X3_8Bit/u_Line_Shift_RAM_8Bit/*     
#add wave -position insertpoint sim:/bmp_tb/u_gray_median_filter/u_VIP_Matrix_Generate_3X3_8Bit/u_Line_Shift_RAM_8Bit/u_tp_ram_0/*           

#表示让div_coef信号用十进制tb_led来显示						   
#add wave -noupdate -radix decimal /follow_led_tb/tb_led     
                                                             
#运行2000个时间单位                                           
#run 200000000                                                     
                                                             
#一直仿真下去                                                 
run -all     
