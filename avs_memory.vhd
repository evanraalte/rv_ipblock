library ieee;
use ieee.std_logic_1164.all;

entity avs_memory is
    port
    (
        clk		: IN STD_LOGIC;
        rst_n   : in std_logic;

        --Avalon MM Slave
        avs_address : in std_logic_vector (17 downto 0);
        avs_read : in std_logic;
        avs_readdata : out std_logic_vector (31 downto 0);
        -- readdatavalid : out std_logic;
        avs_write : in std_logic;
        avs_writedata : in std_logic_vector (31 downto 0);
        -- writeresponsevalid : in std_logic

        --To picoRVSoc

        rv_ready : out std_logic;
        rv_addr : in std_logic_vector(17 downto 0);
        rv_rdata : out std_logic_vector(31 downto 0);
        rv_valid : in std_logic


    );
end avs_memory;


architecture arch of avs_memory is
    component ram
	PORT
	(
		address_a		: IN STD_LOGIC_VECTOR (17 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (17 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data_a		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        data_b		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        rden_a		: IN STD_LOGIC  := '1';
		rden_b		: IN STD_LOGIC  := '1';
		wren_a		: IN STD_LOGIC  := '0';
		wren_b		: IN STD_LOGIC  := '0';
		q_a		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
    end component;  


    signal ram_data_in		    : STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal ram_address		: STD_LOGIC_VECTOR (17 DOWNTO 0);
    signal ram_write_enable		    : STD_LOGIC;
    signal ram_read_enable		    : STD_LOGIC;
    signal ram_data_out		    :  STD_LOGIC_VECTOR (31 DOWNTO 0);

    
    signal rv_data_in		    : STD_LOGIC_VECTOR (31 DOWNTO 0);
    signal rv_address		: STD_LOGIC_VECTOR (17 DOWNTO 0);
    signal rv_write_enable		    : STD_LOGIC;
    signal rv_read_enable		    : STD_LOGIC;
    signal rv_data_out		    :  STD_LOGIC_VECTOR (31 DOWNTO 0);

    signal rv_rdy : std_logic;

begin
    ram0 : ram port map(
        address_a => ram_address,
        address_b => rv_address,
        clock => clk,
        data_a  => ram_data_in,
        data_b  => rv_data_in,
        rden_a  => ram_read_enable,
        rden_b => rv_read_enable,
        wren_a => ram_write_enable,
        wren_b => rv_write_enable,
        q_a => ram_data_out,
        q_b => rv_data_out
        );
    
    avalon_mm_slave : process (clk,rst_n)
    begin
        if rst_n = '0' then
            -- ram_address  <= (others => '0');
            -- ram_data_in <= (others => '0');
            avs_readdata <= (others => '0');

        elsif rising_edge(clk) then
            if avs_read =  '1' then
                ram_address <=  avs_address;
                avs_readdata <= ram_data_out;
            elsif avs_write = '1' then
                ram_address <= avs_address;
                ram_data_in <= avs_writedata;
            end if;
        end if;
    end process;

    ram_write_enable <= '1' when avs_write = '1' and rst_n = '1' else '0'; 
    ram_read_enable <= '1' when avs_read = '1' and rst_n = '1' else '0'; 


    ram_wrapper: process (clk, rst_n)
        variable count : natural range 0 to 6 := 0;
        variable count_en : boolean := false;
    begin
        if rst_n = '0' then
            rv_rdy <= '0';
            rv_rdata <= (others => '0');
            count := 0;
            count_en := false;
            rv_write_enable <= '0';
            rv_address <= rv_addr;
            rv_read_enable <= '0';
        elsif rising_edge(clk) then
            if rv_valid = '1' and count_en = false then
                rv_address <= rv_addr;
                rv_read_enable <= '1';
                rv_read_enable <= '1';
                count_en := true;
            elsif rv_valid = '1' and count_en = true and count <= 5 then
                count := count + 1 ;
            elsif rv_valid = '1' and count_en = true and count >= 6 then
                count_en := false;
                count := 0;
                rv_rdy <= '1';
                rv_rdata <= rv_data_out;
                rv_read_enable <= '0';
            elsif rv_valid = '0'  and rv_rdy = '1' then
                rv_rdy <= '0';                
            end if;
        end if;
    end process;
    rv_ready <= rv_rdy;

            


end arch;