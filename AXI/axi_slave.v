//----------------------------------------------------------------
// Module Name: axi_slave
// The slave module based on axi protocol
// Author: WangFW
// Created on 2020-11-20
// Basic features mainly about write and read
//----------------------------------------------------------------
// Date: 2020-11-21
// New features: the read process, resp mangament
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
  output awready,
  
  // write data channel
  input wid,
  input [data_width-1:0] wdata,
  input [strb-1:0] wstrb,
  input wlast,
  input wuser,
  input wvalid,
  output wready,

  // write response channel
  output reg bid,
  output reg [resp-1:0] bresp,
  output reg buser,
  output bvalid,
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
  output arready,

  // read data channel
  output reg rid,
  output reg [data_width-1:0] rdata,
  output reg [resp-1:0] rresp,
  output reg rlast,
  output reg ruser,
  output rvalid,
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
// The definition of state machine for write process
//-----------------------------------------------------------
reg [2:0] wstate;
reg [2:0] wnext_state;

parameter w_idle = 3'b000, w_s1 = 3'b001, w_s2 = 3'b010, w_s3 = 3'b011,
w_s4 = 3'b100, w_s5 = 3'b101, w_s6 = 3'b110, w_s7 = 3'b111;

reg [addr_width-1:0] waddr_buffer;
reg [data_width-1:0] wdata_buffer;


//-----------------------------------------------------------
// The definition of state machine for read process
//-----------------------------------------------------------
reg [1:0] rstate;
reg [1:0] rnext_state;

parameter r_idle = 2'b00, r_s1 = 2'b01, r_s2 = 2'b10;

reg [addr_width-1:0] araddr_buffer;



//-----------------------------------------------------------
// The state machine for write process
//-----------------------------------------------------------

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


//-----------------------------------------------------------
// The state machine for read process
//-----------------------------------------------------------

always @(posedge aclk, negedge aresetn) begin
  if(!aresetn) begin
    rstate <= r_idle;
  end
  else begin
    rstate <= rnext_state;
  end
end

always @(*) begin
  case(rstate)
    r_idle: begin
      if(arvalid && arready) begin
        rnext_state <= r_s1;
      end
      else begin
        rnext_state <= r_idle;
      end
    end
    r_s1: begin
      if(rvalid && rready) begin
        rnext_state <= r_s2;
      end
      else begin
        rnext_state <= r_s1;
      end
    end
    r_s2: begin
      if(arvalid && arready) begin
        rnext_state <= r_s1;
      end
      else begin
        rnext_state <= r_idle;
      end
    end
    default: begin
      rnext_state <= r_idle;
    end
  endcase
end

always @(posedge aclk, negedge aresetn) begin
  if(!aresetn) begin
    rdata <= 32'd0;
    rresp <= 2'd0;
  end
  else begin
    case(rnext_state)
      r_idle: begin
        rdata <= rdata;
        rresp <= rresp;
      end
      r_s1: begin
        araddr_buffer <= araddr;
      end
      r_s2: begin
        // read as write
        if((araddr_buffer == waddr_buffer) && (wnext_state == w_s6)) begin
          rdata <= wdata_buffer;
          rresp <= 2'b00;
        end
        // read case with the mem has content
        else if(mem_flag[araddr_buffer] == 1'b1)begin
          rdata <= mem[araddr_buffer];
          rresp <= 2'b00;
        end
        // the read mem has not been written, slave error resp
        else begin
          rdata <= 32'd0;
          rresp <= 2'b10;
        end
      end
      default: begin
        rdata <= rdata;
        rresp <= rresp;
      end
    endcase
  end
end


//-----------------------------------------------------------
// Handshake signals of slave always valid
//-----------------------------------------------------------
assign awready = 1'b1;
assign wready = 1'b1;
assign bvalid = 1'b1;
assign arready = 1'b1;
assign rvalid = 1'b1;


endmodule
