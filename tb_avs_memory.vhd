-- Testbench created online at:
--   www.doulos.com/knowhow/perl/testbench_creation/
-- Copyright Doulos Ltd
-- SD, 03 November 2002

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity avs_memory_tb is
end;

architecture bench of avs_memory_tb is

  component avs_memory
      port
      (
          clk		: IN STD_LOGIC;
          rst_n   : in std_logic;
          avs_address : in std_logic_vector (17 downto 0);
          avs_read : in std_logic;
          avs_readdata : out std_logic_vector (31 downto 0);
          avs_write : in std_logic;
          avs_writedata : in std_logic_vector (31 downto 0);
          rv_ready : out std_logic;
          rv_addr : in std_logic_vector(17 downto 0);
          rv_rdata : out std_logic_vector(31 downto 0);
          rv_valid : in std_logic
      );
  end component;

  signal clk: STD_LOGIC;
  signal rst_n: std_logic;
  signal avs_address: std_logic_vector (17 downto 0);
  signal avs_read: std_logic;
  signal avs_readdata: std_logic_vector (31 downto 0);
  signal avs_write: std_logic;
  signal avs_writedata: std_logic_vector (31 downto 0) ;
  
  signal rv_ready :  std_logic;
  signal rv_addr : std_logic_vector(17 downto 0);
  signal rv_rdata :  std_logic_vector(31 downto 0);
  signal rv_valid : std_logic;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin


    

  uut: avs_memory port map ( clk           => clk,
                         rst_n         => rst_n,
                         avs_address   => avs_address,
                         avs_read      => avs_read,
                         avs_readdata  => avs_readdata,
                         avs_write     => avs_write,
                         avs_writedata => avs_writedata,
                         rv_ready => rv_ready,
                         rv_addr => rv_addr,
                         rv_rdata => rv_rdata,
                         rv_valid => rv_valid
                         );

  stimulus: process
  begin
  
    -- Put initialisation code here

    rst_n <= '0';

    avs_address <= (others => '0');
    avs_writedata<= (others => '0');
    avs_write <= '0';
    avs_read <= '0';
    rv_valid <= '0';
    rv_addr <= (others => '0');
    wait for 5 ns;
    rst_n <= '1';
    wait for 5 ns;
    -- Write some stuff
    
    avs_read <= '0';
    avs_write <= '1';
    for i in 0 to 10 loop
        wait until falling_edge(clk);
        avs_address <= std_logic_vector(to_unsigned(i,avs_address'length));
        avs_writedata <= std_logic_vector(to_unsigned(i,avs_writedata'length));
    end loop;
    wait for clock_period/2;
    
    avs_read <= '1';
    avs_write <= '0';
    for i in 0 to 10 loop
        wait until falling_edge(clk);
        avs_address <= std_logic_vector(to_unsigned(i,avs_address'length));
        -- report "Read value: " & integer'
        -- avs_writedata <= std_logic_vector(to_unsigned(i,avs_writedata'length));
    end loop;
    avs_read <= '0';

    -- read data from ram
    for i in 0 to 10 loop
        wait until rising_edge(clk);
        rv_valid <= '1';
        rv_addr <= std_logic_vector(to_unsigned(i,avs_address'length));
        wait until rv_ready = '1';
        -- wait for clock_period*10;
        rv_valid <= '0';
    end loop;



    -- Put test bench stimulus code here

    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;