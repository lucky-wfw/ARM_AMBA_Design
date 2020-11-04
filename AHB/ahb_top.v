//-------------------------------------------------------------------
// Module Name: ahb_top
// The AHB system consisting of one master and four slave
// Author: WangFW
// Created on 2020-11-4
//-------------------------------------------------------------------

module ahb_top(
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

// master
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

// slave 1
wire [31:0] hrdata_1;
wire hreadyout_1;
wire hresp_1;

// slave 2
wire [31:0] hrdata_2;
wire hreadyout_2;
wire hresp_2;

// slave 3
wire [31:0] hrdata_3;
wire hreadyout_3;
wire hresp_3;

// slave 4
wire [31:0] hrdata_4;
wire hreadyout_4;
wire hresp_4;

// decoder
wire hsel_1;
wire hsel_2;
wire hsel_3;
wire hsel_4;

// multiplexor
wire [31:0] hrdata;
wire hreadyout;
wire hresp;


//--------------------------------------------------
// Connect master, slaves, decoder, multiplexor
//--------------------------------------------------

// master

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

// decoder
decoder deco(
  .sel(sel),
  .hsel_1(hsel_1),
  .hsel_2(hsel_2),
  .hsel_3(hsel_3),
  .hsel_4(hsel_4)
);

// slave 1
ahb_slave slave1(
  .hclk(hclk),
  .hresetn(hresetn),
  .hsel(hsel_1),
  .haddr(haddr),
  .hwrite(hwrite),
  .hsize(hsize),
  .hburst(hburst),
  .hprot(hprot),
  .htrans(htrans),
  .hmastlock(hmastlock),
  .hready(hready),
  .hwdata(hwdata),
  .hreadyout(hreadyout_1),
  .hresp(hresp_1),
  .hrdata(hrdata_1)
);

// slave 2
ahb_slave slave2(
  .hclk(hclk),
  .hresetn(hresetn),
  .hsel(hsel_2),
  .haddr(haddr),
  .hwrite(hwrite),
  .hsize(hsize),
  .hburst(hburst),
  .hprot(hprot),
  .htrans(htrans),
  .hmastlock(hmastlock),
  .hready(hready),
  .hwdata(hwdata),
  .hreadyout(hreadyout_2),
  .hresp(hresp_2),
  .hrdata(hrdata_2)
);


// slave 3
ahb_slave slave3(
  .hclk(hclk),
  .hresetn(hresetn),
  .hsel(hsel_3),
  .haddr(haddr),
  .hwrite(hwrite),
  .hsize(hsize),
  .hburst(hburst),
  .hprot(hprot),
  .htrans(htrans),
  .hmastlock(hmastlock),
  .hready(hready),
  .hwdata(hwdata),
  .hreadyout(hreadyout_3),
  .hresp(hresp_3),
  .hrdata(hrdata_3)
);


// slave 4
ahb_slave slave4(
  .hclk(hclk),
  .hresetn(hresetn),
  .hsel(hsel_4),
  .haddr(haddr),
  .hwrite(hwrite),
  .hsize(hsize),
  .hburst(hburst),
  .hprot(hprot),
  .htrans(htrans),
  .hmastlock(hmastlock),
  .hready(hready),
  .hwdata(hwdata),
  .hreadyout(hreadyout_4),
  .hresp(hresp_4),
  .hrdata(hrdata_4)
);

// multiplexor
multiplexor multip(
  .hrdata_1(hrdata_1),
  .hrdata_2(hrdata_2),
  .hrdata_3(hrdata_3),
  .hrdata_4(hrdata_4),
  .hreadyout_1(hreadyout_1),
  .hreadyout_2(hreadyout_2),
  .hreadyout_3(hreadyout_3),
  .hreadyout_4(hreadyout_4),
  .hresp_1(hresp_1),
  .hresp_2(hresp_2),
  .hresp_3(hresp_3),
  .hresp_4(hresp_4),
  .sel(sel),
  .hrdata(hrdata),
  .hreadyout(hreadyout),
  .hresp(hresp)
);



endmodule

