`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/16 17:29:29
// Design Name: 
// Module Name: receive_data
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


module receive_data(
input clk,bd_clk,
input rst_n,
output reg [7:0] data,
input [1:0] parity_mode,
output reg busy,
input  RXD,
output reg parity_error,
output reg frame_error
    );


    reg done;
    reg state;
    parameter receive = 1, IDLE = 0;
    always@(posedge clk or negedge rst_n)
    begin
      if(!rst_n)
        state <= IDLE;
      else
      begin
        case(state)
        IDLE:if(!RXD) state <= receive;
        receive:if(done) state <= IDLE;
        default:state <= IDLE;
        endcase
      end
    end    

    reg [7:0] cnt;
    always@(posedge clk)
    begin
         case(state)
         IDLE:begin
               busy <= 0;
               done <= 0;
               cnt <= 0;
               data <= 0;
              end
         receive:begin
                   busy <= 1;
                   if(bd_clk)
                     cnt <= cnt + 1;
                   case(cnt)
                   6:begin
                       if(RXD) 
                         done <= 1;//起始位太短认为是干扰，返回IDLE
                       else
                       begin
                         frame_error <= 0;//确认新帧的起始位后把之前的错误标志位清零
                         parity_error <= 0;                       
                       end
                     end
                   12:data[0] <= RXD;//在每一位数据有效阶段的中间时刻读数
                   20:data[1] <= RXD;
                   28:data[2] <= RXD;
                   36:data[3] <= RXD;
                   44:data[4] <= RXD;
                   52:data[5] <= RXD;
                   60:data[6] <= RXD;
                   68:data[7] <= RXD;
                   76:begin
                        if(parity_mode[1])
                        begin
                          if(RXD !== (data[0]+data[1]+data[2]+data[3]+data[4]+data[5]+data[6]+data[7]+parity_mode[0]))
                            parity_error <= 1;
                        end
                        else
                        begin
                          done <= 1;
                          if(!RXD)
                            frame_error <= 1;
                        end
                      end
                   84:begin
                        done <= 1;
                        if(!RXD)
                          frame_error <= 1; 
                      end        
                   endcase
                 end
         endcase
    end
endmodule
