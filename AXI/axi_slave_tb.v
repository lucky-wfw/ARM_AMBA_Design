//--------------------------------------------------------------------------
// Module Name: axi_slave_tb
// The testbench of axi_slave
// Author: WangFW
// Created on 2020-11-21
// Basic features verify
//--------------------------------------------------------------------------
// Date: 2020-11-22
// New Features: write_addr_data, write_data_addr, write_addr_with_data,
//               normal read, read empty memory
//--------------------------------------------------------------------------

`timescale 1ns/1ns

module axi_slave_tb
#(
  parameter addr_width = 3,
  parameter len = 8,
  parameter size = 3,
  parameter burst_length = 2,
  parameter cache = 4,
  parameter prot = 3,
  parameter data_width = 32,
  parameter strb = 4,
  parameter resp = 2
)
();

// global signals
reg aclk;
reg aresetn;
  
  // write address channel
reg awid;
reg [addr_width-1:0] awaddr;
reg [len-1:0] awlen;
reg [size-1:0] awsize;
reg [burst_length-1:0] awburst;
reg awlock;
reg [cache-1:0] awcache;
reg [prot-1:0] awprot;
reg awqos;
reg awregion;
reg awuser;
reg awvalid;
wire awready;
  
// write data channel
reg wid;
reg [data_width-1:0] wdata;
reg [strb-1:0] wstrb;
reg wlast;
reg wuser;
reg wvalid;
wire wready;

// write response channel
wire bid;
wire [resp-1:0] bresp;
wire buser;
wire bvalid;
reg bready;

// read address channel
reg arid;
reg [addr_width-1:0] araddr;
reg [len-1:0] arlen;
reg [size-1:0] arsize;
reg [burst_length-1:0] arburst;
reg arlock;
reg [cache-1:0] arcache;
reg [prot-1:0] arprot;
reg arqos;
reg arregion;
reg aruser;
reg arvalid;
wire arready;

  // read data channel
wire rid;
wire [data_width-1:0] rdata;
wire [resp-1:0] rresp;
wire rlast;
wire ruser;
wire rvalid;
reg rready;


// initialize
initial begin
  aclk = 0;
  aresetn = 1;

  awid = 0;
  awaddr = 0;
  awlen = 0;
  awsize = 0;
  awburst = 0;
  awlock = 0;
  awcache = 0;
  awprot = 0;
  awqos = 0;
  awregion = 0;
  awuser = 0;
  awvalid = 0;

  wid = 0;
  wdata = 0;
  wstrb = 0;
  wlast = 0;
  wuser = 0;
  wvalid = 0;

  bready = 0;

  arid = 0;
  araddr = 0;
  arlen = 0;
  arsize = 0;
  arburst = 0;
  arlock = 0;
  arcache = 0;
  arprot = 0;
  arqos = 0;
  arregion = 0;
  aruser = 0;
  arvalid = 0;
  
  rready = 0;


  #10 aresetn = 0;
  #10 aresetn = 1;
end

// case test
initial begin

  #10 @(posedge aclk)
  w_a_d(3'd1,32'd5);

  /*

  #10 @(posedge aclk)
  w_d_a(3'd2,32'd10);

  #10 @(posedge aclk)
  w_a_with_d(3'd3,32'd20);

  // normal read
  #10 @(posedge aclk)
  read(3'd1);

  // read empty memory
  #10 @(posedge aclk)
  read(3'd5);

  */

  fork
    // read and write the differnrt memory location
    #50 @(posedge aclk)
    w_d_a(3'd2,32'd10);

    #50 @(posedge aclk)
    read(3'd1);

   // read and write the same memory location
    #100 @(posedge aclk)
    w_d_a(3'd3,32'd20);

    #104 @(posedge aclk)
    read(3'd3);

  join

end





// data after address
task w_a_d(input [addr_width-1:0] address, input [data_width-1:0] data);
begin
  @(posedge aclk)
  awvalid = 1'b1;
  awaddr = address;
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
task w_d_a(input [addr_width-1:0] address, input [data_width-1:0] data);
begin
  @(posedge aclk)
  wvalid = 1'b1;
  wdata = data;
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

// data with address
task w_a_with_d(input [addr_width-1:0] address, input [data_width-1:0] data);
begin
  @(posedge aclk)
  awvalid = 1'b1;
  awaddr = address;
  wvalid = 1'b1;
  wdata = data;
  @(posedge aclk)
  wvalid = 1'b1;
  awvalid = 1'b1;
  @(posedge aclk)
  wvalid = 1'b0;
  awvalid = 1'b0;
  @(posedge aclk)
  bready = 1'b1;
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

// system clock generate
always #2 aclk <= ~aclk;

// connect the slave module
axi_slave dut(
// global signals
.aclk(aclk),
.aresetn(aresetn),

// write address channel
.awid(awid),
.awaddr(awaddr),
.awlen(awlen),
.awsize(awsize),
.awburst(awburst),
.awlock(awlock),
.awcache(awcache),
.awprot(awprot),
.awqos(awqos),
.awregion(awregion),
.awuser(awuser),
.awvalid(awvalid),
.awready(awready),

// write data channel
.wid(wid),
.wdata(wdata),
.wstrb(wstrb),
.wlast(wlast),
.wuser(wuser),
.wvalid(wvalid),
.wready(wready),

// write response channel
.bid(bid),
.bresp(bresp),
.buser(buser),
.bvalid(bvalid),
.bready(bready),

// read address channel
.arid(arid),
.araddr(araddr),
.arlen(arlen),
.arsize(arsize),
.arburst(arburst),
.arlock(arlock),
.arcache(arcache),
.arprot(arprot),
.arqos(arqos),
.arregion(arregion),
.aruser(aruser),
.arvalid(arvalid),
.arready(arready),

// read data channel
.rid(rid),
.rdata(rdata),
.rresp(rresp),
.rlast(rlast),
.ruser(ruser),
.rvalid(rvalid),
.rready(rready)
);


endmodule
