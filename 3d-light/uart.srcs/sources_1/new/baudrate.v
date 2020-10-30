`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/16 10:44:46
// Design Name: 
// Module Name: baudrate
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


module baudrate(
  input clk,
  input rst_n,en,
  output reg bd_clk
    );
  parameter clk_freq = 100000000;
  parameter baudrate = 9600;
  parameter contmax = clk_freq / baudrate - 1;
  reg [31:0] cont;
  
  always@(posedge clk or negedge rst_n)
  begin
     if(!rst_n | !en)
     begin
        cont <= 0;
        bd_clk <= 0;
     end
     else if(cont < contmax)
        begin
           cont <= cont + 1;
           bd_clk <= 0;
        end 
     else
        begin
           cont <= 0;
           bd_clk <= 1;
        end 
   end
  
endmodule
