`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/16 11:06:32
// Design Name: 
// Module Name: send_data
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


module send_data(
  input clk,bd_clk,
  input rst_n,start,
  input [7:0] data,
  input [1:0] parity_mode,
  output reg busy,
  output reg TXD

    );
  //paraity_mode = 2'b10 偶校验， =2'b11 奇校验， =2'b00 不校验
  reg [11:0] state;
  parameter IDLE=12'b1, start_bit=IDLE<<1, 
             send_bit0=IDLE<<2, send_bit1=IDLE<<3, send_bit2=IDLE<<4, send_bit3=IDLE<<5,
             send_bit4=IDLE<<6, send_bit5=IDLE<<7, send_bit6=IDLE<<8, send_bit7=IDLE<<9, 
             check_bit=IDLE<<10, end_bit=IDLE<<11; 
  always@(posedge clk or negedge rst_n)
  begin
     if(!rst_n )
        state = IDLE;
     else
        case(state)
        IDLE:begin if(start) state <= start_bit;else state = IDLE; end
        start_bit:if(bd_clk)state = send_bit0;
        send_bit0:if(bd_clk)state = send_bit1;  
        send_bit1:if(bd_clk)state = send_bit2; 
        send_bit2:if(bd_clk)state = send_bit3; 
        send_bit3:if(bd_clk)state = send_bit4; 
        send_bit4:if(bd_clk)state = send_bit5; 
        send_bit5:if(bd_clk)state = send_bit6; 
        send_bit6:if(bd_clk)state = send_bit7; 
        send_bit7:if(bd_clk)
                  begin
                     if(parity_mode[1])
                       state = check_bit;
                     else
                       state = end_bit;
                  end
        check_bit:if(bd_clk)state = end_bit;
        end_bit:if(bd_clk)state = IDLE;
        default:state = IDLE;
        endcase
  end
  
  always@(posedge clk)
  begin
     case(state)
     IDLE:begin
            TXD <= 1;
           busy <= 0;
          end
     start_bit:begin
                 TXD <= 0;
                 busy <= 1;
               end
     send_bit0:TXD <= data[0];
     send_bit1:TXD <= data[1];
     send_bit2:TXD <= data[2];
     send_bit3:TXD <= data[3];
     send_bit4:TXD <= data[4];
     send_bit5:TXD <= data[5];
     send_bit6:TXD <= data[6];
     send_bit7:TXD <= data[7];
     check_bit:TXD <= data[0]+data[1]+data[2]+data[3]+data[4]+data[5]+data[6]+data[7]+parity_mode[0];
     end_bit:TXD <= 1;
     endcase
  end

  
  
endmodule
