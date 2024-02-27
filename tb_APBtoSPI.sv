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
    logic              CLK;
    
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
    
    reg [7:0] mem [0:255];
    
    reg [WIDTH*2-1:0] w_data;
    reg [WIDTH-1 : 0] r_data;
    integer i;
    APBtoSPI DUT (.*);
    
    reg [WIDTH-1:0] data = 8'h55;
    
    initial begin
        PCLK = 'b1;
        forever #5 PCLK = !PCLK;
    end
    
    initial begin
        CLK = 'b1;
        forever #10 CLK = !CLK;
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
        {PSEL,PADDR,PWDATA,PENABLE,PWRITE} = 'b0;
        MISO = 'bz;
        @(posedge resetn);
        #200;
        wait(!w_wr_rst_busy & !w_rd_rst_busy & !r_wr_rst_busy & !r_rd_rst_busy);
        @(posedge PCLK);
//        repeat (3) begin
            APB_WRITE();
            SPI_WRITE();
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
        for(i=0;i<=7;i++)begin
            @(posedge CLK);
            r_data = {r_data[14:0],MOSI};
        end
        data = mem [w_data[15:8]];
//        @(negedge CLK);
        for(i=0;i<=7;i++) begin
            @(negedge CLK);
            MISO = data[0];
            data = data >> 1;
        end
        @(negedge CLK);
        MISO = 1'bz;
//        data = 8'h55;
        @(negedge CLK);
    endtask
    
    task SPI_WRITE();
        @(posedge MOSI);
        for(i=0;i<=16;i++)begin
            @(posedge CLK);
            w_data = {w_data[14:0],MOSI};
        end
        mem [w_data[15:8]]=w_data[7:0];
    endtask
    
    initial begin
        $dumpfile("APBtoSPI_wave.vcd");
        $dumpvars(0,tb);
    end
    
endmodule
