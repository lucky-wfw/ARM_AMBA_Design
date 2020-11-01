//-------------------------------------------------------------------------
// Module Name: ahb_slave
// The Slave module of AHB Protocol
// Author: WangFW
//-------------------------------------------------------------------------
// Date: 2020-11-1
// Basic features about read and write
// Date: 2020-11-1
// New features: wait state
//-------------------------------------------------------------------------

module ahn_slave(
  input hclk,
  input hresetn,
  input hsel,
  input [31:0] haddr,
  input hwrite,
  input [2:0] hsize,
  input [2:0] hburst,
  input [3:0] hprot,
  input [1:0] htrans,
  input hmastlock,
  input hready,
  input [31:0] hwdata,
  output reg hreadyout,
  output reg hresp,
  output reg [31:0] hrdata
);

//----------------------------------------------------------------------
// The definitions for intern registers for data storge
//----------------------------------------------------------------------
reg [31:0] mem [31:0];
reg [4:0] waddr;
reg [4:0] raddr;

//----------------------------------------------------------------------
// The definition for state machine
//----------------------------------------------------------------------
reg [1:0] state;
reg [1:0] next_state;
localparam idle = 2'b00,s1 = 2'b01,s2 = 2'b10,s3 = 2'b11;


//----------------------------------------------------------------------
// The state machine
//----------------------------------------------------------------------

always @(posedge hclk, negedge hresetn) begin
  if(!hresetn) begin
    state <= idle;
  end
  else begin
    state <= next_state;
  end
end

always @(*) begin
  case(state)
    idle: begin
      if(hsel == 1'b1) begin
        next_state = s1;
      end
      else begin
        next_state = idle;
      end
    end
    s1: begin
      if((hwrite == 1'b1) && (hready == 1'b1)) begin
        next_state = s2;
      end
      else if((hwrite == 1'b0) && (hready == 1'b1)) begin
        next_state = s3;
      end
      else begin
        next_state = s1;
      end
    end
    s2: begin
      if(hsel == 1'b1) begin
        next_state = s1;
      end
      else begin
        next_state = idle;
      end
    end
    s3: begin
      if(hsel == 1'b1) begin
        next_state = s1;
      end
      else begin
        next_state = idle;
      end
    end
    default: begin
      next_state = idle;
    end
  endcase
end

always @(posedge hclk, negedge hresetn) begin
  if(!hresetn) begin
    hreadyout <= 1'b0;
    hresp <= 1'b0;
    hrdata <= 32'h0000_0000;
    waddr <= 5'b0000_0;
    raddr <= 5'b0000_0;
  end
  else begin
    case(next_state)
      idle: begin
        hreadyout <= 1'b0;
        hresp <= 1'b0;
        hrdata <= hrdata;
        waddr <= waddr;
        raddr <= raddr;
      end
      s1: begin
        hreadyout <= 1'b0;
        hresp <= 1'b0;
        hrdata <= hrdata;
        waddr <= waddr;
        raddr <= raddr;
      end
      s2: begin
        hreadyout <= 1'b1;
        hresp <= 1'b0;
        mem[haddr] <= hwdata;
        waddr <= haddr;
        raddr <= raddr;
      end
      s3: begin
        hreadyout <= 1'b1;
        hresp <= 1'b0;
        hrdata <= mem[haddr];
        raddr <= haddr;
        waddr <= waddr;
      end
      default: begin
        hreadyout <= 1'b0;
        hresp <= 1'b0;
        hrdata <= hrdata;
        waddr <= waddr;
        raddr <= raddr;
      end
    endcase
  end
end


endmodule
