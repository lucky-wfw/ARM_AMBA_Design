//--------------------------------------------------------
// GPIO from ARM doc
// Author: ARM Company
//--------------------------------------------------------
// Programmer's model
// 0x00 RO    DataIn
// 0x04 RW    Data Output
// 0x08 RW    Output enable
// 0x0C RW    Interrupt Enable
// 0x10 RW    Interrupt Type
// 0x14 RW    Interrupt Polarity
// 0x18 RWc   Interrupt State
//--------------------------------------------------------

module apb_gpio #(
  parameter PortWidth = 8
)(
input wire PCLK, // Clock
input wire PRESETn, // Reset
// APB interface inputs
input wire PSEL, // Device select
input wire [7:2] PADDR, // Address
input wire PENABLE, // Transfer control
input wire PWRITE, // Write control
input wire [31:0] PWDATA, // Write data
// APB interface outputs
output wire [31:0] PRDATA, // Read data
output wire PREADY, // Device ready
output wire PSLVERR, // Device error response
// GPIO Interface inputs and output
input wire [PortWidth-1:0] PORTIN, // GPIO input
output wire [PortWidth-1:0] PORTOUT, // GPIO output
output wire [PortWidth-1:0] PORTEN, // GPIO output enable
// Interrupt outputs
output wire [PortWidth-1:0] GPIOINT, // Interrupt output for each pin
output wire COMBINT // Combined interrupt
);


// Signals for read/write controls
wire  ReadEnable;
wire  WriteEnable;
wire  WriteEnable04; // Write enable for Data Output register
wire  WriteEnable08; // Write enable for Output Enable register
wire  WriteEnable0C; // Write enable for Interrupt Enable register
wire  WriteEnable10; // Write enable for Interrupt Type register
wire  WriteEnable14; // Write enable for Interrupt Polarity register
wire  WriteEnable18; // Write enable for Interrupt State register
reg  [PortWidth-1:0] ReadMux;
reg  [PortWidth-1:0] ReadMuxReg;


// Signals for Control registers
reg [PortWidth-1:0] RegDOUT;
reg [PortWidth-1:0] RegDOUTEN;
reg [PortWidth-1:0] RegINTEN;
reg [PortWidth-1:0] RegINTTYPE;
reg [PortWidth-1:0] RegINTPOL;
reg [PortWidth-1:0] RegINTState;

// I/O signal path
reg [PortWidth-1:0] DataInSync1;
reg [PortWidth-1:0] DataInSync2;
wire [PortWidth-1:0] DataInPolAdjusted;
reg [PortWidth-1:0] LastDataInPol;
wire [PortWidth-1:0] EdgeDetect;
wire [PortWidth-1:0] RawInt;
wire [PortWidth-1:0] MaskedInt;
// Start of main code
// Read and write control signals
assign ReadEnable = PSEL & (~PWRITE); // assert for whole APB read transfer
assign WriteEnable = PSEL & (~PENABLE) & PWRITE; // assert for 1st cycle of write transfer
assign WriteEnable04 = WriteEnable & (PADDR[7:2] == 6'b000001);
assign WriteEnable08 = WriteEnable & (PADDR[7:2] == 6'b000010);
assign WriteEnable0C = WriteEnable & (PADDR[7:2] == 6'b000011);
assign WriteEnable10 = WriteEnable & (PADDR[7:2] == 6'b000100);
assign WriteEnable14 = WriteEnable & (PADDR[7:2] == 6'b000101);
assign WriteEnable18 = WriteEnable & (PADDR[7:2] == 6'b000110);

// Write operations
// Data Output register
always @(posedge PCLK or negedge PRESETn)
begin
  if (~PRESETn)
    RegDOUT <= {PortWidth{1'b0}};
  else if (WriteEnable04)
    RegDOUT <= PWDATA[(PortWidth-1):0];
end
// Output enable register
always @(posedge PCLK or negedge PRESETn)
begin
  if (~PRESETn)
    RegDOUTEN <= {PortWidth{1'b0}};
  else if (WriteEnable08)
    RegDOUTEN <= PWDATA[(PortWidth-1):0];
end
// Interrupt Enable register
always @(posedge PCLK or negedge PRESETn)
begin
  if (~PRESETn)
    RegINTEN <= {PortWidth{1'b0}};
  else if (WriteEnable0C)
    RegINTEN <= PWDATA[(PortWidth-1):0];
end
// Interrupt Type register
always @(posedge PCLK or negedge PRESETn)
begin
  if (~PRESETn)
    RegINTTYPE <= {PortWidth{1'b0}};
  else if (WriteEnable10)
    RegINTTYPE <= PWDATA[(PortWidth-1):0];
end
// Interrupt Polarity register
always @(posedge PCLK or negedge PRESETn)
begin
  if (~PRESETn)
    RegINTPOL <= {PortWidth{1'b0}};
  else if (WriteEnable14)
    RegINTPOL <= PWDATA[(PortWidth-1):0];
end
// Read operation
always @(PADDR or DataInSync2 or RegDOUT or RegDOUTEN or RegINTEN or RegINTTYPE or RegINTPOL or RegINTState)
begin
  case (PADDR[7:2])
    0: ReadMux = DataInSync2;
    1: ReadMux = RegDOUT;
    2: ReadMux = RegDOUTEN;
    3: ReadMux = RegINTEN;
    4: ReadMux = RegINTTYPE;
    5: ReadMux = RegINTPOL;
    6: ReadMux = RegINTState;
    default : ReadMux = {PortWidth{1'b0}}; // Read as 0 if address is out of range
  endcase
end
// Register read data
always @(posedge PCLK or negedge PRESETn)
begin
  if (~PRESETn)
    ReadMuxReg <= {PortWidth{1'b0}};
  else
    ReadMuxReg <= ReadMux;
end
// Output read data to APB
assign PRDATA = (ReadEnable) ? {{(32-PortWidth){1'b0}},ReadMuxReg} : {32{1'b0}};
assign PREADY = 1'b1; // Always ready
assign PSLVERR = 1'b0; // Always okay
// Output to external
assign PORTEN = RegDOUTEN;
assign PORTOUT = RegDOUT;
// Synchronize input
always @(posedge PCLK or negedge PRESETn)
begin
  if (~PRESETn)
    begin
      DataInSync1 <= {PortWidth{1'b0}};
      DataInSync2 <= {PortWidth{1'b0}};
    end
  else
    begin
      DataInSync1 <= PORTIN;
      DataInSync2 <= DataInSync1;
    end
end
// Interrupt generation - polarity handling
assign DataInPolAdjusted = DataInSync2 ^ RegINTPOL;
// Interrupt generation - record last value of DataInPolAdjusted
always @(posedge PCLK or negedge PRESETn)
begin
  if (~PRESETn)
    LastDataInPol <= {PortWidth{1'b0}};
  else
    LastDataInPol <= DataInPolAdjusted;
end
// Interrupt generation - positive edge detection
assign EdgeDetect = ~LastDataInPol & DataInPolAdjusted;
// Interrupt generation - select interrupt type
assign RawInt = ( RegINTTYPE & EdgeDetect) | (~RegINTTYPE & DataInPolAdjusted); // Level trigger
// Interrupt generation - Enable masking
assign MaskedInt = RawInt & RegINTEN;
// Interrupt state
always @(posedge PCLK or negedge PRESETn)
begin
  if (~PRESETn)
    RegINTState <= {PortWidth{1'b0}};
  else
    RegINTState <= MaskedInt|(RegINTState & ~(PWDATA[PortWidth-1:0] & {PortWidth{WriteEnable18}}));
end
// Connect interrupt signal to top level
assign GPIOINT = RegINTState;
assign COMBINT = (|RegINTState);
  
endmodule

