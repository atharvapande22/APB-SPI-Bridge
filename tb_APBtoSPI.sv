`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/20/2024 01:43:33 PM
// Design Name: 
// Module Name: tb_APBtoSPI
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


module tb_APBtoSPI #(parameter WIDTH = 8)();

    logic              resetn;
    
    //SPI signals
    logic              SCLK;  
    logic              MISO;  
    logic              MOSI;  
    logic              CS_n;
    
    //APB signals
    logic              PCLK;
    logic              PSEL;
    logic  [WIDTH-1:0] PADDR;
    logic  [WIDTH-1:0] PWDATA;
    logic              PENABLE;
    logic              PWRITE;
    logic              PREADY;
    logic              PSLVERR;
    logic [WIDTH-1:0]  PRDATA; 
    
    //FIFO buzy signal
    logic              w_wr_rst_busy;
    logic              w_rd_rst_busy;
    logic              r_wr_rst_busy;
    logic              r_rd_rst_busy;  
    
    reg [WIDTH-1:0] addr;
    integer i;
    APBtoSPI DUT (.*);
    
    reg [WIDTH-1:0] data = 8'h4a;
    
    initial begin
        PCLK = 'b1;
        forever #5 PCLK = !PCLK;
    end
    
    initial begin
        SCLK = 'b1;
        forever #10 SCLK = !SCLK;
    end
    
//    initial begin
//        MISO = 'b1;
//        forever #20 MISO = !MISO;
//    end
    
    initial begin
        resetn = 'b0;
        #200 resetn = 'b1;
    end
    
    initial begin
        {PSEL,PADDR,PWDATA,PENABLE,PWRITE,PREADY} = 'b0;
        MISO = 'bz;
        @(posedge resetn);
        #200;
        wait(!w_wr_rst_busy & !w_rd_rst_busy & !r_wr_rst_busy & !r_rd_rst_busy);
        @(posedge PCLK);
//        repeat (3) begin
            APB_WRITE();
            #600;
            fork
                APB_READ();
                SPI_READ();
            join
            wait(PREADY);
//        end
        #500 $finish();    
    end
    
    task APB_WRITE();
        @(negedge PCLK);
        PSEL    = 1'b1;
        PENABLE = 1'b0;
        {PADDR,PWDATA,PWRITE} = {8'haa,8'h55,1'b1};
        @(negedge PCLK);
        PSEL    = 1'b1;
        PENABLE = 1'b1;
        @(posedge PREADY);
        #20;
        PSEL    = 1'b0;
        PENABLE = 1'b0;
    endtask
    
    task APB_READ();
        @(negedge PCLK);
        PSEL    = 1'b1;
        PENABLE = 1'b0;
        {PADDR,PWDATA,PWRITE} = {8'haa,8'h0,1'b0};
        @(negedge PCLK);
        PSEL    = 1'b1;
        PENABLE = 1'b1;
        @(posedge PREADY);
        #20;
        PSEL    = 1'b0;
        PENABLE = 1'b0;
    endtask
    
    task SPI_READ();
        @(negedge MOSI);
        for(i=0;i<7;i++) begin
           @(posedge SCLK);
           MISO = 1'bz;
        end
        @(negedge SCLK);
        for(i=0;i<=7;i++) begin
            @(negedge SCLK);
            MISO = data[0];
            data = data >> 1;
        end
        @(negedge SCLK);
        MISO = 1'bz;
        data = 8'h55;
        @(negedge SCLK);
    endtask
    
    initial begin
        $dumpfile("APBtoSPI_wave.vcd");
        $dumpvars(0,tb_APBtoSPI);
    end
    
endmodule
