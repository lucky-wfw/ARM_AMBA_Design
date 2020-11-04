//-------------------------------------------------------------
// Module Name: ahb_top_tb
// The testbench of ahb_top
// Author: WangFW
// Created on 2020-11-4
//-------------------------------------------------------------

`timescale 1ns/1ns

module ahb_top_tb();

reg hclk;
reg hresetn;
reg enable;
reg [31:0] dina;
reg [31:0] dinb;
reg [31:0] addr;
reg wr;
reg [1:0] slave_sel;
wire [31:0] dout;

initial begin
  hclk = 0;
  hresetn = 1;
  enable = 1'b0;
  dina = 32'd0;
  dinb = 32'd0;
  addr = 32'd0;
  wr = 1'b0;
  slave_sel = 2'b00;
  #10 hresetn = 0;
  #10 hresetn = 1;

  // slave 1
  write(2'b00,32'd1,32'd1,32'd2);
  read(2'b00,32'd1);

  // slave 2
  write(2'b01,32'd2,32'd3,32'd4);
  read(2'b01,32'd2);

  // slave 3
  write(2'b10,32'd3,32'd5,32'd6);
  read(2'b10,32'd3);

  // slave 4
  write(2'b11,32'd4,32'd7,32'd8);
  read(2'b11,32'd4);
  // slave 4
  write(2'b11,32'd5,32'd9,32'd10);
  read(2'b11,32'd5);


end



task write(input [1:0] sel, input [31:0] address, input [31:0] a, input [31:0] b);
begin
  @(posedge hclk)
  slave_sel = sel;
  enable = 1'b1;
  addr = address;
  @(posedge hclk)
  dina = a;
  dinb = b;
  wr = 1'b1;
  @(posedge hclk)
  enable = 1'b0;
end
endtask

task read(input [1:0] sel, input [31:0] address);
begin
  @(posedge hclk)
  enable = 1'b1;
  slave_sel = sel;
  addr = address;
  @(posedge hclk)
  wr = 1'b0;
  // 3 beats for read
  @(posedge hclk)
  wr = 1'b0;
  @(posedge hclk)
  wr = 1'b0;
  @(posedge hclk)
  wr = 1'b0;
  @(posedge hclk)
  enable = 1'b0;
  //slave_sel[0] = 1'b0;
end
endtask

ahb_top dut(
  .hclk(hclk),
  .hresetn(hresetn),
  .enable(enable),
  .dina(dina),
  .dinb(dinb),
  .addr(addr),
  .wr(wr),
  .slave_sel(slave_sel),

  .dout(dout)
);

always #2 hclk <= ~hclk;

endmodule
