 library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	use work.packageForTB.all;
	entity QPSK_tb4 is

	end QPSK_tb4;


	architecture tb_arch of QPSK_tb4 is
	component QPSK_enc_pll
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
		end component QPSK_enc_pll;
	
	signal test_clk, test_rst: std_logic := '1';
	signal test_clk_2: std_logic := '1';
	signal test_enable, test_valid_in, test_ready_in: std_logic;
	signal test_out_q, test_out_i: std_logic_vector(15 downto 0);
	signal test_ready_out, test_valid_out: std_logic;
	signal test_din: std_logic_vector(0 downto 0);
	
	constant period : time := 20ns;
	constant period_2 : time := 10ns;
	
	signal gold_in: std_logic_vector(191 downto 0) := x"78BD6101ABF24590C5978A1A5840386FABA54F425FBE20D2";
	--signal gold_in: std_logic_vector(191 downto 0) := x"4B047DFA42F2A5D5F61C021A5851E9A309A24FD58086BD1E";
	signal gold_out_q: std_logic_vector(1535 downto 0):=x"A581A5815A7F5A7F5A7FA581A581A581A5815A7F5A7FA5815A7F5A7F5A7FA5815A7F5A7F5A7FA581A581A5815A7F5A7FA5815A7FA581A5815A7FA5815A7F5A7FA5815A7FA581A5815A7FA581A581A5815A7F5A7F5A7F5A7F5A7FA5815A7F5A7FA581A5815A7F5A7FA5815A7F5A7F5A7F5A7FA5815A7F5A7FA5815A7FA581A5815A7F5A7F5A7FA5815A7F5A7FA581A581A5815A7FA581A581A5815A7F5A7F5A7FA581A581A581A5815A7FA581A5815A7F5A7F5A7F5A7F5A7FA581A5815A7F5A7F";
	signal gold_out_i: std_logic_vector(1535 downto 0):=x"5A7FA581A5815A7FA581A581A5815A7F5A7FA5815A7F5A7F5A7F5A7F5A7F5A7FA581A581A581A581A581A5815A7FA5815A7F5A7F5A7F5A7FA5815A7F5A7F5A7FA5815A7F5A7F5A7FA5815A7F5A7FA581A5815A7FA581A5815A7F5A7FA581A5815A7F5A7FA5815A7F5A7F5A7F5A7F5A7F5A7FA581A5815A7F5A7FA581A581A581A581A581A581A581A581A5815A7F5A7F5A7F5A7FA581A5815A7F5A7F5A7FA5815A7F5A7FA581A581A581A581A581A5815A7FA5815A7F5A7FA5815A7F5A7FA581";
	signal ex_out: std_logic;	
	signal counter: integer:=15;
	
	begin

	uut: QPSK_enc_pll port map (clk => test_clk, clk_2 => test_clk_2, reset => test_rst, en => test_enable,
	valid_in => test_valid_in, ready_in => test_ready_in, ready_out => test_ready_out, valid_out => test_valid_out,
	data_in => test_din, data_out_q => test_out_q, data_out_i => test_out_i);

	
	test_clk <= not test_clk after period/2;
	test_clk_2 <= not test_clk_2 after period_2/2;
	
	process

	begin
	test_rst <= '0';
	test_valid_in <= '0';
	test_ready_in <= '1';
	test_enable <= '1';
	wait for 20 ns;
	test_rst <= '1';
	wait for 20 ns;
	test_valid_in <= '1';
	
	for i in 0 to 191 loop
		gold_in_data(gold_in(i downto i),test_din(0 downto 0));
		wait for period_2;
	end loop;
	test_valid_in <= '0';
	for i in 0 to 191 loop
		gold_in_data(gold_in(i downto i),test_din(0 downto 0));
		wait for period_2;
	end loop;
	test_valid_in <= '1';
	for i in 0 to 191 loop
		gold_in_data(gold_in(i downto i),test_din(0 downto 0));
		wait for period_2;
	end loop;
	wait;
	end process;
	
	process
	begin
	--wait until (test_valid_out = '1');
	wait for 1962 ns;
	for i in 0 to 95 loop
		gold_out_data_qpsk(gold_out_q(counter downto (counter-15)), test_out_q(15 downto 0));
		gold_out_data_qpsk(gold_out_i(counter downto (counter-15)), test_out_i(15 downto 0));
		counter <= counter + 16;
		if (i = 95) then
		counter <= 15;
		end if;
		wait for period;
	end loop;
	--counter <= 15;
	for i in 0 to 95 loop
		gold_out_data_qpsk(gold_out_q(counter downto (counter-15)), test_out_q(15 downto 0));
		gold_out_data_qpsk(gold_out_i(counter downto (counter-15)), test_out_i(15 downto 0));
		counter <= counter + 16;
		wait for period;
	end loop;
	wait;
	end process;
end tb_arch;
	
	
	
	
	