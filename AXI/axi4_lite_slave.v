//--------------------------------------------------------------------------
// Module Name: axi4_lite_slave
// The slave module based on axi 4 lite protocal
// Author: WangFW
// Created on 2020-12-16
//--------------------------------------------------------------------------
// date: 2020-12-17
// write process, wstrb feature
//--------------------------------------------------------------------------
// date: 2020-12-19
// read process
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
  output arready,
  input [addr_width-1:0] araddr,
  input arprot,

  // Read data channel
  output rvalid,
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

//---------------------------------------------------
// The definition of state machine for read process
//---------------------------------------------------
reg [1:0] r_state;
reg [1:0] r_next_state;

parameter r_idle = 2'b00, r_s1 = 2'b01, r_s2 = 2'b10;

reg [addr_width-1:0] r_addr_buff;


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
        case(wstrb)
          4'b0000: begin
            mem[w_addr_buff] <= mem[w_addr_buff];
            mem_flag[w_addr_buff] <= 1'b1;
          end
          4'b0001: begin
            mem[w_addr_buff][7:0] <= w_data_buff[7:0];
            mem[w_addr_buff][15:8] <= mem[w_addr_buff][15:8];
            mem[w_addr_buff][23:16] <= mem[w_addr_buff][23:16];
            mem[w_addr_buff][31:24] <= mem[w_addr_buff][31:24];
            mem_flag[w_addr_buff] <= 1'b1;
          end
          4'b0010: begin
            mem[w_addr_buff][7:0] <= mem[w_addr_buff][7:0];
            mem[w_addr_buff][15:8] <= w_data_buff[15:8];
            mem[w_addr_buff][23:16] <= mem[w_addr_buff][23:16];
            mem[w_addr_buff][31:24] <= mem[w_addr_buff][31:24];
            mem_flag[w_addr_buff] <= 1'b1;
          end
          4'b0011: begin
            mem[w_addr_buff][7:0] <= w_data_buff[7:0];
            mem[w_addr_buff][15:8] <= w_data_buff[15:8];
            mem[w_addr_buff][23:16] <= mem[w_addr_buff][23:16];
            mem[w_addr_buff][31:24] <= mem[w_addr_buff][31:24];
            mem_flag[w_addr_buff] <= 1'b1;
          end
          4'b0100: begin
            mem[w_addr_buff][7:0] <= mem[w_addr_buff][7:0];
            mem[w_addr_buff][15:8] <= mem[w_addr_buff][15:8];
            mem[w_addr_buff][23:16] <= w_data_buff[23:16];
            mem[w_addr_buff][31:24] <= mem[w_addr_buff][31:24];
            mem_flag[w_addr_buff] <= 1'b1;
          end
          4'b0101: begin
            mem[w_addr_buff][7:0] <= w_data_buff[7:0];
            mem[w_addr_buff][15:8] <= mem[w_addr_buff][15:8];
            mem[w_addr_buff][23:16] <= w_data_buff[23:16];
            mem[w_addr_buff][31:24] <= mem[w_addr_buff][31:24];
            mem_flag[w_addr_buff] <= 1'b1;
          end
          4'b0110: begin
            mem[w_addr_buff][7:0] <= mem[w_addr_buff][7:0];
            mem[w_addr_buff][15:8] <= w_data_buff[15:8];
            mem[w_addr_buff][23:16] <= w_data_buff[23:16];
            mem[w_addr_buff][31:24] <= mem[w_addr_buff][31:24];
            mem_flag[w_addr_buff] <= 1'b1;
          end
          4'b0111: begin
            mem[w_addr_buff][7:0] <= w_data_buff[7:0];
            mem[w_addr_buff][15:8] <= w_data_buff[15:8];
            mem[w_addr_buff][23:16] <= w_data_buff[23:16];
            mem[w_addr_buff][31:24] <= mem[w_addr_buff][31:24];
            mem_flag[w_addr_buff] <= 1'b1;
          end
          4'b1000: begin
            mem[w_addr_buff][7:0] <= mem[w_addr_buff][7:0];
            mem[w_addr_buff][15:8] <= mem[w_addr_buff][15:8];
            mem[w_addr_buff][23:16] <= mem[w_addr_buff][23:16];
            mem[w_addr_buff][31:24] <= w_data_buff[31:24];
            mem_flag[w_addr_buff] <= 1'b1;
          end
          4'b1001: begin
            mem[w_addr_buff][7:0] <= w_data_buff[7:0];
            mem[w_addr_buff][15:8] <= mem[w_addr_buff][15:8];
            mem[w_addr_buff][23:16] <= mem[w_addr_buff][23:16];
            mem[w_addr_buff][31:24] <= w_data_buff[31:24];
            mem_flag[w_addr_buff] <= 1'b1;
          end
          4'b1010: begin
            mem[w_addr_buff][7:0] <= mem[w_addr_buff][7:0];
            mem[w_addr_buff][15:8] <= w_data_buff[15:8];
            mem[w_addr_buff][23:16] <= mem[w_addr_buff][23:16];
            mem[w_addr_buff][31:24] <= w_data_buff[31:24];
            mem_flag[w_addr_buff] <= 1'b1;
          end
          4'b1011: begin
            mem[w_addr_buff][7:0] <= w_data_buff[7:0];
            mem[w_addr_buff][15:8] <= w_data_buff[15:8];
            mem[w_addr_buff][23:16] <= mem[w_addr_buff][23:16];
            mem[w_addr_buff][31:24] <= w_data_buff[31:24];
            mem_flag[w_addr_buff] <= 1'b1;
          end
          4'b1100: begin
            mem[w_addr_buff][7:0] <= mem[w_addr_buff][7:0];
            mem[w_addr_buff][15:8] <= mem[w_addr_buff][15:8];
            mem[w_addr_buff][23:16] <= w_data_buff[23:16];
            mem[w_addr_buff][31:24] <= w_data_buff[31:24];
            mem_flag[w_addr_buff] <= 1'b1;
          end
          4'b1101: begin
            mem[w_addr_buff][7:0] <= w_data_buff[7:0];
            mem[w_addr_buff][15:8] <= mem[w_addr_buff][15:8];
            mem[w_addr_buff][23:16] <= w_data_buff[23:16];
            mem[w_addr_buff][31:24] <= w_data_buff[31:24];
            mem_flag[w_addr_buff] <= 1'b1;
          end
          4'b1110: begin
            mem[w_addr_buff][7:0] <= mem[w_addr_buff][7:0];
            mem[w_addr_buff][15:8] <= w_data_buff[15:8];
            mem[w_addr_buff][23:16] <= w_data_buff[23:16];
            mem[w_addr_buff][31:24] <= w_data_buff[31:24];
            mem_flag[w_addr_buff] <= 1'b1;
          end
          4'b1111: begin
            mem[w_addr_buff][7:0] <= w_data_buff[7:0];
            mem[w_addr_buff][15:8] <= w_data_buff[15:8];
            mem[w_addr_buff][23:16] <= w_data_buff[23:16];
            mem[w_addr_buff][31:24] <= w_data_buff[31:24];
            mem_flag[w_addr_buff] <= 1'b1;
          end
        endcase
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

//----------------------------------------------------
// The read process of state machine
//----------------------------------------------------
always @(posedge aclk, negedge aresetn) begin
  if(!aresetn) begin
    r_state <= r_idle;
  end
  else begin
    r_state <= r_next_state;
  end
end


always @(*) begin
  case(r_state)
    r_idle: begin
      if((arvalid == 1'b1)&&(arready == 1'b1))begin
        r_next_state <= r_s1;
      end
      else begin
        r_next_state <= r_idle;
      end
    end
    r_s1: begin
      if((rvalid == 1'b1)&&(rready == 1'b1))begin
        r_next_state <= r_s2;
      end
      else begin
        r_next_state <= r_s1;
      end
    end
    r_s2: begin
      if((arvalid == 1'b1)&&(arready == 1'b1))begin
        r_next_state <= r_s1;
      end
      else begin
        r_next_state <= r_idle;
      end
    end
    default: begin
      r_next_state <= r_idle;
    end
  endcase
end

always @(posedge aclk, negedge aresetn) begin
  if(!aresetn) begin
    rdata <= 32'h0000_0000;
    rresp <= 2'b00;
    r_addr_buff <= 3'b000;
  end
  else begin
    case(r_next_state)
      r_idle: begin
        rdata <= rdata;
        rresp <= rresp;
        r_addr_buff <= r_addr_buff;
      end
      r_s1: begin
        r_addr_buff <= araddr;
      end
      r_s2: begin
        if((w_next_state == w_s5)&&(r_addr_buff == w_addr_buff)) begin
          rdata <= w_data_buff;
          rresp <= 2'b00;
        end
        else if(mem_flag[r_addr_buff] == 1'b1) begin
          rdata <= mem[r_addr_buff];
          rresp <= 2'b00;
        end
        else begin
          rdata <= 32'h0000_0000;
          rresp <= 2'b01;
        end
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
assign arready = 1'b1;
assign rvalid = 1'b1;


endmodule

