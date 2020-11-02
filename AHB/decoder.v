//-----------------------------------------------------------
// Module Name: Decoder
// The decoder for ahb system with 4 slave
// Author: WangFW
// Created on 2020-11-2
//-----------------------------------------------------------

module decoder(
  input [1:0] sel,
  output reg hsel_1,
  output reg hsel_2,
  output reg hsel_3,
  output reg hsel_4
);

always @(*) begin
  case(sel)
    2'b00: begin
      hsel_1 = 1'b1;
      hsel_2 = 1'b0;
      hsel_3 = 1'b0;
      hsel_4 = 1'b0;
    end
    2'b01: begin
      hsel_1 = 1'b0;
      hsel_2 = 1'b1;
      hsel_3 = 1'b0;
      hsel_4 = 1'b0;
    end
    2'b10: begin
      hsel_1 = 1'b0;
      hsel_2 = 1'b0;
      hsel_3 = 1'b1;
      hsel_4 = 1'b0;
    end
    2'b11: begin
      hsel_1 = 1'b0;
      hsel_2 = 1'b0;
      hsel_3 = 1'b0;
      hsel_4 = 1'b1;
    end
    default: begin
      hsel_1 = 1'b0;
      hsel_2 = 1'b0;
      hsel_3 = 1'b0;
      hsel_4 = 1'b0;
    end
  endcase
end


endmodule

