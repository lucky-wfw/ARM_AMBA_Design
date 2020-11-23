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
// Date: 2020-11-22
// New features: write burst-fixed, incr, wrap
//----------------------------------------------------------------
// Date: 2020-11-23
// New features: read burst-fixed, incr, wrap
// New features: ID
//----------------------------------------------------------------



module axi_slave
#(
  parameter id = 2'b01,
  parameter addr_width = 4,
  parameter len = 4,
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
  input [1:0] awid,
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
  input [1:0] wid,
  input [data_width-1:0] wdata,
  input [strb-1:0] wstrb,
  input wlast,
  input wuser,
  input wvalid,
  output wready,

  // write response channel
  output reg [1:0] bid,
  output reg [resp-1:0] bresp,
  output reg buser,
  output bvalid,
  input bready,

  // read address channel
  input [1:0] arid,
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
  output reg [1:0] rid,
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
reg [31:0] mem [15:0];
reg mem_flag [15:0];

//-----------------------------------------------------------
// The definition of state machine for write process
//-----------------------------------------------------------
reg [3:0] wstate;
reg [3:0] wnext_state;

parameter w_idle = 4'b0000, w_s1 = 4'b0001, w_s2 = 4'b0010, 
w_s3 = 4'b0011, w_s4 = 4'b0100, w_s5 = 4'b0101, w_s6 = 4'b0110, 
w_s7 = 4'b0111, w_s8 = 4'b1000;

reg [addr_width-1:0] waddr_buffer;
reg [data_width-1:0] wdata_buffer;

reg [len-1:0] fixed_cnt;
reg [len-1:0] incr_cnt;
reg [len-1:0] wrap_cnt;

//-----------------------------------------------------------
// The definition of state machine for read process
//-----------------------------------------------------------
reg [1:0] rstate;
reg [1:0] rnext_state;

parameter r_idle = 2'b00, r_s1 = 2'b01, r_s2 = 2'b10, r_s3 = 2'b11;

reg [addr_width-1:0] araddr_buffer;

reg [len-1:0] r_fixed_cnt;
reg [len-1:0] r_incr_cnt;
reg [len-1:0] r_wrap_cnt;
//-----------------------------------------------------------
// The definition for burst type
//-----------------------------------------------------------
parameter fixed = 2'b00;
parameter incr = 2'b01;
parameter wrap = 2'b10;
parameter reserved = 2'b11;

reg [1:0] w_burst_type;

reg [len-1:0] awlen_buffer;
reg [size-1:0] awsize_buffer;

reg fixed_flag;
reg incr_flag;
reg wrap_flag;

reg [1:0] r_burst_type;

reg [len-1:0] arlen_buffer;
reg [size-1:0] arsize_buffer;

reg r_fixed_flag;
reg r_incr_flag;
reg r_wrap_flag;

//-----------------------------------------------------------
// The definition for transaction channel id
//-----------------------------------------------------------
wire id_enable_w;

wire id_enable_r;

assign id_enable_w = (awid == id) && (wid == id);

assign id_enable_r = (arid == id);

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
      if(wvalid && wready && awvalid && awready && id_enable_w) begin
        wnext_state <= w_s5;
      end
      else if(wvalid && wready && id_enable_w) begin
        wnext_state <= w_s3;
      end
      else if(awvalid && awready && id_enable_w) begin
        wnext_state <= w_s1;
      end
      else begin
        wnext_state <= w_idle;
      end
    end
    w_s1: begin
      // burst related
      case(awburst)
        fixed: w_burst_type <= fixed;
        incr: w_burst_type <= incr;
        wrap: w_burst_type <= wrap;
        default: w_burst_type <= reserved;
      endcase
      awlen_buffer <= awlen;

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
      // burst related
      case(awburst)
        fixed: w_burst_type <= fixed;
        incr: w_burst_type <= incr;
        wrap: w_burst_type <= wrap;
        default: w_burst_type <= reserved;
      endcase
      awlen_buffer <= awlen;

      wnext_state <= w_s6;
    end
    w_s5: begin
      // burst related
      case(awburst)
        fixed: w_burst_type <= fixed;
        incr: w_burst_type <= incr;
        wrap: w_burst_type <= wrap;
        default: w_burst_type <= reserved;
      endcase
      awlen_buffer <= awlen;

      wnext_state <= w_s6;
    end
    w_s6: begin
      case(w_burst_type)
        fixed: begin
          if(fixed_flag == 1'b0) begin
            wnext_state <= w_s6;
          end
          else begin
            wnext_state <= w_s7;
          end
        end
        incr: begin
          if(incr_flag == 1'b0) begin
            wnext_state <= w_s6;
          end
          else begin
            wnext_state <= w_s7;
          end
        end
        wrap: begin
          if(wrap_flag == 1'b0) begin
            wnext_state <= w_s6;
          end
          else begin
            wnext_state <= w_s7;
          end
        end
        reserved: begin
          wnext_state <= w_s7;
        end
      endcase
    end
    w_s7: begin
      if(bvalid && bready) begin
        wnext_state <= w_s8;
      end
      else begin
        wnext_state <= w_s7;
      end
    end
    w_s8: begin
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
    mem_flag[8] <= 1'b0;
    mem_flag[9] <= 1'b0;
    mem_flag[10] <= 1'b0;
    mem_flag[11] <= 1'b0;
    mem_flag[12] <= 1'b0;
    mem_flag[13] <= 1'b0;
    mem_flag[14] <= 1'b0;
    mem_flag[15] <= 1'b0;
    waddr_buffer <= 3'd0;
    wdata_buffer <= 32'd0;
    bresp <= 2'b00;
    // burst
    fixed_flag <= 1'b0;
    incr_flag <= 1'b0;
    wrap_flag <= 1'b0;
    fixed_cnt <= 4'd0;
    incr_cnt <= 4'd0;
    wrap_cnt <= 4'd0;

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
        mem_flag[8] <= mem_flag[8];
        mem_flag[9] <= mem_flag[9];
        mem_flag[10] <= mem_flag[10];
        mem_flag[11] <= mem_flag[11];
        mem_flag[12] <= mem_flag[12];
        mem_flag[13] <= mem_flag[13];
        mem_flag[14] <= mem_flag[14];
        mem_flag[15] <= mem_flag[15];
        waddr_buffer <= waddr_buffer;
        wdata_buffer <= wdata_buffer;
        bresp <= bresp;
        // burst
        fixed_flag <= 1'b0;
        incr_flag <= 1'b0;
        wrap_flag <= 1'b0;
        fixed_cnt <= 4'd0;
        incr_cnt <= 4'd0;
        wrap_cnt <= 4'd0;
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
        case(w_burst_type)
          fixed: begin
            if(fixed_cnt <= awlen_buffer) begin
              mem[waddr_buffer] <= wdata;
              mem_flag[waddr_buffer] <= 1'b1;
              fixed_flag <= 1'b0;
              fixed_cnt <= fixed_cnt + 1'b1;
            end
            else begin
              fixed_cnt <= 4'd0;
              fixed_flag <= 1'b1;
            end
          end
          incr: begin
            if(incr_cnt <= awlen_buffer) begin
              mem[waddr_buffer + incr_cnt] <= wdata;
              mem_flag[waddr_buffer + incr_cnt] <= 1'b1;
              incr_flag <= 1'b0;
              incr_cnt <= incr_cnt + 1'b1;
            end
            else begin
              incr_cnt <= 4'd0;
              incr_flag <= 1'b1;
            end
          end
          // wrap 4
          wrap: begin
            if(wrap_cnt <= awlen_buffer) begin
              if(wrap_cnt <= 3) begin
                mem[waddr_buffer + wrap_cnt] <= wdata;
                mem_flag[waddr_buffer + wrap_cnt] <= 1'b1;
                wrap_flag <= 1'b0;
                wrap_cnt <= wrap_cnt + 1'b1;
              end
              else begin
                mem[waddr_buffer + wrap_cnt - 4] <= wdata;
                mem_flag[waddr_buffer + wrap_cnt - 4] <= 1'b1;
                wrap_flag <= 1'b0;
                wrap_cnt <= wrap_cnt + 1'b1;
              end
            end
            else begin
              wrap_cnt <= 4'd0;
              wrap_flag <= 1'b1;
            end
          end
          default: begin
          end
        endcase
      end
      w_s7: begin
        fixed_flag <= 1'b0;
        incr_flag <= 1'b0;
        wrap_flag <= 1'b0;
        fixed_cnt <= 4'd0;
        incr_cnt <= 4'd0;
        wrap_cnt <= 4'd0;
      end
      w_s8: begin
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
        mem_flag[8] <= mem_flag[8];
        mem_flag[9] <= mem_flag[9];
        mem_flag[10] <= mem_flag[10];
        mem_flag[11] <= mem_flag[11];
        mem_flag[12] <= mem_flag[12];
        mem_flag[13] <= mem_flag[13];
        mem_flag[14] <= mem_flag[14];
        mem_flag[15] <= mem_flag[15];
        waddr_buffer <= waddr_buffer;
        wdata_buffer <= wdata_buffer;

        fixed_flag <= 1'b0;
        incr_flag <= 1'b0;
        wrap_flag <= 1'b0;
        fixed_cnt <= 4'd0;
        incr_cnt <= 4'd0;
        wrap_cnt <= 4'd0;
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
      if(arvalid && arready && id_enable_r) begin
        rnext_state <= r_s1;
      end
      else begin
        rnext_state <= r_idle;
      end
    end
    r_s1: begin
      // burst related
      case(arburst)
        fixed: r_burst_type <= fixed;
        incr: r_burst_type <= incr;
        wrap: r_burst_type <= wrap;
        default: r_burst_type <= reserved;
      endcase
      arlen_buffer <= arlen;

      if(rvalid && rready) begin
        rnext_state <= r_s2;
      end
      else begin
        rnext_state <= r_s1;
      end
    end
    r_s2: begin
      case(r_burst_type)
        fixed: begin
          if(r_fixed_flag == 1'b0) begin
            rnext_state <= r_s2;
          end
          else begin
            if(arvalid && arready) begin
              rnext_state <= r_s1;
            end
            else begin
              rnext_state <= r_idle;
            end
          end
        end
        incr: begin
          if(r_incr_flag == 1'b0) begin
            rnext_state <= r_s2;
          end
          else begin
            if(arvalid && arready) begin
              rnext_state <= r_s1;
            end
            else begin
              rnext_state <= r_idle;
            end
          end
        end
        wrap: begin
          if(r_wrap_flag == 1'b0) begin
            rnext_state <= r_s2;
          end
          else begin
            if(arvalid && arready) begin
              rnext_state <= r_s1;
            end
            else begin
              rnext_state <= r_idle;
            end
          end
        end
        default: begin
          if(arvalid && arready) begin
            rnext_state <= r_s1;
          end
          else begin
            rnext_state <= r_idle;
          end
        end
      endcase
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
    r_fixed_flag <= 1'b0;
    r_fixed_cnt <= 4'd0;
    r_incr_flag <= 1'b0;
    r_incr_cnt <= 4'd0;
    r_incr_flag <= 1'b0;
    r_incr_cnt <= 4'd0;
  end
  else begin
    case(rnext_state)
      r_idle: begin
        rdata <= rdata;
        rresp <= rresp;
        r_fixed_flag <= 1'b0;
        r_fixed_cnt <= 4'd0;
        r_incr_flag <= 1'b0;
        r_incr_cnt <= 4'd0;
        r_wrap_flag <= 1'b0;
        r_wrap_cnt <= 4'd0;
      end
      r_s1: begin
        araddr_buffer <= araddr;
      end
      r_s2: begin
        case(r_burst_type)
          fixed: begin
            if(r_fixed_cnt <= arlen_buffer) begin
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
              r_fixed_flag <= 1'b0;
              r_fixed_cnt <= r_fixed_cnt + 1'b1;
            end
            else begin
              r_fixed_flag <= 1'b1;
              r_fixed_cnt <= 4'd0;
            end
          end
          incr: begin
            if(r_incr_cnt <= arlen_buffer) begin
              // read as write
              if((araddr_buffer == waddr_buffer) && (wnext_state == w_s6)) begin
                rdata <= wdata_buffer;
                rresp <= 2'b00;
              end
              // read case with the mem has content
              else if(mem_flag[araddr_buffer + r_incr_cnt] == 1'b1)begin
                rdata <= mem[araddr_buffer + r_incr_cnt];
                rresp <= 2'b00;
              end
              // the read mem has not been written, slave error resp
              else begin
                rdata <= 32'd0;
                rresp <= 2'b10;
              end
              r_incr_flag <= 1'b0;
              r_incr_cnt <= r_incr_cnt + 1'b1;
            end
            else begin
              r_incr_flag <= 1'b1;
              r_incr_cnt <= 4'd0;
            end
          end
          wrap: begin
            if(r_wrap_cnt <= arlen_buffer) begin
              if(r_wrap_cnt <= 3) begin
                // read as write
                if((araddr_buffer == waddr_buffer) && (wnext_state == w_s6)) begin
                  rdata <= wdata_buffer;
                  rresp <= 2'b00;
                end
                // read case with the mem has content
                else if(mem_flag[araddr_buffer + r_wrap_cnt] == 1'b1)begin
                  rdata <= mem[araddr_buffer + r_wrap_cnt];
                  rresp <= 2'b00;
                end
                // the read mem has not been written, slave error resp
                else begin
                  rdata <= 32'd0;
                  rresp <= 2'b10;
                end
                r_wrap_flag <= 1'b0;
                r_wrap_cnt <= r_wrap_cnt + 1'b1;
              end
              else begin
                // read as write
                if((araddr_buffer == waddr_buffer) && (wnext_state == w_s6)) begin
                  rdata <= wdata_buffer;
                  rresp <= 2'b00;
                end
                // read case with the mem has content
                else if(mem_flag[araddr_buffer + r_wrap_cnt - 4] == 1'b1)begin
                  rdata <= mem[araddr_buffer + r_wrap_cnt - 4];
                  rresp <= 2'b00;
                end
                // the read mem has not been written, slave error resp
                else begin
                  rdata <= 32'd0;
                  rresp <= 2'b10;
                end
                r_wrap_flag <= 1'b0;
                r_wrap_cnt <= r_wrap_cnt + 1'b1;
              end
            end
            else begin
              r_wrap_flag <= 1'b1;
              r_wrap_cnt <= 4'd0;
            end
          end
          default: begin
          end
        endcase
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
