#tcl脚本  自动化仿真                         
#创建工作库 名为work                       
vlib work                       
                                    
#映射工作库 work 到 work                   
vmap work work                           
   
#编译testbench文件                     
vlog video_sim_tb.v                       
                                                    
#若要仿真IP核必须添加该文件                                 
#vlog altera_mf.v                                   
                                                          
#编译被仿真文件                                                                               
vlog  ./VIP/*.v   
vlog  ./VIP/martix_ram/*.v   
vlog  ./VIP/ab/*.v   
vlog  ./VIP/raw2rgb/*.v 
vlog  ./VIP/tpg/*.v   
                                                                                                         
                                                             
#指定仿真顶层                                                 
vsim -voptargs=+acc work.video_sim_tb

                                                            
#添加testbench顶层模块中的信号到波形窗    
#add wave -position insertpoint sim:/video_sim_tb/*
                                                            
#表示让该tb_clk信号显示黄色									
#add wave -position insertpoint sim:/video_sim_tb/u_rgb2raw/* 
#add wave -position insertpoint sim:/video_sim_tb/u_color_data_gen/*          
add wave -position insertpoint sim:/video_sim_tb/u_Video_Image_Processor/u_VIP_RAW2RGB888/*   
                                                             
#运行2000个时间单位                                           
#run 200000000                                                     
                                                             
#一直仿真下去                                                 
run -all     
