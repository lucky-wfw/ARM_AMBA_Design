//---------------------------------------------------------------
// Module Name: decoder_tb
// The testbenc of decoder
// Author: WangFw
// Created on 2020-11-2
//---------------------------------------------------------------

`timescale 1ns/1ns

module decoder_tb();

reg [1:0] sel;
wire hsel_1;
wire hsel_2;
wire hsel_3;
wire hsel_4;


initial begin
  sel = 2'b00;
  #20 sel = 2'b01;
  #20 sel = 2'b10;
  #20 sel = 2'b11;
end


decoder dut(
  .sel(sel),
  .hsel_1(hsel_1),
  .hsel_2(hsel_2),
  .hsel_3(hsel_3),
  .hsel_4(hsel_4)
);


endmodule

