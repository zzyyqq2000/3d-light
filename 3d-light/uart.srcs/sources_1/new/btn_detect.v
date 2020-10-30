`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/15 19:16:35
// Design Name: 
// Module Name: btn_detect
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


module btn_detect(
  input clk,
  input rst_n,
  input btn_in,
  output reg btn_out,
  output  pos_edge,
  output  neg_edge
    );
     reg BTN_buf;
     reg [32:0] cnt;
     parameter clk_sys_freq = 100000000;
     parameter delay = 2;//ms
     parameter cnt_max = delay * clk_sys_freq / 1000 - 1;//1999999
     always@(posedge clk or negedge rst_n)
     begin
       if(!rst_n)
       begin
         btn_out <= 0;
         BTN_buf <= 0;
         cnt <= 0;
       end
       else if(btn_in != BTN_buf)
       begin
         if( cnt < cnt_max)
           cnt <= cnt + 1;
         else
         begin
           cnt <= 0;
           BTN_buf <= btn_in;
           btn_out <= btn_in;
         end
       end
       else
       begin
         cnt <= 0;
         btn_out <= BTN_buf;
       end
     end
    
        reg btn_pre;
     always@(posedge clk or negedge rst_n)
     begin
       if(!rst_n)
         btn_pre <= 0;
       else
         begin

            btn_pre = btn_in;
         end
     end
     assign pos_edge = (!btn_pre) & btn_in;
     assign neg_edge = btn_pre & (!btn_in);
endmodule
