/* Copyright (c) 2024 Tobias Scheipel, David Beikircher, Florian Riedl
 * Embedded Architectures & Systems Group, Graz University of Technology
 * SPDX-License-Identifier: MIT
 * ---------------------------------------------------------------------
 * File: fetch_stage.sv
 */



module fetch_stage (
    input logic clk,
    input logic rst,

    // Memory interface
    wishbone_interface.master wb,

    //  Output data
    output logic [31:0] instruction_reg_out,
    output logic [31:0] program_counter_reg_out,

    // Pipeline control
    output pipeline_status::forwards_t  status_forwards_out,
    input  pipeline_status::backwards_t status_backwards_in,
    input  logic [31:0] jump_address_backwards_in
);

    // TODO: Delete the following line and implement this module.
    //ref_fetch_stage golden(.*);
    logic [31:0] instruction_fetch;
    logic [31:0] pc_fetch;
    logic [31:0] jump_address_fetch;
    pipeline_status::forwards_t status_forwards_fetch;
    pipeline_status::backwards_t status_backwards_fetch;
   
 always_ff @(clk,rst) begin 
    if(rst) begin
        pc_fetch <= constants::RESTART_ADDRESS;               
        wb.stb <= 0;
        wb.we  <= 0;
        wb.cyc <= 0;
        wb.adr <= 0;
        wb.sel <=0;
        wb.data_mosi <= 0;
        status_forwards_fetch <= VALID;

    end else begin
        if(status_backwasds_fetch == READY) begin
        pc_fetch <= pc_fetch + 4;
        wb.stb <= 1;
        wb.cyc <= 1;
        


        end
        else if(status_backwards_fetch == JUMP)begin


        end
        else begin


        end



    end


    
        

endmodule
