//---------------------------------------------------------------------
// Module Name: one_master_slave
// One master to one slave based on AHB protocol
// Author: WangFW
// Created on 2020-11-4
//---------------------------------------------------------------------

module one_master_slave(
  input hclk,
  input hresetn,
  input enable,
  input [31:0] dina,
  input [31:0] dinb,
  input [31:0] addr,
  input wr,
  input [1:0] slave_sel,

  output [31:0] dout
);

//--------------------------------------------------
// Connect wires
//--------------------------------------------------


wire [1:0] sel;
wire [31:0] haddr;
wire hwrite;
wire [3:0] hprot;
wire [2:0] hsize;
wire [2:0] hburst;
wire [1:0] htrans;
wire hmastlock;
wire hready;
wire [31:0] hwdata;

wire [31:0] hrdata;
wire hreadyout;
wire hresp;



//--------------------------------------------------
// AHB Master
//--------------------------------------------------

ahb_master master(
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

//--------------------------------------------------
// AHB Slave
//--------------------------------------------------
ahb_slave slave1(
  .hclk(hclk),
  .hresetn(hresetn),
  .hsel(sel[0]),
  .haddr(haddr),
  .hwrite(hwrite),
  .hsize(hsize),
  .hburst(hburst),
  .hprot(hprot),
  .htrans(htrans),
  .hmastlock(hmastlock),
  .hready(hready),
  .hwdata(hwdata),
  .hreadyout(hreadyout),
  .hresp(hresp),
  .hrdata(hrdata)
);


endmodule



