--==================================================================================
-- FECencoderPhase2.vhd RTLfile for Wi-Max
-- Adham Abouelata
-- 12/12/2023
--==================================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity FECencoderPhase2 is
    port(
        -- Global input ports
        clk: in std_logic;
        clk_100: in std_logic;
        reset: in std_logic;
        en: in std_logic;
        -- DPR inputs
        data_in: in std_logic_vector(0 downto 0);
        -- Local input ports
        ready_in: in std_logic;
		valid_in: in std_logic;
        -- Local output ports
        valid_out_port: out std_logic;
        ready_out: out std_logic;
        data_out: out std_logic_vector (0 downto 0)
    );
end FECencoderPhase2;

architecture FECrtl of FECencoderPhase2 is

--========================
-- component declarations
--========================
-- Dual Port Ram
component TwoPortRam is
    port
	(
		aclr		: IN STD_LOGIC;
		clock		: IN STD_LOGIC;
		data		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		enable		: IN STD_LOGIC;
		rdaddress		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wraddress		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC;
		q		: OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
	);
END component;
--
--============================
-- component declarations END
--============================

--==============================
-- internal signal declarations
--==============================

-- dual port ram signals
type state_type_RAM is (initial_wait_read, reading_writing_initial, reading_writing);
signal state_reg_RAM, state_next_RAM: state_type_RAM; -- for the inferrence of the state register
signal wr_address: std_logic_vector (7 downto 0);
signal wr_address_next: std_logic_vector (7 downto 0);
signal rd_address: std_logic_vector (7 downto 0);
signal wr_en: std_logic;
signal q_RAM: std_logic_vector (0 downto 0);
signal reset_RAM: std_logic;
signal data_in_reg: std_logic_vector(0 downto 0);
signal valid_in_reg: std_logic;
--

-- FEC signals
signal tailbite: std_logic_vector (5 downto 0);
signal tailbite_next: std_logic_vector (5 downto 0);
signal FEC_reg: std_logic_vector (5 downto 0);
signal FEC_next: std_logic_vector (5 downto 0);
signal X1: std_logic;
signal X2: std_logic;
signal valid_out: std_logic;
--==================================
-- internal signal declarations END
--==================================
begin
    reset_RAM <= not reset;
    valid_out_port <= valid_out; -- to use valid out as an input in the X1 and X2 section of the code
    wr_en <= valid_in_reg;
    ready_out <= '1';
    tailbite_next <= tailbite(4 downto 0) & data_in;
    --===================
    -- DPR instantiation
    --===================
    TwoPortRam_inst : TwoPortRam
    PORT MAP (
		aclr	 => reset_RAM,
		clock	 => clk,
        enable => en,
		data	 => data_in_reg,
		rdaddress	 => rd_address,
		wraddress	 => wr_address,
		wren	 => wr_en,
		q	 => q_RAM
	);
    --=======================
    -- DPR instantiation END
    --=======================

    --===================
    -- DPR state machine
    --===================
    process(clk, reset)
    begin
        if (reset = '0') then
            data_in_reg <= "0";
        elsif(clk'event and clk = '1' and en = '1') then
            data_in_reg <= data_in;
        end if;
    end process;

    process(clk, reset)
    begin
        if (reset = '0') then
            valid_in_reg <= '0';
        elsif(clk'event and clk = '1' and en = '1') then
            valid_in_reg <= valid_in;
        end if;
    end process;

    process(clk, reset)
    begin
        if (reset = '0') then
            state_reg_RAM <= initial_wait_read;
        elsif(clk'event and clk = '1' and en = '1') then
            state_reg_RAM <= state_next_RAM;
        end if;
    end process;

    
    process (clk, reset)
    begin
        if (reset = '0') then
            wr_address <= "01100000";
        else
            if (clk'event and clk ='1' and en = '1') then
                wr_address <= wr_address_next;
            end if;
        end if;
    end process;

    process (state_reg_RAM, valid_in_reg, ready_in, wr_address)
    begin
        case state_reg_RAM is
            when initial_wait_read => 
                if (valid_in_reg = '1' and ready_in = '1') then 
                    state_next_RAM <= reading_writing_initial;
                else
                    state_next_RAM <= initial_wait_read;
                end if;
            when reading_writing_initial =>
                if (wr_address = "10111111") then
                    state_next_RAM <= reading_writing; 
                else
                    state_next_RAM <= reading_writing_initial;
                end if;
            when reading_writing =>
                state_next_RAM <= reading_writing;
        end case;
    end process;

    process (state_reg_RAM, wr_address)
    begin
        case state_reg_RAM is
            when initial_wait_read => 
                wr_address_next <= "01100000";
                valid_out <= '0';
            when reading_writing_initial =>
                if (wr_address < "10111111") then
                    wr_address_next <= std_logic_vector(unsigned(wr_address) + 1);
                else
                    wr_address_next <= (others => '0');
                end if;
                valid_out <= '0';
            when reading_writing =>
                if (wr_address < "10111111") then
                    wr_address_next <= std_logic_vector(unsigned(wr_address) + 1);
                else
                    wr_address_next <= (others => '0');
                end if;
                valid_out <= '1';
        end case;
    end process;
    
    process(wr_address)
    begin
        if (wr_address > "01011110") then
            rd_address <= std_logic_vector(unsigned(wr_address) - 95);
        else
            rd_address <= std_logic_vector(97 + unsigned(wr_address));
        end if;
    end process;

    --======================
    -- DPR state machine END
    --=======================

    --=====
    -- FEC
    --=====
            
    process (clk, reset)
    begin
        if (reset = '0') then
            tailbite <= (others => '0');
        elsif (clk'event and clk = '1' and en = '1' and valid_in = '1') then
            tailbite <= tailbite_next;
        end if;
    end process;

    process (clk, reset)
    begin
        if (reset = '0') then
            FEC_reg <= (others => '0');
        else
            if (clk'event and clk ='1' and en = '1') then
                FEC_reg <= FEC_next;
            end if;
        end if;
    end process;
    
    process (FEC_reg, tailbite, wr_address, q_RAM)
    begin
        if (wr_address = "10111111" or wr_address = "01011111") then
            FEC_next <= tailbite;
        else
            FEC_next <= FEC_reg(4 downto 0) & q_RAM;
        end if;
    end process;
    
    --=========
    -- FEC END
    --=========

    --=======================================================
    -- Continous assignments and serialization for X1 and X2
    --=======================================================
    -- X1&X2
   
    X1 <= q_RAM(0) xor FEC_reg(0) xor FEC_reg(1) xor FEC_reg(2) xor FEC_reg(5);
    X2 <= q_RAM(0) xor FEC_reg(1) xor FEC_reg(2) xor FEC_reg(4) xor FEC_reg(5);

    -- Serialization
    process (clk_100, reset)
    begin
        if (reset = '0') then
            data_out(0) <= '0';
        elsif (clk_100'event and clk_100 = '1' and en = '1') then
            if (clk = '1') then
                data_out(0) <= X1;
            else
                data_out(0) <= X2;
            end if;
        end if;
    end process;
    --===============
    -- X1 and X2 END
    --===============

    end architecture FECrtl;