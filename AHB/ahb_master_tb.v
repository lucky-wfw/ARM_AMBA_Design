//-------------------------------------------------------------
// Module Name: ahb_master_tb
// The testbench of ahb_master
// Author: WangFW
// Created on 2020-11-3
//-------------------------------------------------------------
// Date: 2020-11-4
// Basic write and read
//-------------------------------------------------------------

`timescale 1ns/1ns

module ahb_master_tb();

reg hclk;
reg hresetn;
reg enable;
reg [31:0] dina;
reg [31:0] dinb;
reg [31:0] addr;
reg wr;
reg hreadyout;
reg hresp;
reg [31:0] hrdata;
reg [1:0] slave_sel;
  
wire [1:0] sel;
wire [31:0] haddr;
wire hwrite;
wire [2:0] hsize;
wire [2:0] hburst;
wire [3:0] hprot;
wire [1:0] htrans;
wire hmastlock;
wire hready;
wire [31:0] hwdata;
wire [31:0] dout;

initial begin
  hclk = 0;
  hresetn = 1;
  enable = 1'b0;
  dina = 32'd0;
  dinb = 32'd0;
  addr = 32'd0;
  wr = 1'b0;
  hreadyout = 1'b0;
  hresp = 1'b0;
  hrdata = 32'd0;
  slave_sel = 2'b00;
  #10 hresetn = 0;
  #10 hresetn = 1;
  

  // write
  write(2'b01, 32'd9, 32'd1, 32'd2);
  

  // read 
  read(2'b10, 32'd5);


end

task write( input [1:0] sel, input [31:0] address, input [31:0] a, input [31:0] b);
begin
  @(posedge hclk)
  slave_sel = sel;
  enable = 1'b1;
  @(posedge hclk)
  dina = a;
  dinb = b;
  addr = address;
  wr = 1'b1;
  @(posedge hclk)
  enable = 1'b0;
end
endtask

task read(input [1:0] sel, input [31:0] address);
begin
  @(posedge hclk)
  slave_sel = sel;
  enable = 1'b1;
  @(posedge hclk)
  wr = 1'b0;
  addr = address;
  @(posedge hclk)
  enable = 1'b0;
end
endtask


// clock generate
always #2 hclk <= ~hclk;

// Connect
ahb_master dut(
  .hclk(hclk),
  .hresetn(hresetn),
  .enable(enable),
  .dina(dina),
  .dinb(dinb),
  .addr(addr),
  .wr(wr),
  .hreadyout(hreadyout),
  .hresp(hresp),
  .hrdata(hrdata),
  .slave_sel(slave_sel),
  
  .sel(sel),
  .haddr(haddr),
  .hsize(hsize),
  .hwrite(hwrite),
  .hburst(hburst),
  .hprot(hprot),
  .htrans(htrans),
  .hmastlock(hmastlock),
  .hready(hready),
  .hwdata(hwdata),
  .dout(dout)
);


endmodule

