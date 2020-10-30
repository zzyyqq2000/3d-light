`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/16 13:59:54
// Design Name: 
// Module Name: clk_div
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


module clk_div(
    input clk_in,
output reg clk_out
    );
        parameter [31:0] period = 2;//两毫秒一个周期
    wire [31:0] cnt_num;
    reg [31:0] cnt;
    assign cnt_num = ( period*100000 >>1) - 1; 
    always@(posedge clk_in)
    begin
      if(cnt < cnt_num)
        cnt <= cnt + 1;
      else
        begin
          cnt <= 0;
          clk_out <= !clk_out;
        end
    end
endmodule
