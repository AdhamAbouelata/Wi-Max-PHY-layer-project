
--==========================================================
-- FECencoder_tb.vhd SELF-CHECKING TESTBENCH for FECencoder
-- Adham Abouelata
-- 12/12/2023
-- Tests two packets of the same input.
-- Tailbites sucessfully.
-- No test failed prompt.
--==========================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.packageForTB.all;

entity interleaver_tb3 is
end interleaver_tb3;

architecture arc of interleaver_tb3 is
-- component declaration

  

 signal  data_in:  std_logic_vector(0 downto 0);

signal valid_out:std_logic;
 signal  ready_out: std_logic;
 signal  data_out:  std_logic_vector(0 downto 0);
signal locked:std_logic;


signal clk2: std_logic:= '0';
signal reset: std_logic := '0';
signal en: std_logic := '1';
signal ready_in: std_logic := '0';
signal valid_in: std_logic := '0';

signal gold_in:std_logic_vector (191 downto 0):= "001010000011001111100100100011010011100100100000001001101101010110110110110111000101111001001010111101000111101011011101001010010100100101001011011011001000100100010101000100110100100011001010";

signal gold_out:std_logic_vector (191 downto 0):="010010110000010001111101111110100100001011110010101001011101010111110110000111000000001000011010010110000101000111101001101000110000100110100010010011111101010110000000100001101011110100011110";

-- periods of the clocks

constant period_100: time := 10 ns;
--


component interleaver_7 is
  port(
    clk: in std_logic ;
	 --clk_100:in std_logic;
    reset: in std_logic;
    en:in std_logic;
    data_in: in std_logic_vector(0 downto 0);
    ready_in: in std_logic;
    valid_in: in std_logic;
    valid_out: out std_logic;
    ready_out: out std_logic;
    data_out: out std_logic_vector(0 downto 0)
  );
end component;


begin

intrlv:interleaver_7
port map(

 clk=> clk2,
	 --clk_100:in std_logic;
    reset=> reset,
    en=>en,
    data_in=> data_in,
    ready_in=> ready_in,
    valid_in=> valid_in,
    valid_out=> valid_out,
    ready_out=> ready_out,
    data_out=> data_out
	

);
    --

    -- clock generation
  
    clk2 <= not clk2 after period_100/2;
    --

    --stimulus
    process
    begin
        wait for (period_100);
        reset <= '1';
        wait for (period_100);
        ready_in <= '1';
        valid_in <= '1';
        wait for (period_100);
        for i in 0 to 191 loop
            gold_in_data(gold_in(191-i downto 191-i), data_in);
            wait for (period_100);
        end loop;
 for i in 0 to 191 loop
            gold_in_data(gold_in(191-i downto 191-i), data_in);
            wait for (period_100);
        end loop;
        wait;
    end process;
    --
    
    -- self checking
    process
    begin
        wait until (valid_out = '1');
        wait for (period_100+period_100/2);
        for i in 0 to 191 loop
            gold_out_data(gold_out(191-i), data_out(0));
            wait for (period_100);
	end loop;
	for i in 0 to 191 loop
            gold_out_data(gold_out(191-i), data_out(0));
            wait for (period_100);
        end loop;
       wait;
    end process;
    --

 

end arc;