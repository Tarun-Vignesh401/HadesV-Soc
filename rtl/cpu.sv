/* Copyright (c) 2024 Tobias Scheipel, David Beikircher, Florian Riedl
 * Embedded Architectures & Systems Group, Graz University of Technology
 * SPDX-License-Identifier: MIT
 * ---------------------------------------------------------------------
 * File: cpu.sv
 */



module cpu (
    input logic clk,
    input logic rst,

    wishbone_interface.master memory_fetch_port,
    wishbone_interface.master memory_mem_port,

    input logic external_interrupt_in,
    input logic timer_interrupt_in
);
    // fetch to decode stage wires and vice versa 
    logic [31:0] instruction_ftod;    
    logic [31:0] pc_ftod;
    logic [31:0] jump_address_dtof;
    pipeline_status::forwards_t status_ftod;
    pipeline_status::backwards_t status_dtof;

    //decode to execute stage wires and vice versa 
    logic [31:0] instruction_dtoe;
    logic [31:0] pc_dtoe;
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    forwarding::t exe_forwarding;
    forwarding::t mem_forwarding; 
    forwarding::t wb_forwarding; 
    pipeline_status::forwards_t status_dtoe;
    pipeline_status::backwards_t status_etod;
    logic [31:0] jump_address__etod;
    
    // execute to memory wires and vice versa 

    logic [31:0] instruction_etom;
    logic [31:0] pc_etom;
    logic [31:0] next_pc_etom;
    logic [31:0] rd_data_etom;
    logic [31:0] source_data_etom;
    pipeline_status::forwards_t status_etom;
    pipeline_status::backwards_t status_mtoe;
    logic [31:0] jump_address_etom;

    // memory to wb wires and vice versa 

    logic [31:0] instruction_mtowb;
    logic [31:0] pc_mtowb;
    logic [31:0] next_pc_mtowb;
    logic [31:0] rd_data_mtowb;
    logic [31:0] source_data_mtowb;
    pipeline_status::forwards_t status_mtowb;
    pipeline_status::backwards_t status_wbtom;
    logic [31:0] jump_address_mtowb;

    // TODO: Delete the following line and implement this module.
   // ref_cpu golden(.*);
fetch_stage(
    .clk(clk),
    .rst(rst),
    .wb(memory_fetch_port),
    .instruction_reg_out(instruction_ftod),
    .program_counter_reg_out(pc_ftod),
    .jump_address_backwards_in(jump_address_dtof)
);
    
decode_stage(
  .clk(clk),
  .rst(rst),
  .instruction_in(instruction_ftod), 
  .program_counter_in(pc_ftod), 
  .exe_forwarding(exe_forwarding), 
  .mem_forwarding(mem_forwarding), 
  .wb_forwarding_in(wb_forwarding),
  .rs1_data_reg_out(rs1_data), 
  .rs2_data_reg_out(rs2_data), 
  .program_counter_reg_out(pc_dtoe),
  .status_forwards_in(status_ftod) , 
  .status_forwards_out(status_dtoe) , 
  .status_backwards_in(status_etod) , 
  .status_backwards_out(status_dtof),
  .jump_address_backwards_in(jump_address_etod), 
  .jump_address_backwards_out(jump_address_dtof)
  );

execute_stage(
    .clk(clk), 
    .rst(rst),
    .rs1_data_in(rs1_data) , 
    .rs2_data_in(rs2_data) , 
    .instruction_in(instruction_dtoe), 
    .program_counter_in(pc_dtoe),
    .source_data_reg_out(source_data_etom),
    .rd_data_reg_out(rd_data_etom),
    .instruction_reg_out(instruction_etom),
    .program_counter_reg_out(pc_etom),
    .next_program_counter_reg_out(next_pc_etom) ,
    .forwarding_out(exe_forwarding),
    .status_forwards_in(status_dtoe) ,
    .status_forwards_out(status_etom) ,
    .status_backwards_in(status_mtoe) ,
    .status_backwards_out(status_etod),
    .jump_address_backwards_in(jump_address_mtoe) ,
    .jump_address_backwards_out(jump_backwards_etod)
);

memory_stage(
    .clk(clk) ,
    .rst(rst),
    .wb(memory_mem_port),
    .source_data_in(source_data_etom) ,
    .rd_data_in(rd_data_etom) ,
    .instruction_in(instruction_in) ,
    .program_counter_in(pc_etom) ,
    .next_program_counter_in(next_pc_etom),
    .source_data_reg_out(source_data_mtowb) ,
    .instruction_reg_out(instruction_mtowb) ,
    .program_counter_reg_out(pc_mtowb) ,
    .next_program_counter_reg_out(next_pc_mtowb) ,
    .forwarding_out(wb_forwarding),
    .status_forwards_in(status_etom) ,
    .status_forwards_out(status_mtowb), 
    .status_backwards_in(status_wbtom) ,
    .status_backwards_out(status_mtoe), 
    .jump_address_backwards_in(jump_address_wbtom) ,
    .jump_address_backwards_out(jump_address_mtoe)
);



writeback_stage(
    .clk(clk),
    .rst(rst),
    .source_data_in(source_data_mtowb),
    .instruction_in(instruction_mtowb),
    .program_counter_in(pc_mtowb),
    .next_program_counter_in(next_pc_mtowb),
    .external_interrupt_in(external_interrupt_in),
    .timer_interrupt_in(timer_interrupt_in),
    .forwarding_out(wb_forwarding),
    .status_forwards_in(status_mtowb),
    .status_backwards_out(status_wbtom),
    .jump_address_backwards_out(jump_address_wbtom)
);

endmodule
