//-------------------------------------------------------------------------
// Module Name: ahb_slave
// The Slave module of AHB Protocol
// Author: WangFW
//-------------------------------------------------------------------------
// Date: 2020-11-1
// Basic features about read and write
// Date: 2020-11-1
// New features: wait state, burst
//-------------------------------------------------------------------------

module ahb_slave(
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
// The definition for burst feature
//----------------------------------------------------------------------
reg single_flag;
reg incr_flag;
reg wrap4_flag;
reg incr4_flag;
reg wrap8_flag;
reg incr8_flag;
reg wrap16_flag;
reg incr16_flag;




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
      single_flag = 1'b0;
      incr_flag = 1'b0;
      wrap4_flag = 1'b0;
      incr4_flag = 1'b0;
      wrap8_flag = 1'b0;
      incr8_flag = 1'b0;
      wrap16_flag = 1'b0;
      incr16_flag = 1'b0;
      if(hsel == 1'b1) begin
        next_state = s1;
      end
      else begin
        next_state = idle;
      end
    end
    s1: begin
      case(hburst)
        // single transfer burst
        3'b000: begin  
          single_flag = 1'b1;
          incr_flag = 1'b0;
          wrap4_flag = 1'b0;
          incr4_flag = 1'b0;
          wrap8_flag = 1'b0;
          incr8_flag = 1'b0;
          wrap16_flag = 1'b0;
          incr16_flag = 1'b0;
        end
        // incrementing burst of undefined length
        3'b001: begin  
          single_flag = 1'b0;
          incr_flag = 1'b1;
          wrap4_flag = 1'b0;
          incr4_flag = 1'b0;
          wrap8_flag = 1'b0;
          incr8_flag = 1'b0;
          wrap16_flag = 1'b0;
          incr16_flag = 1'b0;
        end
        // 4-beat wrapping burst
        3'b010: begin  
          single_flag = 1'b0;
          incr_flag = 1'b0;
          wrap4_flag = 1'b1;
          incr4_flag = 1'b0;
          wrap8_flag = 1'b0;
          incr8_flag = 1'b0;
          wrap16_flag = 1'b0;
          incr16_flag = 1'b0;
        end
        // 4-beat incrementing burst
        3'b011: begin  
          single_flag = 1'b0;
          incr_flag = 1'b0;
          wrap4_flag = 1'b0;
          incr4_flag = 1'b1;
          wrap8_flag = 1'b0;
          incr8_flag = 1'b0;
          wrap16_flag = 1'b0;
          incr16_flag = 1'b0;
        end
        // 8-beat wrapping burst
        3'b100: begin  
          single_flag = 1'b0;
          incr_flag = 1'b0;
          wrap4_flag = 1'b0;
          incr4_flag = 1'b0;
          wrap8_flag = 1'b1;
          incr8_flag = 1'b0;
          wrap16_flag = 1'b0;
          incr16_flag = 1'b0;
        end
        // 8-beat incrementing burst
        3'b101: begin  
          single_flag = 1'b0;
          incr_flag = 1'b0;
          wrap4_flag = 1'b0;
          incr4_flag = 1'b0;
          wrap8_flag = 1'b0;
          incr8_flag = 1'b1;
          wrap16_flag = 1'b0;
          incr16_flag = 1'b0;
        end
        // 16-beat wrapping burst
        3'b110: begin  
          single_flag = 1'b0;
          incr_flag = 1'b0;
          wrap4_flag = 1'b0;
          incr4_flag = 1'b0;
          wrap8_flag = 1'b0;
          incr8_flag = 1'b0;
          wrap16_flag = 1'b1;
          incr16_flag = 1'b0;
        end
        // 16-beat incrementing burst
        3'b111: begin  
          single_flag = 1'b0;
          incr_flag = 1'b0;
          wrap4_flag = 1'b0;
          incr4_flag = 1'b0;
          wrap8_flag = 1'b0;
          incr8_flag = 1'b0;
          wrap16_flag = 1'b0;
          incr16_flag = 1'b1;
        end
        // default
        default: begin  
          single_flag = 1'b0;
          incr_flag = 1'b0;
          wrap4_flag = 1'b0;
          incr4_flag = 1'b0;
          wrap8_flag = 1'b0;
          incr8_flag = 1'b0;
          wrap16_flag = 1'b0;
          incr16_flag = 1'b0;
        end
      endcase


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
      case(hburst)
        // single transfer burst
        3'b000: begin  
          if(hsel == 1'b1) begin
            next_state = s1;
          end
          else begin
            next_state = idle;
          end
        end
        // incrementing burst of undefined length
        3'b001: begin  
          next_state = s2;
        end
        // 4-beat wrapping burst
        3'b010: begin  
          next_state = s2;
        end
        // 4-beat incrementing burst
        3'b011: begin  
          next_state = s2;
        end
        // 8-beat wrapping burst
        3'b100: begin  
          next_state = s2;
        end
        // 8-beat incrementing burst
        3'b101: begin  
          next_state = s2;
        end
        // 16-beat wrapping burst
        3'b110: begin  
          next_state = s2;
        end
        // 16-beat incrementing burst
        3'b111: begin  
          next_state = s2;
        end
        // default
        default: begin  
          if(hsel == 1'b1) begin
            next_state = s1;
          end
          else begin
            next_state = idle;
          end
        end
      endcase
    end
    s3: begin
      case(hburst)
        // single transfer burst
        3'b000: begin  
          if(hsel == 1'b1) begin
            next_state = s1;
          end
          else begin
            next_state = idle;
          end
        end
        // incrementing burst of undefined length
        3'b001: begin  
          next_state = s3;
        end
        // 4-beat wrapping burst
        3'b010: begin  
          next_state = s3;
        end
        // 4-beat incrementing burst
        3'b011: begin  
          next_state = s3;
        end
        // 8-beat wrapping burst
        3'b100: begin  
          next_state = s3;
        end
        // 8-beat incrementing burst
        3'b101: begin  
          next_state = s3;
        end
        // 16-beat wrapping burst
        3'b110: begin  
          next_state = s3;
        end
        // 16-beat incrementing burst
        3'b111: begin  
          next_state = s3;
        end
        // default
        default: begin  
          if(hsel == 1'b1) begin
            next_state = s1;
          end
          else begin
            next_state = idle;
          end
        end
      endcase
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
        waddr <= haddr;
        raddr <= haddr;
      end
      s2: begin
        case({single_flag,incr_flag,wrap4_flag,incr4_flag,wrap8_flag,incr8_flag,wrap16_flag,incr16_flag})
          // single transfer
          8'b1000_0000: begin
            hreadyout <= 1'b1;
            hresp <= 1'b0;
            mem[waddr] <= hwdata;
          end
          // incre
          8'b0100_0000: begin
            hreadyout <= 1'b1;
            hresp <= 1'b0;
            mem[waddr] <= hwdata;
            waddr <= waddr + 1'b1;
          end
          // wrap 4
          8'b0010_0000: begin
            hreadyout <= 1'b1;
            hresp <= 1'b0;
            if(waddr < (haddr + 2'd3)) begin
              mem[waddr] <= hwdata;
              waddr <= waddr + 1'b1;
            end
            else begin
              mem[waddr] <= hwdata;
              waddr <= haddr;
            end
          end
          // incre 4
          8'b0001_0000: begin
            hreadyout <= 1'b1;
            hresp <= 1'b0;
            mem[waddr] <= hwdata;
            waddr <= waddr + 1'b1;
          end
          // wrap 8
          8'b0000_1000: begin
            hreadyout <= 1'b1;
            hresp <= 1'b0;
            if(waddr < (haddr + 3'd7)) begin
              mem[waddr] <= hwdata;
              waddr <= waddr + 1'b1;
            end
            else begin
              mem[waddr] <= hwdata;
              waddr <= haddr;
            end
          end
          // incre 8
          8'b0000_0100: begin
            hreadyout <= 1'b1;
            hresp <= 1'b0;
            mem[waddr] <= hwdata;
            waddr <= waddr + 1'b1;
          end
          // wrap 16
          8'b0000_0010: begin
            hreadyout <= 1'b1;
            hresp <= 1'b0;
            if(waddr < (haddr + 4'd15)) begin
              mem[waddr] <= hwdata;
              waddr <= waddr + 1'b1;
            end
            else begin
              mem[waddr] <= hwdata;
              waddr <= haddr;
            end
          end
          // incre 16
          8'b0000_0001: begin
            hreadyout <= 1'b1;
            hresp <= 1'b0;
            mem[waddr] <= hwdata;
            waddr <= waddr + 1'b1;
          end
          // default
          default: begin
            hreadyout <= 1'b1;
            hresp <= 1'b0;
          end
        endcase
      end
      s3: begin
        case({single_flag,incr_flag,wrap4_flag,incr4_flag,wrap8_flag,incr8_flag,wrap16_flag,incr16_flag})
          // single transfer
          8'b1000_0000: begin
            hreadyout <= 1'b1;
            hresp <= 1'b0;
            hrdata <= mem[raddr];
          end
          // incre
          8'b0100_0000: begin
            hreadyout <= 1'b1;
            hresp <= 1'b0;
            hrdata <= mem[raddr];
            raddr <= raddr + 1'b1;
          end
          // wrap 4
          8'b0010_0000: begin
            hreadyout <= 1'b1;
            hresp <= 1'b0;
            if(raddr < (haddr + 2'd3)) begin
              hrdata <= mem[raddr];
              raddr <= raddr + 1'b1;
            end
            else begin
              hrdata <= mem[raddr];
              raddr <= haddr;
            end
          end
          // incre 4
          8'b0001_0000: begin
            hreadyout <= 1'b1;
            hresp <= 1'b0;
            hrdata <= mem[raddr];
            raddr <= raddr + 1'b1;
          end
          // wrap 8
          8'b0000_1000: begin
            hreadyout <= 1'b1;
            hresp <= 1'b0;
            if(raddr < (haddr + 3'd7)) begin
              hrdata <= mem[raddr];
              raddr <= raddr + 1'b1;
            end
            else begin
              hrdata <= mem[raddr];
              raddr <= haddr;
            end
          end
          // incre 8
          8'b0000_0100: begin
            hreadyout <= 1'b1;
            hresp <= 1'b0;
            hrdata <= mem[raddr];
            raddr <= raddr + 1'b1;
          end
          // wrap 16
          8'b0000_0010: begin
            hreadyout <= 1'b1;
            hresp <= 1'b0;
            if(raddr < (haddr + 4'd15)) begin
              hrdata <= mem[raddr];
              raddr <= raddr + 1'b1;
            end
            else begin
              hrdata <= mem[raddr];
              raddr <= haddr;
            end
          end
          // incre 16
          8'b0000_0001: begin
            hreadyout <= 1'b1;
            hresp <= 1'b0;
            hrdata <= mem[raddr];
            raddr <= raddr + 1'b1;
          end
          // default
          default: begin
            hreadyout <= 1'b1;
            hresp <= 1'b0;
          end
        endcase
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
