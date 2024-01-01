


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tl is
  port(
    clk:                        in std_logic;
    clk2: 			in std_logic;
    reset:                      in std_logic;
    en:                         in std_logic;
    data_in:                    in std_logic_vector(0 downto 0);
    data_out_q: 		out std_logic_vector(15 downto 0);
    data_out_i: 		out std_logic_vector(15 downto 0);
    valid_out:			out std_logic; 
    ready_in:   		in std_logic;
	 ready_out: out std_logic;
	 data1Port: out std_logic_vector(0 downto 0);
	 data2Port: out std_logic_vector(0 downto 0);
	 valid1Port: out std_logic;
	 valid2Port: out std_logic;
    valid_in:			in std_logic
  );
end entity tl;



architecture arc of tl is



 signal ready1:  std_logic;
 signal  valid1:  std_logic;


  signal ready2:  std_logic;
 signal  valid2:  std_logic;

signal data1:std_logic_vector(0 downto 0);
signal data2:std_logic_vector(0 downto 0);




component interleaver_7 is
  port(
    clk: in std_logic ;
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
component QPSK_enc_pll is
	port(
		--Global input ports
		clk: in std_logic;
		clk_2: in std_logic;
		reset: in std_logic;
		en: in std_logic;
		--local input ports
		valid_in: in std_logic;
		ready_in: in std_logic;
		--local output ports
		data_out_q, data_out_i: out std_logic_vector(15 downto 0);
		ready_out: out std_logic;
		valid_out: out std_logic;
		--pingpong buffer inputs
		data_in: in std_logic_vector(0 downto 0)

		);
end component;
component FECencoderPhase2 is
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
end component;
begin

valid1Port <= valid1;
valid2Port <= valid2;
data1Port <= data1;
data2Port <= data2;

F_R:FECencoderPhase2
port map(
	clk=>clk,
	clk_100=>clk2,
	reset=>reset,
	en=>en,
	data_in=>data_in,
	ready_in=>ready1,
	valid_in=>valid_in,
	valid_out_port=>valid1,
	ready_out => ready_out,
	data_out=>data1
);
	

intrlv:interleaver_7
port map(

    clk=> clk2,
    reset=> reset,
    en=>en,
    data_in=> data1,
    ready_in=> ready2,
    valid_in=> valid1,
    valid_out=> valid2,
    ready_out=> ready1,
    data_out=> data2
	

);
QPSK:QPSK_enc_pll
port map(
	clk=>clk,
	reset=> reset,
	clk_2=>clk2,
    en=>en,
    data_in=> data2,
    ready_in=> ready_in,
    valid_in=> valid2,
    valid_out=> valid_out,
    ready_out=> ready2,
    data_out_q=> data_out_q,
	data_out_i=>data_out_i
);


end arc;