//------------------------------------------------------
// The testbench of apb_master
// Author: WangFw
// Date: 2020-10-25
//------------------------------------------------------
// Date: 2020-=10-26
// Add: error verify
// Add: more slave device
//------------------------------------------------------

`timescale 1ns/1ns

module apb_more_slave_tb();

reg clk;
reg rstn;
reg in_valid;
reg [31:0] din_a;
reg [31:0] din_b;
reg out_ready;
reg [1:0] sel;
wire error;
wire [31:0] dout;

initial begin
  clk = 0;
  rstn = 1;
  in_valid = 0;
  din_a = 32'd0;
  din_b = 32'd0;
  sel = 2'b00;
  out_ready = 0;
  #10 rstn = 0;
  #10 rstn = 1;

  // slave device0
  #10 sel = 2'b00;
  write(32'd1,32'd2);
  #50 read();
  #50 write(32'd2,32'd3);
  #50 read();
  #50 write(32'd3,32'd4);
  #50 read();
  #50 write(32'd4,32'd5);
  #50 read();
  #50 write(32'd5,32'd6);
  #50 read();

  // slave device1
  #10 sel = 2'b01;
  write(32'd1,32'd2);
  #50 read();
  #50 write(32'd2,32'd3);
  #50 read();
  #50 write(32'd3,32'd4);
  #50 read();
  #50 write(32'd4,32'd5);
  #50 read();
  #50 write(32'd5,32'd6);
  #50 read();

  // slave device2
  #10 sel = 2'b10;
  write(32'd1,32'd2);
  #50 read();
  #50 write(32'd2,32'd3);
  #50 read();
  #50 write(32'd3,32'd4);
  #50 read();
  #50 write(32'd4,32'd5);
  #50 read();
  #50 write(32'd5,32'd6);
  #50 read();

  // slave device3
  #10 sel = 2'b11;
  write(32'd1,32'd2);
  #50 read();
  #50 write(32'd2,32'd3);
  #50 read();
  #50 write(32'd3,32'd4);
  #50 read();
  #50 write(32'd4,32'd5);
  #50 read();
  #50 write(32'd5,32'd6);
  #50 read();
 
end

always #2 clk <= ~clk;

apb_more_slave master(
  .clk(clk),
  .rstn(rstn),
  .sel(sel),
  .in_valid(in_valid),
  .din_a(din_a),
  .din_b(din_b),
  .out_ready(out_ready),
  .dout(dout),
  .error(error)
);

task write(input [31:0] a, input [31:0] b);
begin
  din_a = a;
  din_b = b;
  in_valid = 1'b1;
  #10 in_valid = 1'b0;
end
endtask

task read();
begin
  out_ready = 1'b1;
  #10 out_ready = 1'b0;
end
endtask




endmodule
