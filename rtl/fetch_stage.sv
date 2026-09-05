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
    //logic [31:0] instruction_fetch;
    //logic [31:0] pc_fetch;
    //logic [31:0] jump_address_fetch;
    pipeline_status::forwards_t status_forwards_fetch;
    pipeline_status::backwards_t status_backwards_fetch;


    logic [31:0] word_address;
    logic [1:0] word_offset;

//this dude changes if pc changes instantaneously......
//pc alignment
always_comb begin
    word_address = program_counter_reg_out & 32'h1111_1100;
    word_offset = program_counter_reg_out & 32'h0000_0011;
end

always_comb begin
      if(status_backwards_in == READY) begin
        wb.cyc = 1;
        wb.stb = 1;
        wb.adr = word_address;
        wb.sel = word_offset;    
        wb.miso = instruction_fetch;
        if(wb.ack | wb.err)begin
            wb.stb = 0;
            wb.cyc = 0;
            if(wb.err)begin
                wb.cyc = 1;
                wb.stb = 1;
                wb.adr = word_address;
                wb.sel = word_offset; 
            end
        end
    end
    else if(status_backwards_in == JUMP)begin
        
    end
end
   
 always_ff @(clk,rst) begin 
    if(rst) begin
        program_counter_reg_out <= constants::RESTART_ADDRESS;               
        status_forwards_out <= VALID;
    end 
    else begin
        program_counter_reg_out <= pc_fetch + 4;
        instruction_reg_out <= wb.miso;
    end



end


    
        

endmodule
