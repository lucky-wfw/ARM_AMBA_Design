//-----------------------------------------------------------
// Module Name: ahb_slave_tb
// The testbench of ahb_slave
// Author: WangFW
//-----------------------------------------------------------
// Date: 2020-11-1
// The basic features of write and read
//-----------------------------------------------------------
// Date: 2020-11-2
// New feature: burst
//-----------------------------------------------------------

`timescale 1ns/1ns

module ahb_slave_tb();

reg hclk;
reg hresetn;
reg hsel;
reg [31:0] haddr;
reg hwrite;
reg [2:0] hsize;
reg [2:0] hburst;
reg [3:0] hprot;
reg [1:0] htrans;
reg hmastlock;
reg hready;
reg [31:0] hwdata;
wire hreadyout;
wire hresp;
wire [31:0] hrdata;


initial begin
  hclk = 0;
  hresetn = 1;
  hsel = 0;
  haddr = 32'd0;
  hwrite = 1;
  hburst = 3'b000;
  hprot = 0;
  hsize = 0;
  htrans = 0;
  hmastlock = 0;
  hready = 1;
  hwdata = 32'd0;
  
  #10 hresetn = 0;
  #10 hresetn = 1;
  

  // basic write and read
  //basic_wr();

  // Wait state write and read
  //wr_wait_state();

  // burst: incr
  //burst_incr_wr();

  // burst wrap 4
  //burst_wrap4(32'd1);

  // burst incr 4
  burst_incr4();


end

//----------------------------------------------------
// Normal write and read
//----------------------------------------------------
task write(input [31:0] addr, input [31:0] data);
begin
  @(posedge hclk)
  hsel = 1;
  haddr = addr;
  hwrite = 1'b1;
  hwdata = data;
  hready = 1;
  @(posedge hclk)
  hsel = 0;
end
endtask

task read(input [31:0] addr);
begin
  @(posedge hclk)
  hsel = 1;
  haddr = addr;
  hwrite = 1'b0;
  hready = 1;
  @(posedge hclk)
  hsel = 0;
end
endtask


//----------------------------------------------------
// Burst
//----------------------------------------------------

// Incr
task burst_incr_wr();
begin
  hburst = 3'b001;
  write(32'd1,32'd1);
  write(32'd1,32'd2);
  write(32'd1,32'd3);
  write(32'd1,32'd4);
  hburst = 3'b000;
  @(posedge hclk)
  hburst = 3'b001;
  read(32'd1);
  read(32'd1);
  read(32'd1);
  read(32'd1);
  hburst = 3'b000;
end
endtask


//Wrap 4
task burst_wrap4(input [31:0] addr);
begin
  // write
  @(posedge hclk)
  hburst = 3'b010;
  hsel = 1'b1;
  hwrite = 1'b1;
  haddr = addr;
  hready = 1'b1;
  @(posedge hclk)
  hwdata = 32'd1;
  @(posedge hclk)
  hwdata = 32'd2;
  @(posedge hclk)
  hwdata = 32'd3;
  @(posedge hclk)
  hwdata = 32'd4;
  @(posedge hclk)
  hwdata = 32'd5;
  @(posedge hclk)
  hwdata = 32'd6;
  @(posedge hclk)
  hsel = 1'b0;
  hwrite = 1'b0;
  hburst = 3'b000;
  
  // read
  @(posedge hclk)
  hburst = 3'b010;
  hsel = 1'b1;
  hwrite = 1'b0;
  haddr = addr;
  hready = 1'b1;
  @(posedge hclk)
  hsel = 1'b0;
  @(posedge hclk)
  hsel = 1'b1;
  @(posedge hclk)
  hsel = 1'b0;
  @(posedge hclk)
  hsel = 1'b1;
  @(posedge hclk)
  hsel = 1'b0;
  @(posedge hclk)
  hsel = 1'b1;
  @(posedge hclk)
  hsel = 1'b0;
  @(posedge hclk)
  hsel = 1'b1;
  @(posedge hclk)
  hsel = 1'b0;
  @(posedge hclk)
  hsel = 1'b1;
  @(posedge hclk)
  hsel = 1'b0;
  @(posedge hclk)
  hsel = 1'b1;
  @(posedge hclk)
  hsel = 1'b0;
  hburst = 3'b000;
end
endtask

// Incr 4
task burst_incr4();
begin
  // write
  @(posedge hclk)
  hburst = 3'b011;
  hsel = 1'b1;
  hwrite = 1'b1;
  haddr = 32'd1;
  hready = 1'b1;
  @(posedge hclk)
  hwdata = 32'd1;
  @(posedge hclk)
  hwdata = 32'd2;
  @(posedge hclk)
  hwdata = 32'd3;
  @(posedge hclk)
  hwdata = 32'd4;
  @(posedge hclk)
  hsel = 1'b0;
  hwrite = 1'b0;
  hburst = 3'b000;
  
  // read
  @(posedge hclk)
  hburst = 3'b011;
  hsel = 1'b1;
  hwrite = 1'b0;
  haddr = 32'd1;
  hready = 1'b1;
  @(posedge hclk)
  hsel = 1'b0;
  @(posedge hclk)
  hsel = 1'b1;
  @(posedge hclk)
  hsel = 1'b0;
  @(posedge hclk)
  hsel = 1'b1;
  @(posedge hclk)
  hsel = 1'b0;
  @(posedge hclk)
  hsel = 1'b1;
  @(posedge hclk)
  hsel = 1'b0;
  @(posedge hclk)
  hsel = 1'b1;
  @(posedge hclk)
  hsel = 1'b0;
  hburst = 3'b000;
end
endtask


//----------------------------------------------------
// Basic
//----------------------------------------------------
task basic_wr();
begin
  hburst = 3'b000;
  write(32'd0,32'd100);
  read(32'd0);
  write(32'd1,32'd1);
  read(32'd1);
  write(32'd2,32'd2);
  read(32'd2);
  write(32'd3,32'd3);
  read(32'd3);
  write(32'd4,32'd4);
  write(32'd5,32'd5);
  write(32'd6,32'd6);
  read(32'd4);
  read(32'd5);
  read(32'd6);
end
endtask

task wr_wait_state();
begin
  hburst = 3'b000;
  write_wait_state(32'd7,32'd7);
  read_wait_state(32'd7);
  write_wait_state(32'd8,32'd8);
  read_wait_state(32'd8);
  read_wait_state(32'd7);
end
endtask



task write_wait_state(input [31:0] addr, input [31:0] data);
begin
  @(posedge hclk)
  hsel = 1;
  haddr = addr;
  hwrite = 1'b1;
  hwdata = data;
  hready = 0;
  @(posedge hclk)
  hready = 0;
  @(posedge hclk)
  hready = 1;
  @(posedge hclk)
  hsel = 0;
end
endtask

task read_wait_state(input [31:0] addr);
begin
  @(posedge hclk)
  hsel = 1;
  haddr = addr;
  hwrite = 1'b0;
  hready = 0;
  @(posedge hclk)
  hready = 0;
  @(posedge hclk)
  hready = 1;
  @(posedge hclk)
  hsel = 0;
end
endtask

always #2 hclk <= ~hclk;

ahb_slave slave1(
  .hclk(hclk),
  .hresetn(hresetn),
  .hsel(hsel),
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

