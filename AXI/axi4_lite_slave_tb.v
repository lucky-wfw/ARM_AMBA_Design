//--------------------------------------------------------------------------
// Module Name: axi4_lite_slave_tb
// The testbench of axi4_lite_slave
// Author: WangFW
// Created on 2020-12-17
// feature: write, strb
//--------------------------------------------------------------------------
// date: 2020-12-19
// read process
//--------------------------------------------------------------------------


`timescale 1ns/1ns

module axi4_lite_slave_tb
#(
  parameter addr_width = 3,
  parameter data_width =32,
  parameter strb_width = 4
)
();


// Global signals
reg aclk;
reg aresetn;

// write address channel
reg awvalid;
wire awready;
reg [addr_width-1:0] awaddr;
reg awprot;

// write data channel
reg wvalid;
wire wready;
reg [data_width-1:0] wdata;
reg [strb_width-1:0] wstrb;

// write response channel
wire bvalid;
reg bready;
wire [1:0] bresp;

// read address channel
reg arvalid;
wire arready;
reg [addr_width-1:0] araddr;
reg arprot;

// read data channel
wire rvalid;
reg rready;
wire [data_width-1:0] rdata;
wire [1:0] rresp;


// initialize
initial begin
  aclk = 0;
  aresetn = 1;
  awvalid = 0;
  awaddr = 0;
  awprot = 0;
  wvalid = 0;
  wdata = 0;
  wstrb = 0;
  bready = 0;
  arvalid = 0;
  araddr = 0;
  arprot = 0;
  rready = 0;
  
  #10 aresetn = 0;
  #10 aresetn = 1;

end

// write data test
initial begin
  #50 w_a_d(3'd1,32'd100,4'b1111);
  #50 w_d_a(3'd2,32'd200,4'b1111);
  #50 w_a_d(3'd3,32'h1234_5678,4'b1111);
  #50 w_a_d(3'd3,32'h9999_aaaa,4'b1010);

  #50 read(3'd1);
  #50 read(3'd4);

end


// data after address
task w_a_d(input [addr_width-1:0] address, input [data_width-1:0] data,
           input [strb_width-1:0] strb);
begin
  @(posedge aclk)
  awvalid = 1'b1;
  awaddr = address;
  wstrb = strb;
  @(posedge aclk)
  wvalid = 1'b1;
  wdata = data;
  @(posedge aclk)
  wvalid = 1'b1;
  awvalid = 1'b0;
  @(posedge aclk)
  bready = 1'b1;
  wvalid = 1'b0;
  @(posedge aclk)
  bready = 1'b0;
end
endtask

// address after data
task w_d_a(input [addr_width-1:0] address, input [data_width-1:0] data,
           input [strb_width-1:0] strb);
begin 
  @(posedge aclk)
  wvalid = 1'b1;
  wdata = data;
  wstrb = strb;
  @(posedge aclk)
  awvalid = 1'b1;
  awaddr = address;
  @(posedge aclk)
  wvalid = 1'b0;
  awvalid = 1'b1;
  @(posedge aclk)
  bready = 1'b1;
  awvalid = 1'b0;
  @(posedge aclk)
  bready = 1'b0;
end
endtask


// read process
task read(input [addr_width-1:0] address);
begin
  @(posedge aclk)
  arvalid = 1'b1;
  araddr = address;
  @(posedge aclk)
  rready = 1'b1;
  arvalid = 1'b0;
  @(posedge aclk)
  rready = 1'b0;
end
endtask


// aclk generate
always #2 aclk <= ~aclk;

// connect dut
axi4_lite_slave slave(
// global signals
.aclk(aclk),
.aresetn(aresetn),

// write address channel
.awaddr(awaddr),
.awprot(awprot),
.awvalid(awvalid),
.awready(awready),

// write data channel
.wdata(wdata),
.wstrb(wstrb),
.wvalid(wvalid),
.wready(wready),

// write response channel
.bresp(bresp),
.bvalid(bvalid),
.bready(bready),

// read address channel
.araddr(araddr),
.arprot(arprot),
.arvalid(arvalid),
.arready(arready),

// read data channel
.rdata(rdata),
.rresp(rresp),
.rvalid(rvalid),
.rready(rready)
);

endmodule

