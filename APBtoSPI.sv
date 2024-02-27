`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/20/2024 11:22:13 AM
// Design Name: 
// Module Name: APBtoSPI
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module APBtoSPI #(parameter WIDTH = 8)(
    
    //global reset
    input              resetn,
    
    //SPI signals
    input              SCLK,  
    input              MISO,  
    output             MOSI,  
    output             CS_n,
    
    //APB signals
    input              PCLK,
    input              PSEL,
    input  [WIDTH-1:0] PADDR,
    input  [WIDTH-1:0] PWDATA,
    input              PENABLE,
    input              PWRITE,
    output             PREADY,
    output             PSLVERR,
    output [WIDTH-1:0] PRDATA, 
    
    //FIFO buzy signal
    output             w_wr_rst_busy,
    output             w_rd_rst_busy,
    output             r_wr_rst_busy,
    output             r_rd_rst_busy 
    );
    
    //WRITE_FIFO Signals
    
    wire             w_empty;
    wire             w_valid;
    wire [WIDTH*2:0] w_dout;
    wire             w_rd_en;
    wire             w_full;
    wire             w_wr_ack;
    wire             w_wr_en;
    wire [WIDTH*2:0] w_din; 
    
    //READ_FIFO Signals
    
    wire             r_empty;
    wire             r_valid;
    wire [WIDTH-1:0] r_dout;
    wire             r_rd_en;    
    wire             r_full;
    wire             r_wr_ack;
    wire             r_wr_en;
    wire [WIDTH-1:0] r_din;
    
    wire reset = !resetn;
    
    APB apb ( .PCLK     (PCLK    ), 
              .PRESET_N (resetn), 
              .PSEL     (PSEL    ), 
              .PADDR    (PADDR   ), 
              .PWDATA   (PWDATA  ), 
              .PENABLE  (PENABLE ), 
              .PWRITE   (PWRITE  ), 
              .PREADY   (PREADY  ), 
              .PSLVERR  (PSLVERR ), 
              .PRDATA   (PRDATA  ),
              .w_full       (w_full       ), 
              .w_wr_ack     (w_wr_ack     ), 
              .w_wr_rst_busy(w_wr_rst_busy), 
              .w_rd_rst_busy(w_rd_rst_busy), 
              .w_wr_en      (w_wr_en      ), 
              .w_din        (w_din        ),              
              .r_empty      (r_empty      ), 
              .r_valid      (r_valid      ), 
              .r_wr_rst_busy(r_wr_rst_busy), 
              .r_rd_rst_busy(r_rd_rst_busy), 
              .r_dout       (r_dout       ), 
              .r_rd_en      (r_rd_en      ) 
);

    SPI spi (.resetn (resetn ),       
                    .SCLK   (SCLK   ),
                    .MISO   (MISO   ),
                    .MOSI   (MOSI   ),
                    .CS_n   (CS_n   ),
                    .w_dout (w_dout ), 
                    .w_empty(w_empty), 
                    .w_valid(w_valid), 
                    .w_rd_en(w_rd_en), 
                    .r_din  (r_din  ), 
                    .r_wr_en(r_wr_en)     
);
    
  WRITE_FIFO w_fifo (
  .rst(reset),                  // input wire rst
  .wr_clk(PCLK),            // input wire wr_clk
  .rd_clk(SCLK),            // input wire rd_clk
  .din(w_din),                  // input wire [16 : 0] din
  .wr_en(w_wr_en),              // input wire wr_en
  .rd_en(w_rd_en),              // input wire rd_en
  .dout(w_dout),                // output wire [16 : 0] dout
  .full(w_full),                // output wire full
  .wr_ack(w_wr_ack),            // output wire wr_ack
  .empty(w_empty),              // output wire empty
  .valid(w_valid),              // output wire valid
  .wr_rst_busy(w_wr_rst_busy),  // output wire wr_rst_busy
  .rd_rst_busy(w_rd_rst_busy)  // output wire rd_rst_busy
);

   READ_FIFO r_fifo (
  .rst(reset),                  // input wire rst
  .wr_clk(SCLK),            // input wire wr_clk
  .rd_clk(PCLK),            // input wire rd_clk
  .din(r_din),                  // input wire [7 : 0] din
  .wr_en(r_wr_en),              // input wire wr_en
  .rd_en(r_rd_en),              // input wire rd_en
  .dout(r_dout),                // output wire [7 : 0] dout
  .full(r_full),                // output wire full
  .wr_ack(r_wr_ack),            // output wire wr_ack
  .empty(r_empty),              // output wire empty
  .valid(r_valid),              // output wire valid
  .wr_rst_busy(r_wr_rst_busy),  // output wire wr_rst_busy
  .rd_rst_busy(r_rd_rst_busy)  // output wire rd_rst_busy
);
    
endmodule
