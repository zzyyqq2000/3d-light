`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/16 10:16:18
// Design Name: 
// Module Name: uart
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart(
  input clk_sys,
  
  input rst_n,btn_pin,
  input PC_Uart_rxd,
  output PC_Uart_txd,
  output [7:0] seg_cs,
  output [6:0] seg_data_0_pin,seg_data_1_pin ,
  output reg [7:0] led_pin ,
  output reg exp_io,
  output reg exp_io_n
    );
  wire clk;
  clk_div #(40) c0(.clk_in(clk_sys), .clk_out(clk));
  
  wire btn_send;
  btn_detect BTN_detect(.clk(clk_sys),.rst_n(rst_n),.btn_in(rec_data[0]),.btn_out(),.pos_edge(btn_send),.neg_edge());
  
  reg [1:0] parity_mode = 2'b10;//paraity_mode = 2'b10 偶校验， =2'b11 奇校验， =2'b00 不校验
  
  wire turn_on;
  wire bd_clk;
  baudrate #(.clk_freq(100000000), .baudrate(9600*8)) Baudrate(.clk(clk_sys),.rst_n(rst_n),.en(turn_on),.bd_clk(bd_clk));
  
 
//  wire txd;
//  send_data Send_data(.clk(clk_sys),.bd_clk(bd_clk),.rst_n(rst_n),.start(start),
//                       .data(data_send),.parity_mode(parity_mode),.busy(turn_on),.TXD(PC_Uart_txd));
 
 wire [7:0] rec_data;
 receive_data Rec_data(.clk(clk_sys),.bd_clk(bd_clk),.rst_n(rst_n),
                        .data(rec_data),.parity_mode(parity_mode),.busy(turn_on),.RXD(PC_Uart_rxd),
                        .parity_error(),.frame_error());
                       
 reg start;
 reg [7:0] data_send;
 

    
    always@(posedge clk_sys or negedge rst_n)
    begin
      if(!rst_n)
         led_pin = 0;
      else
          led_pin = rec_data;
    end
   
   
     //输出pwm---------------------------------------------------
    always@(clk_sys)
    begin
          exp_io_n=0;
          exp_io=rec_data[0];
    end 
endmodule
