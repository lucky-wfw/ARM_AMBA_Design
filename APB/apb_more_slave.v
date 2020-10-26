
//-------------------------------------------------------------------
// Module Name: apb_more_slave
// control the data transfer to the slave device 
// Author: WangFW
// Date: 2020-10-25
//-------------------------------------------------------------------
// Date: 2020-10-26
// Error magement
// add more slave device
//-------------------------------------------------------------------

module apb_more_slave(
  input clk,
  input rstn,
  input [31:0] din_a,
  input [31:0] din_b,
  input in_valid,
  input out_ready,
  input [1:0] sel,
  // error signal
  output reg error,
  output reg [31:0] dout
);

//---------------------------------------------------------------
// Parameters definition
//---------------------------------------------------------------
// slave 0
reg [31:0] din_a_0;
reg [31:0] din_b_0;
reg in_valid_0;
reg out_ready_0;
wire error_0;
wire [31:0] dout_0;
//slave 1
reg [31:0] din_a_1;
reg [31:0] din_b_1;
reg in_valid_1;
reg out_ready_1;
wire error_1;
wire [31:0] dout_1;
//slave 2
reg [31:0] din_a_2;
reg [31:0] din_b_2;
reg in_valid_2;
reg out_ready_2;
wire error_2;
wire[31:0] dout_2;
//slave 3
reg [31:0] din_a_3;
reg [31:0] din_b_3;
reg in_valid_3;
reg out_ready_3;
wire error_3;
wire [31:0] dout_3;


//---------------------------------------------------------------
// slave devices select according to sel signals
//---------------------------------------------------------------

always @(posedge clk, negedge rstn) begin
  if(!rstn) begin
    // slave 0
    din_a_0 <= 32'h0000_0000;
    din_b_0 <= 32'h0000_0000;
    in_valid_0 <= 1'b0;
    out_ready_0 <= 1'b0;
    // slave 1
    din_a_1 <= 32'h0000_0000;
    din_b_1 <= 32'h0000_0000;
    in_valid_1 <= 1'b0;
    out_ready_1 <= 1'b0;
    // slave 2
    din_a_2 <= 32'h0000_0000;
    din_b_2 <= 32'h0000_0000;
    in_valid_2 <= 1'b0;
    out_ready_2 <= 1'b0;
    // slave 3
    din_a_3 <= 32'h0000_0000;
    din_b_3 <= 32'h0000_0000;
    in_valid_3 <= 1'b0;
    out_ready_3 <= 1'b0;
    // sys output
    dout <= 32'h0000_0000;
    error <= 1'b0;
  end
  else begin
    case(sel)
      2'b00: begin
        // slave 0
        din_a_0 <= din_a;
        din_b_0 <= din_b;
        in_valid_0 <= in_valid;
        out_ready_0 <= out_ready;
        // slave 1
        din_a_1 <= 32'h0000_0000;
        din_b_1 <= 32'h0000_0000;
        in_valid_1 <= 1'b0;
        out_ready_1 <= 1'b0;
        // slave 2
        din_a_2 <= 32'h0000_0000;
        din_b_2 <= 32'h0000_0000;
        in_valid_2 <= 1'b0;
        out_ready_2 <= 1'b0;
        // slave 3
        din_a_3 <= 32'h0000_0000;
        din_b_3 <= 32'h0000_0000;
        in_valid_3 <= 1'b0;
        out_ready_3 <= 1'b0;
        // sys output
        dout <= dout_0;
        error <= error_0;
      end
      2'b01: begin
        // slave 0
        din_a_0 <= 32'h0000_0000;
        din_b_0 <= 32'h0000_0000;
        in_valid_0 <= 1'b0;
        out_ready_0 <= 1'b0;
        // slave 1
        din_a_1 <= din_a;
        din_b_1 <= din_b;
        in_valid_1 <= in_valid;
        out_ready_1 <= out_ready;
        // slave 2
        din_a_2 <= 32'h0000_0000;
        din_b_2 <= 32'h0000_0000;
        in_valid_2 <= 1'b0;
        out_ready_2 <= 1'b0;
        // slave 3
        din_a_3 <= 32'h0000_0000;
        din_b_3 <= 32'h0000_0000;
        in_valid_3 <= 1'b0;
        out_ready_3 <= 1'b0;
        // sys output
        dout <= dout_1;
        error <= error_1;
      end
      2'b10: begin
        // slave 0
        din_a_0 <= 32'h0000_0000;
        din_b_0 <= 32'h0000_0000;
        in_valid_0 <= 1'b0;
        out_ready_0 <= 1'b0;
        // slave 1
        din_a_1 <= 32'h0000_0000;
        din_b_1 <= 32'h0000_0000;
        in_valid_1 <= 1'b0;
        out_ready_1 <= 1'b0;
        // slave 2
        din_a_2 <= din_a;
        din_b_2 <= din_b;
        in_valid_2 <= in_valid;
        out_ready_2 <= out_ready;
        // slave 3
        din_a_3 <= 32'h0000_0000;
        din_b_3 <= 32'h0000_0000;
        in_valid_3 <= 1'b0;
        out_ready_3 <= 1'b0;
        // sys output
        dout <= dout_2;
        error <= error_2;
      end
      2'b11: begin
        // slave 0
        din_a_0 <= 32'h0000_0000;
        din_b_0 <= 32'h0000_0000;
        in_valid_0 <= 1'b0;
        out_ready_0 <= 1'b0;
        // slave 1
        din_a_1 <= 32'h0000_0000;
        din_b_1 <= 32'h0000_0000;
        in_valid_1 <= 1'b0;
        out_ready_1 <= 1'b0;
        // slave 2
        din_a_2 <= 32'h0000_0000;
        din_b_2 <= 32'h0000_0000;
        in_valid_2 <= 1'b0;
        out_ready_2 <= 1'b0;
        // slave 3
        din_a_3 <= din_a;
        din_b_3 <= din_b;
        in_valid_3 <= in_valid;
        out_ready_3 <= out_ready;
        // sys output
        dout <= dout_3;
        error <= error_3;
      end
      default: begin
        // slave 0
        din_a_0 <= 32'h0000_0000;
        din_b_0 <= 32'h0000_0000;
        in_valid_0 <= 1'b0;
        out_ready_0 <= 1'b0;
        // slave 1
        din_a_1 <= 32'h0000_0000;
        din_b_1 <= 32'h0000_0000;
        in_valid_1 <= 1'b0;
        out_ready_1 <= 1'b0;
        // slave 2
        din_a_2 <= 32'h0000_0000;
        din_b_2 <= 32'h0000_0000;
        in_valid_2 <= 1'b0;
        out_ready_2 <= 1'b0;
        // slave 3
        din_a_3 <= 32'h0000_0000;
        din_b_3 <= 32'h0000_0000;
        in_valid_3 <= 1'b0;
        out_ready_3 <= 1'b0;
        // sys output
        dout <= 32'h0000_0000;
        error <= 1'b0;
      end
    endcase
  end
end

//---------------------------------------------------------------
// four slave devices 
//---------------------------------------------------------------


apb_master slave0(
  .clk(clk),
  .rstn(rstn),
  .in_valid(in_valid_0),
  .din_a(din_a_0),
  .din_b(din_b_0),
  .out_ready(out_ready_0),
  .dout(dout_0),
  .error(error_0)
);

apb_master slave1(
  .clk(clk),
  .rstn(rstn),
  .in_valid(in_valid_1),
  .din_a(din_a_1),
  .din_b(din_b_1),
  .out_ready(out_ready_1),
  .dout(dout_1),
  .error(error_1)
);


apb_master slave2(
  .clk(clk),
  .rstn(rstn),
  .in_valid(in_valid_2),
  .din_a(din_a_2),
  .din_b(din_b_2),
  .out_ready(out_ready_2),
  .dout(dout_2),
  .error(error_2)
); 

apb_master slave3(
  .clk(clk),
  .rstn(rstn),
  .in_valid(in_valid_3),
  .din_a(din_a_3),
  .din_b(din_b_3),
  .out_ready(out_ready_3),
  .dout(dout_3),
  .error(error_3)
);
    



endmodule
