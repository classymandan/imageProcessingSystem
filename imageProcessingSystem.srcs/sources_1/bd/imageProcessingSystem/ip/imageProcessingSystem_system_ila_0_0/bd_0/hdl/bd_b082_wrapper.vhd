--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Command: generate_target bd_b082_wrapper.bd
--Design : bd_b082_wrapper
--Purpose: IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity bd_b082_wrapper is
  port (
    SLOT_0_AXIS_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    SLOT_0_AXIS_tkeep : in STD_LOGIC_VECTOR ( 3 downto 0 );
    SLOT_0_AXIS_tlast : in STD_LOGIC;
    SLOT_0_AXIS_tready : in STD_LOGIC;
    SLOT_0_AXIS_tvalid : in STD_LOGIC;
    SLOT_1_AXIS_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    SLOT_1_AXIS_tlast : in STD_LOGIC;
    SLOT_1_AXIS_tready : in STD_LOGIC;
    SLOT_1_AXIS_tvalid : in STD_LOGIC;
    clk : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    resetn : in STD_LOGIC
  );
end bd_b082_wrapper;

architecture STRUCTURE of bd_b082_wrapper is
  component bd_b082 is
  port (
    clk : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 0 to 0 );
    resetn : in STD_LOGIC;
    SLOT_0_AXIS_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    SLOT_0_AXIS_tkeep : in STD_LOGIC_VECTOR ( 3 downto 0 );
    SLOT_0_AXIS_tlast : in STD_LOGIC;
    SLOT_0_AXIS_tready : in STD_LOGIC;
    SLOT_0_AXIS_tvalid : in STD_LOGIC;
    SLOT_1_AXIS_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    SLOT_1_AXIS_tlast : in STD_LOGIC;
    SLOT_1_AXIS_tready : in STD_LOGIC;
    SLOT_1_AXIS_tvalid : in STD_LOGIC
  );
  end component bd_b082;
begin
bd_b082_i: component bd_b082
     port map (
      SLOT_0_AXIS_tdata(31 downto 0) => SLOT_0_AXIS_tdata(31 downto 0),
      SLOT_0_AXIS_tkeep(3 downto 0) => SLOT_0_AXIS_tkeep(3 downto 0),
      SLOT_0_AXIS_tlast => SLOT_0_AXIS_tlast,
      SLOT_0_AXIS_tready => SLOT_0_AXIS_tready,
      SLOT_0_AXIS_tvalid => SLOT_0_AXIS_tvalid,
      SLOT_1_AXIS_tdata(31 downto 0) => SLOT_1_AXIS_tdata(31 downto 0),
      SLOT_1_AXIS_tlast => SLOT_1_AXIS_tlast,
      SLOT_1_AXIS_tready => SLOT_1_AXIS_tready,
      SLOT_1_AXIS_tvalid => SLOT_1_AXIS_tvalid,
      clk => clk,
      probe0(0) => probe0(0),
      resetn => resetn
    );
end STRUCTURE;
