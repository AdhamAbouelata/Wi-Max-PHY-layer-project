
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity QPSK_enc_final is
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
		end QPSK_enc_final;
		
architecture QPSK_enc_arch of QPSK_enc_final is
	 
	
--state types of FSM
type state_type is (start_state,Buffer_switch, QPSKactive);
signal state_reg, state_next: state_type;
--2 Bit Register for reading input
signal QPSK_reg: std_logic_vector(1 downto 0);
--signals for pingpong buffer
signal bank_addr: std_logic;
signal bank_addr_next: std_logic;
signal bank_ptr: std_logic_vector(7 downto 0); --to address each individual bit of the enabled bank
signal bank_ptr_next: std_logic_vector(7 downto 0);
signal bank1: std_logic_vector (191 downto 0);
signal bank2: std_logic_vector (191 downto 0);
signal bank_done: std_logic_vector (7 downto 0);
signal valid_output: std_logic; 
begin


	--================
	--ping pong buffer
	--================
	process (clk_2, reset)
	begin
		if(reset = '0') then
			bank1<=(others => '0');
			bank2<=(others => '0');
		else 
			if(clk_2'event and clk_2 = '1' and valid_in = '1' and en = '1' and ready_in = '1') then
				if(bank_addr = '0') then
					bank2 <= data_in & bank2 (191 downto 1);
				else 
					bank1 <= data_in & bank1 (191 downto 1);
				end if;
			end if;
		end if;
	end process;
	-- bank pointer (counter)
	process(clk, reset)
	begin
		if(reset = '0') then
			bank_ptr <= (others => '0');
		elsif(clk'event and clk = '1' and en ='1' and valid_in = '1' and ready_in = '1') then
			bank_ptr <= bank_ptr_next;
		end if;
	end process;
	--flipping the banks everytime they're filled up
	process (clk,reset)
	begin
		if(reset = '0') then
			bank_addr <= '0';
		elsif(clk'event and clk = '1' and en = '1' and valid_in = '1' and ready_in = '1') then
			bank_addr <= bank_addr_next;
		end if;
	end process;
	process (bank_addr, state_next)
	begin	
		if(state_next = Buffer_switch) then
			bank_addr_next <= not(bank_addr);
		else
			bank_addr_next <= bank_addr;
		end if;
	end process;
	
	--=====================
	--ping pong buffer end	
	--=====================
	
	--=========
	--FSM Begin
	--=========
	
	--state registers
	process(clk, reset)
	begin
		if(reset = '0') then
			state_reg <= start_state;
		elsif(clk'event and clk = '1' and en = '1') then
			state_reg <= state_next;
		end if;
	end process;
	
	--next state logic
	process (state_reg, bank_ptr, ready_in)
	begin
		case state_reg is
			when Start_state =>
				if (bank_ptr = "10111110" and ready_in = '1') then
					state_next <= Buffer_switch;
				else
					state_next <= start_state;
				end if;
			when Buffer_switch =>
				state_next <= QPSKactive;
			when QPSKactive => 
				if(bank_ptr = "10111110") then
					state_next <= Buffer_switch;
				else
					state_next <= QPSKactive;
				end if;
			when others =>
				state_next <= Start_state;
		end case;
	end process;
			
	
	--state outputs
	process (state_reg, bank_ptr, QPSK_reg, bank_addr, bank1, bank2, valid_in, ready_in)
	begin
		case state_reg is
			when start_state =>
				if(ready_in = '1') then
					ready_out <= '1';
				else
					ready_out <= '0';
				end if;
				valid_out <= '0';
				valid_output <= '0';
				QPSK_reg <= (others => '0');
				if(bank_ptr = "10111110") then
					bank_ptr_next <= (others => '0');
				else 
					bank_ptr_next <= std_logic_vector(unsigned(bank_ptr)+2);
				end if;
				--QPSK_register_next <= QPSK_register;	
			when Buffer_switch =>
				
				if(valid_in = '1' and ready_in = '1') then
					valid_out <= '1';
					valid_output <= '1';
				else
					valid_out <= '0';
					valid_output<= '0';
				end if;
				if(ready_in = '1') then
					ready_out <= '1';
				else
					ready_out <= '0';
				end if;
			--	bank_ptr_next <= "00000000";
				if (bank_addr = '0') then
					QPSK_reg <= bank1(to_integer(unsigned(bank_ptr)+1)) & bank1(to_integer(unsigned(bank_ptr)));
				else 
					QPSK_reg <= bank2(to_integer(unsigned(bank_ptr)+1)) & bank2(to_integer(unsigned(bank_ptr)));
				end if;
				bank_ptr_next <= "00000010";
			--	if (bank_addr = '0') then
			when QPSKactive =>
				
				if(valid_in = '1' and ready_in = '1') then
					valid_out <= '1';
					valid_output <= '1';
				else 
					valid_out <= '0';
					valid_output <= '0';
				end if;
				if(ready_in = '1') then
					ready_out <= '1';
				else
					ready_out <= '0';
				end if;
				if (bank_ptr = "10111110") then
					bank_ptr_next <= (others => '0');
				else
					bank_ptr_next <= std_logic_vector(unsigned(bank_ptr)+2); 
				end if;
				if (bank_addr = '0') then
					QPSK_reg <= bank1(to_integer(unsigned(bank_ptr)+1)) & bank1(to_integer(unsigned(bank_ptr)));
				else 
					QPSK_reg <= bank2(to_integer(unsigned(bank_ptr)+1)) & bank2(to_integer(unsigned(bank_ptr)));
				end if;
				
				when others =>
				ready_out <= '1';
				valid_output <= '0';
				bank_ptr_next <= bank_ptr;
				valid_out <= '0';
			end case;
		end process;
		
	--==================	
	-- State machine end
	--==================
	
	
	
	--==================
	--QPSK encoder Begin
	--==================
	process(QPSK_reg, valid_output)
	begin
		if(valid_output = '1') then
					if(QPSK_reg(0) = '0') then
						data_out_q <= x"5A7F";
					else
						data_out_q <= x"A581";
					end if;
					if(QPSK_reg(1) = '0') then
					data_out_i <= x"5A7F";
					else
					data_out_i <= x"A581";
					end if;
		else
			data_out_q <= x"0000";
			data_out_i <= x"0000";
		end if;
	end process;
	
end QPSK_enc_arch;
				
		
		
		
		
		
		