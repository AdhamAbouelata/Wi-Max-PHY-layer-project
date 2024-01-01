

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Tlv is
  port(
    clk:                        in std_logic;
    rst:                        in std_logic;
    en:                         in std_logic;
    pass:			out std_logic;
	 pass2: out std_logic;
	 pass3: out std_logic
  );
end entity Tlv;



architecture arc of Tlv is


signal data1next1: std_logic_vector(0 downto 0);
signal data1next2: std_logic_vector(0 downto 0);
signal data1next3: std_logic_vector(0 downto 0);
signal data2next1: std_logic_vector(0 downto 0);
signal data2next2: std_logic_vector(0 downto 0);
signal data2next3: std_logic_vector(0 downto 0);

signal  data_in:std_logic_vector(0 downto 0);

signal	data_out_q:std_logic_vector(15 downto 0);
signal	data_out_i:std_logic_vector(15 downto 0);
signal data_out_i_delayed: std_logic_vector(15 downto 0);
signal data_out_i_delayed2: std_logic_vector(15 downto 0);
signal data_out_q_delayed: std_logic_vector(15 downto 0);
signal	data_out_q_comp:std_logic_vector(15 downto 0);
signal	data_out_i_comp:std_logic_vector(15 downto 0);

signal clk_100: std_logic;
signal clk_2:std_logic;
signal reset_pll:std_logic;
signal reset:std_logic;
signal valid_out2: std_logic;
signal in_address:std_logic_vector(6 downto 0);
signal out_address:std_logic_vector(6 downto 0);
signal pass_inner: std_logic;
signal in_address_next:std_logic_vector(6 downto 0);
signal out_address_next:std_logic_vector(6 downto 0);
signal pass_counter: std_logic_vector(3 downto 0);
signal pass_counter_next: std_logic_vector(3 downto 0);
signal valid_out1: std_logic;
signal valid_in: std_logic;
signal ready_in: std_logic;
signal ready_out:std_logic;
signal valid_out3: std_logic;
signal valid1: std_logic;
signal valid2: std_logic;
signal data1: std_logic_vector (0 downto 0);
signal data2: std_logic_vector (0 downto 0);


signal valid8: std_logic;
signal valid3: std_logic;
signal valid4: std_logic;
signal valid5: std_logic;
signal valid6: std_logic;
signal out_address2:std_logic_vector(7 downto 0);
signal pass_inner2: std_logic;
signal out_address_next2:std_logic_vector(7 downto 0);
signal pass_counter2: std_logic_vector(3 downto 0);
signal pass_counter_next2: std_logic_vector(3 downto 0); 

signal out_address3:std_logic_vector(7 downto 0);
signal pass_inner3: std_logic;
signal out_address_next3:std_logic_vector(7 downto 0);
signal pass_counter3: std_logic_vector(3 downto 0);
signal pass_counter_next3: std_logic_vector(3 downto 0); 
signal data1comp: std_logic_vector (0 downto 0);
signal data2comp: std_logic_vector (0 downto 0);

component tl is
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
end component;

component pll_3 is
	port (
		refclk   : in  std_logic := '0'; --  refclk.clk
		rst      : in  std_logic := '0'; --   reset.reset
		outclk_0 : out std_logic;        -- outclk0.clk
		outclk_1 : out std_logic;        -- outclk1.clk
		locked   : out std_logic         --  locked.export
	);
end component;

component ROMQ_FINAL IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (6 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
END component;
component ROMI_FINAL IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (6 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
END component;

component PRBS_ROM IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (6 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
	);

END component;

component FEC_ROM is
port(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
);
end component;
component INTRLV_ROM is
port(
	address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
);
end component;

begin

reset_pll<= not rst;
--valid_out<=valid_out1;

ready_in <= '1';
T_L:Tl
port map(
	clk=>clk,
	clk2=>clk_100,
	reset=>reset,
	en=>en,
	data_in=>data_in,
	ready_in=>ready_in,
	valid_in=>valid_in,
	valid_out=>valid_out2,
	ready_out => ready_out,
	data1Port => data1,
	data2Port => data2,
	valid1Port => valid1,
	valid2Port => valid2,
	data_out_q=>data_out_q,
	data_out_i=>data_out_i
);
pll:pll_3
port map(
refclk =>clk,
rst => reset_pll,
outclk_0 =>clk_100,
outclk_1 =>clk_2,
locked=>reset
);


ROM_Q:ROMQ_FINAL
port map(
address=> out_address,
clock=>clk,
q=> data_out_q_comp

);

ROM_I:ROMI_FINAL
port map(
address=> out_address,
clock=>clk,
q=> data_out_i_comp

);



ROM_IN:PRBS_ROM
port map(
address=> in_address,
clock=>clk,
q=> data_in

);

ROM_FEC: FEC_ROM
port map(
address => out_address2,
clock => clk_100,
q => data1comp
);
ROM_INTRLV: INTRLV_ROM
port map(
address => out_address3,
clock => clk_100,
q => data2comp
);

process(clk_100, reset)
begin
if (reset = '0') then
	data1next1 <= (others => '0');
elsif(clk_100'event and clk_100 = '1' and en = '1') then
	data1next1 <= data1;
end if;
end process;

process(clk_100, reset)
begin
if (reset = '0') then
	data1next2 <= (others => '0');
elsif(clk_100'event and clk_100 = '1' and en = '1') then
	data1next2 <= data1next1;
end if;
end process;

process(clk_100, reset)
begin
if (reset = '0') then
	data1next3 <= (others => '0');
elsif(clk_100'event and clk_100 = '1' and en = '1') then
	data1next3 <= data1next2;
end if;
end process;

process(clk_100, reset)
begin
if (reset = '0') then
	data2next1 <= (others => '0');
elsif(clk_100'event and clk_100 = '1' and en = '1') then
	data2next1 <= data2;
end if;
end process;

process(clk_100, reset)
begin
if (reset = '0') then
	data2next2 <= (others => '0');
elsif(clk_100'event and clk_100 = '1' and en = '1') then
	data2next2 <= data2next1;
end if;
end process;

process(clk_100, reset)
begin
if (reset = '0') then
	data2next3 <= (others => '0');
elsif(clk_100'event and clk_100 = '1' and en = '1') then
	data2next3 <= data2next2;
end if;
end process;

process(clk, reset)
begin
if (reset = '0') then
	data_out_i_delayed <= (others => '0');
elsif(clk'event and clk = '1' and en = '1') then
	data_out_i_delayed <= data_out_i;
end if;
end process;

process(clk, reset)
begin
if (reset = '0') then
	data_out_q_delayed <= (others => '0');
elsif(clk'event and clk = '1' and en = '1') then
	data_out_q_delayed <= data_out_q;
end if;
end process;

process(clk, reset)
begin
if (reset = '0') then
	data_out_i_delayed2 <= (others => '0');
elsif(clk'event and clk = '1' and en = '1') then
	data_out_i_delayed2 <= data_out_i_delayed;
end if;
end process;

process(clk, reset)
begin
if (reset = '0') then
	valid_out1 <= '0';
elsif (clk'event and clk = '1' and en = '1') then
	valid_out1 <= valid_out2;
end if;
end process;

process(clk, reset)
begin
if (reset = '0') then
	valid_out3 <= '0';
elsif (clk'event and clk = '1' and en = '1') then
	valid_out3 <= valid_out2;
end if;
end process;
	
process(clk, reset)
begin
if (reset = '0') then
	pass_counter <= (others => '0');
elsif (clk'event and clk = '1' and en = '1') then
	pass_counter <= pass_counter_next;
end if;
end process;

process(clk, reset)
begin
if (reset = '0') then
	valid_in <= '0';
elsif (clk'event and clk = '1' and en = '1') then
	valid_in <= '1';
end if;
end process;


process(clk, reset)
begin
if (reset = '0') then
	valid3<= '0';
elsif (clk'event and clk = '1' and en = '1') then
	valid3 <= valid1;
end if;
end process;

process(clk, reset)
begin
if (reset = '0') then
	valid5<= '0';
elsif (clk'event and clk = '1' and en = '1') then
	valid5 <= valid3;
end if;
end process;

process(clk, reset)
begin
if (reset = '0') then
	valid4<= '0';
elsif (clk'event and clk = '1' and en = '1') then
	valid4 <= valid2;
end if;
end process;

process(clk_100, reset)
begin
if (reset = '0') then
	valid6<= '0';
elsif (clk_100'event and clk_100 = '1' and en = '1') then
	valid6 <= valid4;
end if;
end process;

process(clk_100, reset)
begin
if (reset = '0') then
	valid8<= '0';
elsif (clk_100'event and clk_100 = '1' and en = '1') then
	valid8 <= valid6;
end if;
end process;

process(pass_counter)
begin
if(pass_counter > "0001") then
	pass <= '1';
else
	pass <= '0';
end if;
end process;

process(pass_counter, pass_inner)
begin
if (pass_counter > "0001" or pass_inner = '0') then
	pass_counter_next <= pass_counter;
else 
	pass_counter_next <= std_logic_vector(unsigned(pass_counter)+1);
end if;
end process;

process(valid_out3, data_out_i_delayed, data_out_q_comp)
begin
	if ((data_out_i_delayed /= data_out_q_comp) and valid_out3 = '1') then
		pass_inner <= '1';
	else
		pass_inner <= '0';
end if;
end process;

process(clk,reset)
begin
if (reset='0') then
	in_address<="0000000";

elsif(rising_edge(clk)) then
	in_address<=in_address_next;
end if;
end process;

process(clk,reset)
begin
if (reset='0') then
	out_address<="0000000";
elsif(rising_edge(clk)) then
	out_address<=out_address_next;
end if;
end process;

process(valid_in,valid_out2,in_address,out_address,ready_in, ready_out)
begin

if(ready_out = '1')then

	if(in_address = "1011111")then
		in_address_next<="0000000";
	else
		in_address_next<=std_logic_vector(unsigned(in_address)+1);

	end if;	

	if(valid_out2 = '1'and ready_in ='1')then
		if(out_address = "1011111")then
			out_address_next<="0000000";
		else
			out_address_next<=std_logic_vector(unsigned(out_address)+1);
		end if;
	else
		out_address_next<=out_address;
	end if;


else
	out_address_next<=out_address;
	in_address_next<=in_address;
end if;
end process;

process(clk_2, reset)
begin
if (reset = '0') then
	pass_counter2 <= (others => '0');
elsif (clk_2'event and clk_2 = '1' and en = '1') then
	pass_counter2 <= pass_counter_next2;
end if;
end process;
process(pass_counter2)
begin
if(pass_counter2 > "0001") then
	pass2 <= '1';
else
	pass2 <= '0';
end if;
end process;

process(pass_counter2, pass_inner2)
begin
if (pass_counter2 > "0001" or pass_inner2 = '0') then
	pass_counter_next2 <= pass_counter2;
else 
	pass_counter_next2 <= std_logic_vector(unsigned(pass_counter2)+1);
end if;
end process;

process(valid3, data1next3, data1comp)
begin
	if ((data1next3 /= data1comp) and valid3 = '1') then
		pass_inner2 <= '1';
	else
		pass_inner2 <= '0';
end if;
end process;

process(clk_100,reset)
begin
if (reset='0') then
	out_address2<="00000000";
elsif(rising_edge(clk_100)) then
	out_address2<=out_address_next2;
end if;
end process;

process(valid3,out_address2, ready_out)
begin

if(ready_out = '1')then

	if(valid3 = '1')then
		if(out_address2 = "10111111")then
			out_address_next2<="00000000";
		else
			out_address_next2<=std_logic_vector(unsigned(out_address2)+1);
		end if;
	else
		out_address_next2<=out_address2;
	end if;


else
	out_address_next2<=out_address2;
end if;
end process;
process(clk_100, reset)
begin
if (reset = '0') then
	pass_counter3 <= (others => '0');
elsif (clk_100'event and clk_100 = '1' and en = '1') then
	pass_counter3 <= pass_counter_next3;
end if;
end process;
process(pass_counter3)
begin
if(pass_counter3 > "0001") then
	pass3 <= '1';
else
	pass3 <= '0';
end if;
end process;

process(pass_counter3, pass_inner3)
begin
if (pass_counter3 > "0001" or pass_inner3 = '0') then
	pass_counter_next3 <= pass_counter3;
else 
	pass_counter_next3 <= std_logic_vector(unsigned(pass_counter3)+1);
end if;
end process;

process(valid6, data2next3, data2comp)
begin
	if ((data2next3 /= data2comp) and valid6 = '1') then
		pass_inner3 <= '1';
	else
		pass_inner3 <= '0';
end if;
end process;

process(clk_100,reset)
begin
if (reset='0') then
	out_address3<="00000000";
elsif(rising_edge(clk_100)) then
	out_address3<=out_address_next3;
end if;
end process;

process(valid4,out_address3, ready_out)
begin

if(ready_out = '1')then

	if(valid4 = '1')then
		if(out_address3 = "10111111")then
			out_address_next3<="00000000";
		else
			out_address_next3<=std_logic_vector(unsigned(out_address3)+1);
		end if;
	else
		out_address_next3<=out_address3;
	end if;


else
	out_address_next3<=out_address3;
end if;
end process;
end arc;
