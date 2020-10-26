//-------------------------------------------------------------------
// Module Name: apb master
// control the data transfer to the slave device 
// Author: WangFW
// Date: 2020-10-25
//-------------------------------------------------------------------
// Date: 2020-10-26
// Error magement
//-------------------------------------------------------------------

module apb_master(
  input clk,
  input rstn,
  input [31:0] din_a,
  input [31:0] din_b,
  input in_valid,
  //output in_ready,
  input out_ready,
  // error signal
  output error,
  //output reg out_valid,
  output reg [31:0] dout
);

//---------------------------------------------------------------
// Parameters definition
//---------------------------------------------------------------

// add 
reg [31:0] sum;
reg flag;

// state machine
reg [2:0] state, next_state;
localparam IDLE = 3'b000, s1 = 3'b001, s2 = 3'b010, s3 = 3'b011,
s4 = 3'b100, s5 = 3'b101, s6 = 3'b110;

// connect wires
reg [31:0] pwdata;
reg penable;
reg pwrite;
reg [2:0] pprot;
reg psel;
reg [3:0] pstrb;
reg [6:0] paddr;
wire [31:0] prdata;
wire pready;
wire pslverr;

// some reg
reg [6:0] w_addr;
reg [6:0] r_addr;

// error flag
reg w_error_flag;
reg r_error_flag;


//---------------------------------------------------------------
// Add process
//---------------------------------------------------------------

always @(posedge clk, negedge rstn) begin
  if(!rstn) begin
    flag <= 1'b0;
    sum <= 32'h0000_0000;
  end
  else begin
    if(in_valid == 1'b1) begin
      sum <= din_a + din_b;
      flag <= 1'b1;
    end
    else begin
      sum <= sum;
      flag <= 1'b0;
    end
  end
end

//---------------------------------------------------------------
// APB state machine
//---------------------------------------------------------------

always @(posedge clk, negedge rstn) begin
  if(!rstn) begin
    state <= IDLE;
  end
  else begin
    state <= next_state;
  end
end


always @(*) begin
  case(state)
    IDLE: begin
      if(flag == 1'b1) begin
        next_state = s1;
      end
      else if(out_ready == 1'b1) begin
        next_state = s4;
      end
      else begin
        next_state = IDLE;
      end
    end
    s1: begin
      next_state = s2;
    end
    s2: begin
      // error magament
      if(pslverr == 1'b0) begin
        next_state = s3;
        w_error_flag = 1'b0;
      end
      else begin
        next_state = IDLE;
        w_error_flag = 1'b1;
      end
    end
    s3: begin
      next_state = IDLE;
    end
    s4: begin
      next_state = s5;
    end
    s5: begin
      // error magament
      if(pslverr == 1'b0) begin
        next_state = s6;
        r_error_flag = 1'b0;
      end
      else begin
        next_state = IDLE;
        r_error_flag = 1'b1;
      end
    end
    s6: begin
      next_state = IDLE;
    end
    default: begin
      next_state = IDLE;
    end
  endcase
end


always @(posedge clk, negedge rstn) begin
  if(!rstn) begin
    pwdata <= 32'h0000_0000;
    penable <= 1'b0;
    pwrite <= 1'b0;
    pprot <= 3'b000;
    psel <= 1'b0;
    pstrb <= 4'b1111;
    paddr <= 7'b0000000;
    // address cnt
    w_addr <= 7'd0;
    r_addr <= 7'd0;
    // data out
    dout <= 32'h0000_0000;
  end
  else begin
    case(next_state)
      s1: begin
        paddr <= w_addr;
        pwrite <= 1'b1;
        pwdata <= sum;
        psel <= 1'b1;
        penable <= 1'b0;
      end
      s2: begin
        paddr <= w_addr;
        pwrite <= 1'b1;
        pwdata <= sum;
        psel <= 1'b1;
        penable <= 1'b1;
      end
      s3: begin
        paddr <= w_addr;
        pwrite <= 1'b1;
        pwdata <= sum;
        psel <= 1'b0;
        penable <= 1'b0;
        // write address plus
        w_addr <= w_addr + 1'b1;
      end
      s4: begin
        paddr <= r_addr;
        pwrite <= 1'b0;
        dout <= prdata;
        psel <= 1'b1;
        penable <= 1'b0;
      end
      s5: begin
        paddr <= r_addr;
        pwrite <= 1'b0;
        dout <= prdata;
        psel <= 1'b1;
        penable <= 1'b1;
      end
      s6: begin
        paddr <= r_addr;
        pwrite <= 1'b0;
        dout <= prdata;
        psel <= 1'b0;
        penable <= 1'b0;
        // read address plus
        r_addr <= r_addr + 1'b1;
      end
      default: begin
        paddr <= 32'h0000_0000;
        pwrite <= 1'b0;
        dout <= dout;
        psel <= 1'b0;
        penable <= 1'b0;
        if(w_error_flag == 1'b1) begin
          w_addr <= 7'd0;
        end
        else begin
          w_addr <= w_addr;
        end
        if(r_error_flag == 1'b1) begin
          r_addr <= 7'd0;
        end
        else begin
          r_addr <= r_addr;
        end
      end
    endcase
  end
end


//Error signal from slave

assign error = pslverr;

//----------------------------------------------------
// The slave device which connect into the apb bus
//----------------------------------------------------


apb_slave1 slave1(
  .pclk(clk),
  .presetn(rstn),
  .pwdata(pwdata),
  .penable(penable),
  .pwrite(pwrite),
  .pprot(pprot),
  // The select siganl
  .psel(psel),  
  .pstrb(pstrb),
  .paddr(paddr),
  .prdata(prdata),
  .pready(pready),
  .pslverr(pslverr)
);


endmodule

