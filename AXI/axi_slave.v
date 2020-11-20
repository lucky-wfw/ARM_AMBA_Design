//----------------------------------------------------------------
// Module Name: axi_slave
// The slave module based on axi protocol
// Author: WangFW
// Created on 2020-11-20
// Basic features mainly about write and read
//----------------------------------------------------------------


module axi_slave
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
(
  // global signals
  input aclk,
  input aresetn,
  
  // write address channel
  input awid,
  input [addr_width-1:0] awaddr,
  input [len-1:0] awlen,
  input [size-1:0] awsize,
  input [burst_length-1:0] awburst,
  input awlock,
  input [cache-1:0] awcache,
  input [prot-1:0] awprot,
  input awqos,
  input awregion,
  input awuser,
  input awvalid,
  output reg awready,
  
  // write data channel
  input wid,
  input [data_width-1:0] wdata,
  input [strb-1:0] wstrb,
  input wlast,
  input wuser,
  input wvalid,
  output reg wready,

  // write response channel
  output reg bid,
  output reg [resp-1:0] bresp,
  output reg buser,
  output reg bvalid,
  input bready,

  // read address channel
  input arid,
  input [addr_width-1:0] araddr,
  input [len-1:0] arlen,
  input [size-1:0] arsize,
  input [burst_length-1:0] arburst,
  input arlock,
  input [cache-1:0] arcache,
  input [prot-1:0] arprot,
  input arqos,
  input arregion,
  input aruser,
  input arvalid,
  output reg arready,

  // read data channel
  output reg rid,
  output reg [data_width-1:0] rdata,
  output reg [resp-1:0] rresp,
  output reg rlast,
  output reg ruser,
  output reg rvalid,
  input rready
);

//-----------------------------------------------------------
// The definition for intern memory and flag
// flag = 0: has not been written
// flag = 1: has been written
//-----------------------------------------------------------
reg [31:0] mem [7:0];
reg mem_flag [7:0];

//-----------------------------------------------------------
// The state machine for write process
//-----------------------------------------------------------
reg [2:0] wstate;
reg [2:0] wnext_state;
parameter w_idle = 3'b000, w_s1 = 3'b001, w_s2 = 3'b010, w_s3 = 3'b011,
w_s4 = 3'b100, w_s5 = 3'b101, w_s6 = 3'b110, w_s7 = 3'b111;
reg [addr_width-1:0] waddr_buffer;
reg [data_width-1:0] wdata_buffer;

always @(posedge aclk, negedge aresetn) begin
  if(~aresetn) begin
    wstate <= w_idle;
  end
  else begin
    wstate <= wnext_state;
  end
end

always @(*) begin
  case(wstate)
    w_idle: begin
      if(wvalid && wready && awvalid && awready) begin
        wnext_state <= w_s5;
      end
      else if(wvalid && wready) begin
        wnext_state <= w_s3;
      end
      else if(awvalid && awready) begin
        wnext_state <= w_s1;
      end
      else begin
        wnext_state <= w_idle;
      end
    end
    w_s1: begin
      if(wvalid && wready) begin
        wnext_state <= w_s2;
      end
      else begin
        wnext_state <= w_s1;
      end
    end
    w_s2: begin
        wnext_state <= w_s6;
    end
    w_s3: begin
      if(awvalid && awready) begin
        wnext_state <= w_s4;
      end
      else begin
        wnext_state <= w_s3;
      end
    end
    w_s4: begin
        wnext_state <= w_s6;
    end
    w_s5: begin
        wnext_state <= w_s6;
    end
    w_s6: begin
      if(bvalid && bready) begin
        wnext_state <= w_s7;
      end
      else begin
        wnext_state <= w_s6;
      end
    end
    w_s7: begin
      if(wvalid && wready && awvalid && awready) begin
        wnext_state <= w_s5;
      end
      else if(wvalid && wready) begin
        wnext_state <= w_s3;
      end
      else if(awvalid && awready) begin
        wnext_state <= w_s1;
      end
      else begin
        wnext_state <= w_idle;
      end
    end
    default: wnext_state <= w_idle;
  endcase
end

always @(posedge aclk, negedge aresetn) begin
  if(~aresetn) begin
    mem_flag[0] <= 1'b0;
    mem_flag[1] <= 1'b0;
    mem_flag[2] <= 1'b0;
    mem_flag[3] <= 1'b0;
    mem_flag[4] <= 1'b0;
    mem_flag[5] <= 1'b0;
    mem_flag[6] <= 1'b0;
    mem_flag[7] <= 1'b0;
    waddr_buffer <= 3'd0;
    wdata_buffer <= 32'd0;
    bresp <= 2'b00;
  end
  else begin
    case(wnext_state)
      w_idle: begin
        mem_flag[0] <= mem_flag[0];
        mem_flag[1] <= mem_flag[1];
        mem_flag[2] <= mem_flag[2];
        mem_flag[3] <= mem_flag[3];
        mem_flag[4] <= mem_flag[4];
        mem_flag[5] <= mem_flag[5];
        mem_flag[6] <= mem_flag[6];
        mem_flag[7] <= mem_flag[7];
        waddr_buffer <= waddr_buffer;
        wdata_buffer <= wdata_buffer;
        bresp <= bresp;
      end
      w_s1: begin
        waddr_buffer <= awaddr;
      end
      w_s2: begin
        wdata_buffer <= wdata;
      end
      w_s3: begin
        wdata_buffer <= wdata;
      end
      w_s4: begin
        waddr_buffer <= awaddr;
      end
      w_s5: begin
        wdata_buffer <= wdata;
        waddr_buffer <= awaddr;
      end
      w_s6: begin
        mem[waddr_buffer] <= wdata_buffer;
        mem_flag[waddr_buffer] <= 1'b1;
      end
      w_s7: begin
        bresp <= 2'b00;
      end
      default: begin
        mem_flag[0] <= mem_flag[0];
        mem_flag[1] <= mem_flag[1];
        mem_flag[2] <= mem_flag[2];
        mem_flag[3] <= mem_flag[3];
        mem_flag[4] <= mem_flag[4];
        mem_flag[5] <= mem_flag[5];
        mem_flag[6] <= mem_flag[6];
        mem_flag[7] <= mem_flag[7];
        waddr_buffer <= waddr_buffer;
        wdata_buffer <= wdata_buffer;
      end
    endcase
  end
end










endmodule
