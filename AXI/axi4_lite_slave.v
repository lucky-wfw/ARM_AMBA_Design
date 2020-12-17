//--------------------------------------------------------------------------
// Module Name: axi4_lite_slave
// The slave module based on axi 4 lite protocal
// Author: WangFW
// Created on 2020-12-16
//--------------------------------------------------------------------------
// date: 2020-12-17
// write process
//--------------------------------------------------------------------------

module axi4_lite_slave
#(
  parameter addr_width = 3,
  parameter data_width =32,
  parameter strb_width = 4
)
(
  // Global signals
  input aclk,
  input aresetn,

  // Write address channel
  input awvalid,
  output awready,
  input [addr_width-1:0] awaddr,
  input awprot,

  // Write data channel
  input wvalid,
  output wready,
  input [data_width-1:0] wdata,
  input [strb_width-1:0] wstrb,

  // Write response channel
  output bvalid,
  input bready,
  output reg [1:0] bresp,

  // Read address channel
  input arvalid,
  output reg arready,
  input [addr_width-1:0] araddr,
  input arprot,

  // Read data channel
  output reg rvalid,
  input rready,
  output reg [data_width-1:0] rdata,
  output reg [1:0] rresp
);

//----------------------------------------------------
// The intern memory for write and read data
//----------------------------------------------------
reg [data_width-1:0] mem [7:0];
reg mem_flag [7:0];

//----------------------------------------------------
// The definitions of state machine for write data
//----------------------------------------------------
reg [2:0] w_state;
reg [2:0] w_next_state;
parameter w_idle = 3'b000, w_s1 = 3'b001, w_s2 = 3'b010, 
w_s3 = 3'b011, w_s4 = 3'b100, w_s5 = 3'b101, w_s6 = 3'b110;

reg [data_width-1:0] w_data_buff;
reg [addr_width-1:0] w_addr_buff;




//----------------------------------------------------
// The write process of state machine
//----------------------------------------------------

always @(posedge aclk, negedge aresetn) begin
  if(!aresetn) begin
    w_state <= w_idle;
  end
  else begin
    w_state <= w_next_state;
  end
end

always @(*) begin
  case(w_state)
    w_idle: begin
      if((awvalid == 1'b1)&&(awready == 1'b1)) begin
        w_next_state <= w_s1;
      end
      else if((wvalid == 1'b1)&&(wready == 1'b1)) begin
        w_next_state <= w_s3;
      end
      else begin
        w_next_state <= w_idle;
      end
    end
    w_s1: begin
      if((wvalid == 1'b1)&&(wready == 1'b1)) begin
        w_next_state <= w_s2;
      end
      else begin
        w_next_state <= w_s1;
      end
    end
    w_s2: begin
      w_next_state <= w_s5;
    end
    w_s3: begin
      if((awvalid == 1'b1)&&(awready == 1'b1)) begin
        w_next_state <= w_s4;
      end
      else begin
        w_next_state <= w_s3;
      end
    end
    w_s4: begin
      w_next_state <= w_s5;
    end
    w_s5: begin
      if((bvalid == 1'b1)&&(bready == 1'b1)) begin
        w_next_state <= w_s6;
      end
      else begin
        w_next_state <= w_s5;
      end
    end
    w_s6: begin
      if((awvalid == 1'b1)&&(awready == 1'b1)) begin
        w_next_state <= w_s1;
      end
      else if((wvalid == 1'b1)&&(wready == 1'b1)) begin
        w_next_state <= w_s3;
      end
      else begin
        w_next_state <= w_idle;
      end
    end
    default: begin
      w_next_state <= w_idle;
    end
  endcase
end

always @(posedge aclk, negedge aresetn) begin
  if(!aresetn) begin
    mem[0] <= 32'h0000;
    mem[1] <= 32'h0000;
    mem[2] <= 32'h0000;
    mem[3] <= 32'h0000;
    mem[4] <= 32'h0000;
    mem[5] <= 32'h0000;
    mem[6] <= 32'h0000;
    mem[7] <= 32'h0000;
    mem_flag[0] <= 1'b0;
    mem_flag[1] <= 1'b0;
    mem_flag[2] <= 1'b0;
    mem_flag[3] <= 1'b0;
    mem_flag[4] <= 1'b0;
    mem_flag[5] <= 1'b0;
    mem_flag[6] <= 1'b0;
    mem_flag[7] <= 1'b0;
    w_data_buff <= 32'h0000;
    w_addr_buff <= 3'b000;
    bresp <= 2'b00;
  end
  else begin
    case(w_next_state)
      w_idle: begin
        w_data_buff <= w_data_buff;
        w_addr_buff <= w_addr_buff;
      end
      w_s1: begin
        w_addr_buff <= awaddr;
      end
      w_s2: begin
        w_data_buff <= wdata;
      end
      w_s3: begin
        w_data_buff <= wdata;
      end
      w_s4: begin
        w_addr_buff <= awaddr;
      end
      w_s5: begin
        mem[w_addr_buff] <= w_data_buff;
        mem_flag[w_addr_buff] <= 1'b1;
      end
      w_s6: begin
        bresp <= 2'b00;
      end
      default: begin
        w_data_buff <= w_data_buff;
        w_addr_buff <= w_addr_buff;
        bresp <= 2'b10;
      end
    endcase
  end
end







//-----------------------------------------------------------
// five channels's output valid/ready signals always valid
//-----------------------------------------------------------

assign awready = 1'b1;
assign wready = 1'b1;
assign bvalid = 1'b1;




endmodule

