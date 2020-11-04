//-------------------------------------------------------------
// Module Name: one_master_slave_tb
// The testbench of one_master_slave
// Author: WangFW
// Created on 2020-11-4
//-------------------------------------------------------------

`timescale 1ns/1ns

module one_master_slave_tb();

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

  write(32'd1,32'd1,32'd2);
  read(32'd1);

end



task write( input [31:0] address, input [31:0] a, input [31:0] b);
begin
  @(posedge hclk)
  slave_sel[0] = 1'b1;
  enable = 1'b1;
  addr = address;
  @(posedge hclk)
  dina = a;
  dinb = b;
  wr = 1'b1;
  @(posedge hclk)
  enable = 1'b0;
  slave_sel[0] = 1'b0;
end
endtask

task read(input [31:0] address);
begin
  @(posedge hclk)
  enable = 1'b1;
  slave_sel[0] = 1'b1;
  addr = address;
  @(posedge hclk)
  wr = 1'b0;
  // two beats for read
  @(posedge hclk)
  wr = 1'b0;
  @(posedge hclk)
  wr = 1'b0;
  @(posedge hclk)
  enable = 1'b0;
  slave_sel[0] = 1'b0;
end
endtask

one_master_slave dut(
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
