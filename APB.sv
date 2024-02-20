`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CDAC
// Engineer: Atharva, Rajat, Pankaj, Joshua, Pavan
// 
// Create Date: 2/14/2024 12:58:39 PM
// Design Name: APB to SPI Bridge
// Module Name: APB
// Project Name: APB to SPI Bridge
// Target Devices: Basys 3
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


module APB #(parameter WIDTH = 8)(

    //APB signals
    input                    PCLK,
    input                    PRESET_N,
    input                    PSEL,
    input        [WIDTH-1:0] PADDR,
    input        [WIDTH-1:0] PWDATA,
    input                    PENABLE,
    input                    PWRITE,
    output logic             PREADY,
    output logic             PSLVERR,
    output logic [WIDTH-1:0] PRDATA,
    
    //WRITE_FIFO Signals
    
    input                    w_full,
    input                    w_wr_ack,
    input                    w_wr_rst_busy,
    input                    w_rd_rst_busy,
    output logic             w_wr_en,
    output logic [WIDTH*2:0] w_din, 
    
    //READ_FIFO Signals
    
    input                    r_empty,
    input                    r_valid,
    input                    r_wr_rst_busy,
    input                    r_rd_rst_busy,
    input        [WIDTH-1:0] r_dout,
    output logic             r_rd_en   
    );
    
    //reset status register
//    reg [1:0] write_fifo_reset, read_fifo_reset;
    
    //state registers
    reg [2:0] next_state, present_state;  
    
    //write logic reg
//    reg [WIDTH*2 : 0]write_fifo;
    
    //read logic reg
//    reg [WIDTH-1 : 0]read_fifo;
    
    //3 states with one hot encoding
    localparam IDLE  = 3'b001;
    localparam SETUP  = 3'b010;
    localparam ACCESS = 3'b100;
    
    //assigning values to status register
//    assign write_fifo_reset = {w_wr_rst_busy,w_rd_rst_busy};
//    assign read_fifo_reset  = {r_wr_rst_busy,r_rd_rst_busy};
    
    //state transition logic
    always_ff@(posedge PCLK) begin
        if(!PRESET_N) begin
            present_state <= IDLE;
        end else begin
            present_state <= next_state;
        end
    end
    
    //FSM logic for state transition
    //always@(posedge PCLK) begin
    always_comb begin
    
        {PREADY,PSLVERR,w_wr_en,r_rd_en} = 'b0;
        w_din   = {PWRITE,PADDR,PWDATA};
        PRDATA  = r_dout;
        
        case(present_state)
            IDLE : begin
//                    {w_wr_en,r_rd_en} = 1'b0;
                        if(PSEL && !PENABLE) begin
                            next_state = SETUP;
                        end else begin
                            next_state = IDLE;
                        end
                    end
            SETUP : begin
                        if(PWRITE) begin
//                            w_din   = {PWRITE,PADDR,PWDATA};
//                            PRDATA  = r_dout;
                            w_wr_en = 1'b1;
                            r_rd_en = 1'b0;
                        end else begin
//                            w_din   = {PWRITE,PADDR,8'b0};
//                            PRDATA  = r_dout;
                            w_wr_en = 1'b1;
//                            r_rd_en = 1'b1;
                        end 
                        
                        if(PSEL && PENABLE) begin
                            next_state = ACCESS;
                        end else begin
                            next_state = IDLE;
                        end
                    end
            ACCESS : begin
                        if(PSEL && PENABLE) begin
                            if(PWRITE & !w_full) begin
//                                w_wr_en = 1'b1;
                                if(w_wr_ack) begin
                                    PREADY     = 1'b1;
                                    next_state = IDLE;
                                end else begin
                                    PREADY     = 1'b0;
                                    next_state = ACCESS;
                                end
                            end else if (PWRITE & w_full) begin
                                PSLVERR    = 1'b1;
                                PREADY     = 1'b1;
                                next_state = IDLE;
                            end else if (!PWRITE & !r_empty) begin
                                r_rd_en = 1'b1;
                                if(r_valid) begin
                                    PREADY     = 1'b1;
                                    next_state = IDLE;
                                end else begin
                                    PREADY     = 1'b0;
                                    next_state = ACCESS;
                                end
                            end else if (!PWRITE & r_empty) begin
                                if(r_valid) begin
                                    PREADY     = 1'b1;
                                    next_state = IDLE;
                                end else begin
                                    PREADY     = 1'b0;
                                    next_state = ACCESS;
                                end
                            end else begin
                                PSLVERR    = 1'b1;
                                PREADY     = 1'b1; 
                                next_state = IDLE;
                            end
                        end else begin
                            PSLVERR    = 1'b1;
                            next_state = IDLE;
                        end
                     end
            default : next_state = IDLE;
        endcase
    end
    
endmodule
