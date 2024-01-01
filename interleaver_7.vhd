library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interleaver_7 is
  port(
    clk:                        in std_logic;
    reset:                      in std_logic;
    en:                         in std_logic;
    data_in:                    in std_logic_vector(0 downto 0);
    ready_in:                   in std_logic;
    valid_in:                   in std_logic;
    valid_out:                  out std_logic;
    ready_out:                  out std_logic;
    data_out:                   out std_logic_vector(0 downto 0)
  );
end entity interleaver_7;

architecture arch of interleaver_7 is

  signal Ncbs_over_d:           std_logic_vector (7 downto 0); 
  signal d:                     std_logic_vector (7 downto 0); 
  
  type state_type is (IDLE,ITERLEAVING_LITE,SWITCHING, INTERLEAVING);
  
  signal state, state_next:     state_type;
  
  
 

signal counter:                 std_logic_vector(7 downto 0);
signal late_counter:                 std_logic_vector(7 downto 0);
signal intrlv_ctr:              std_logic_vector(1 downto 0);
signal RAM_select:              std_logic; 

signal wr_bit:                  std_logic_vector(0 downto 0);
signal rd_bit:                  std_logic_vector(0 downto 0);
signal wr_ad:                   std_logic_vector(7 downto 0);
signal rd_ad:                   std_logic_vector(7 downto 0);
signal wr_en:                   std_logic;
signal rd_en:                   std_logic;

signal wr_bit2:                 std_logic_vector(0 downto 0);
signal rd_bit2:                 std_logic_vector(0 downto 0);
signal wr_ad2:                  std_logic_vector(7 downto 0);
signal rd_ad2:                  std_logic_vector(7 downto 0);
signal wr_en2:                  std_logic;
signal rd_en2:                  std_logic;

signal wr_bit3:                 std_logic_vector(0 downto 0);
signal rd_bit3:                 std_logic_vector(0 downto 0);
signal wr_ad3:                  std_logic_vector(7 downto 0);
signal rd_ad3:                  std_logic_vector(7 downto 0);
signal wr_en3:                  std_logic;
signal rd_en3:                  std_logic;

signal wr_bit4:                 std_logic_vector(0 downto 0);
signal rd_bit4:                 std_logic_vector(0 downto 0);
signal wr_ad4:                  std_logic_vector(7 downto 0);
signal rd_ad4:                  std_logic_vector(7 downto 0);
signal wr_en4:                  std_logic;
signal rd_en4:                  std_logic;



signal delay_in,delay_in2:      std_logic_vector(0 downto 0);
signal intrlv_ctr_next:         std_logic_vector(1 downto 0);
signal counter_next:            std_logic_vector(7 downto 0);
signal late_counter_next:            std_logic_vector(7 downto 0);

signal RAM_select_next:         std_logic;
signal switching_tmr:           std_logic_vector(1 downto 0);
signal valid_out_next:		std_logic;
signal valid_out1:		std_logic;
component RAM2P IS
	PORT
	(
		clock		:           IN STD_LOGIC;
		data		:           IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		rdaddress   :           IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rden		:           IN STD_LOGIC;
		wraddress	:           IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		:           IN STD_LOGIC;
		q		    :           OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
	);
END component;


begin

Ram1:RAM2P
port map(
clock=>clk,
data=>wr_bit,
q=>rd_bit,
rdaddress=>rd_ad,
rden=>rd_en,
wren=>wr_en,
wraddress=>wr_ad

);
Ram2:RAM2P
port map(
clock=>clk,
data=>wr_bit2,
q=>rd_bit2,
rdaddress=>rd_ad2,
rden=>rd_en2,
wren=>wr_en2,
wraddress=>wr_ad2

);
Ram3:RAM2P
port map(
clock=>clk,
data=>wr_bit3,
q=>rd_bit3,
rdaddress=>rd_ad3,
rden=>rd_en3,
wren=>wr_en3,
wraddress=>wr_ad3

);
Ram4:RAM2P
port map(
clock=>clk,
data=>wr_bit4,
q=>rd_bit4,
rdaddress=>rd_ad4,
rden=>rd_en4,
wren=>wr_en4,
wraddress=>wr_ad4

);

   -- state registers
    process (clk, reset)
    begin
        if (reset = '0') then
            state <= IDLE;
			  
        else
            if (rising_edge(clk) and en = '1') then
                state <= state_next; 
            end if;
        end if;
    end process;
	 
	Ncbs_over_d <="00001100";
	d<="00010000";
	 
      process (state,intrlv_ctr,valid_in,counter)
    begin
        case state is
            when IDLE => -- RESET_state state next state logic
                if (valid_in = '1') then
                    state_next <= SWITCHING;
                else
                    state_next <= IDLE;
                end if;
					 
	when ITERLEAVING_LITE=>
                        if(counter = "10111111") then
						    state_next<=SWITCHING;
					else
						state_next<=ITERLEAVING_LITE;
					end if;
            when INTERLEAVING => --movingup next state logic\
			if(counter = "10111111")then
			state_next<=SWITCHING;
			ELSE
                    state_next <= INTERLEAVING;
	
			end if;
	    when SWITCHING =>
		if(counter = "00000001") then
			if(intrlv_ctr = "10") then
				state_next <= INTERLEAVING;
			else
				state_next<=ITERLEAVING_LITE;
			end if;
		else
		state_next <=SWITCHING;
		end if;
		
            when others => 
                state_next <= IDLE; 
        end case;
    end process;
	
	process(clk, reset)
	begin
		if (reset = '0') then
			late_counter <= (others => '0');
		elsif(clk'event and clk = '1' and en = '1') then
			late_counter <= late_counter_next;
		end if;
	end process;
	
	process(clk, reset)
	begin
		if (reset = '0') then
			counter <= (others => '0');
		elsif (clk'event and clk = '1' and en = '1') then
			counter <= counter_next;
		end if;
	end process;

	process(clk, reset)
	begin
		if (reset = '0') then
			intrlv_ctr <= (others => '0');
		elsif (clk'event and clk = '1' and en = '1') then
			intrlv_ctr <= intrlv_ctr_next;
		end if;
	end process;
	
	process(clk, reset)
	begin
		if (reset = '0') then
			RAM_select <= '0';
		elsif (clk'event and clk = '1' and en = '1') then
			RAM_select <= RAM_select_next;
		end if;
	end process;

	process(clk, reset)
	begin
		if (reset = '0') then
			valid_out1 <= '0';
		elsif (clk'event and clk = '1' and en = '1') then
			valid_out1 <= valid_out_next;
		end if;
	end process;

	valid_out<=valid_out1;

     -- state outputs
    process (state,valid_in,valid_out1,ready_in ,counter, late_counter, intrlv_ctr, RAM_select, d, Ncbs_over_d, data_in, rd_bit, rd_bit2, rd_bit3, rd_bit4,valid_out_next)
    begin
	 --if rising_edge(clk)  then		
        case state is
            when IDLE =>
                ready_out <= '1';
		
                valid_out_next <= '0';
		data_out<="0";
		
						 late_counter_next<=late_counter;	
					 counter_next<= counter;
					 intrlv_ctr_next<= intrlv_ctr;

				    RAM_select_next<=RAM_select;
							rd_en<='0';
							wr_en<='0';
							wr_en2<='0';
							rd_en2<='0';
							wr_en3<='0';					
							rd_en3<='0';
							wr_en4<='0';
							rd_en4<='0';

							rd_ad<="00000000";	
							rd_ad2<="00000000";
							rd_ad3<="00000000";
							rd_ad4<="00000000";
							
							wr_ad<="00000000";	
							wr_ad2<="00000000";
							wr_ad3<="00000000";
							wr_ad4<="00000000";
							
							wr_bit<="0";
							wr_bit2<="0";
							wr_bit3<="0";
							wr_bit4<="0";

	when ITERLEAVING_LITE=>
		

                
		ready_out <= '1';
                valid_out_next <= '0';
							data_out<="0";
							
	
					 if(valid_in = '1' ) then
							
							
                        if(counter ="10111111")then
							counter_next <= (others =>'0');
							RAM_select_next<= not RAM_select;
							late_counter_next <=std_logic_vector(unsigned(late_counter)+1);
							if(intrlv_ctr < "10") then
								intrlv_ctr_next <= std_logic_vector(unsigned(intrlv_ctr)+1);
							else
								intrlv_ctr_next <= intrlv_ctr;
							end if;
						else
							counter_next <= std_logic_vector(unsigned(counter) + 1);
							RAM_select_next<= RAM_select;
							late_counter_next<= std_logic_vector(unsigned(late_counter) + 1);
							intrlv_ctr_next <= intrlv_ctr;
						end if;
					    	if(RAM_select = '0') then

							rd_en<='1';
							wr_en<='0';
							wr_en2<='1';
							rd_en2<='0';
							
								rd_ad <= counter;
							wr_ad2 <= counter;
							
							wr_bit2<=data_in;
							
							rd_ad2<="00000000";
							
							
							wr_ad<="00000000";	
							
							wr_bit<="0";
							
							
							wr_en3<='1';					
							rd_en3<='0';
							wr_en4<='0';
							rd_en4<='0';
							wr_ad3<= std_logic_vector(to_unsigned(to_integer(unsigned(Ncbs_over_d)) * to_integer(unsigned(late_counter) rem unsigned(d)) +to_integer(unsigned(late_counter)/to_integer(unsigned(d))),wr_ad3'length)    );
							
							wr_bit3<=rd_bit;
							
							rd_ad4<="00000000";
							rd_ad3<="00000000";
							wr_ad4<="00000000";
							wr_bit4<="0";
							
                                
                   
							else
							
							rd_en<='0';
							wr_en<='1';
							wr_en2<='0';
							rd_en2<='1';
							
							rd_ad2 <= counter;
							wr_ad <= counter;
							

							wr_bit<=data_in;
							
							

							
							rd_ad<="00000000";	
							
							
							wr_ad2<="00000000";
							
							
							wr_bit2<="0";
							
							
							
							wr_en3<='0';					
							rd_en3<='0';
							wr_en4<='1';
							rd_en4<='0';
							wr_ad4<= std_logic_vector(to_unsigned(to_integer(unsigned(Ncbs_over_d)) * to_integer(unsigned(late_counter) rem unsigned(d)) +to_integer(unsigned(late_counter)/to_integer(unsigned(d))),wr_ad4'length)    );
							wr_bit4<=rd_bit2;
							rd_ad4<="00000000";
							wr_ad3<="00000000";
							wr_bit3<="0";
							
							
							rd_ad3<="00000000";
							
                                

		
							
              
                    end if;
							else
						
							late_counter_next<=late_counter;	
					 counter_next<= counter;
					 intrlv_ctr_next<= intrlv_ctr;

				    RAM_select_next<=RAM_select;
							rd_en<='0';
							wr_en<='0';
							wr_en2<='0';
							rd_en2<='0';
							wr_en3<='0';					
							rd_en3<='0';
							wr_en4<='0';
							rd_en4<='0';

							rd_ad<="00000000";	
							rd_ad2<="00000000";
							rd_ad3<="00000000";
							rd_ad4<="00000000";
							
							wr_ad<="00000000";	
							wr_ad2<="00000000";
							wr_ad3<="00000000";
							wr_ad4<="00000000";
							
							wr_bit<="0";
							wr_bit2<="0";
							wr_bit3<="0";
							wr_bit4<="0";


							
							

					        end if;
				

            				when INTERLEAVING =>
		 if(ready_in = '1')then
		ready_out <= '1';
		else
		ready_out<='0';
		end if;
					

		
					
			if(valid_in = '1' and ready_in = '1') then
                        	valid_out_next<='1';
						
			if(counter ="10111111")then
				counter_next <= (others =>'0');
				RAM_select_next<= not RAM_select;
				late_counter_next<=std_logic_vector(unsigned(late_counter)+1);
					intrlv_ctr_next <= intrlv_ctr;
				
			else
				counter_next <= std_logic_vector(unsigned(counter) + 1);
				RAM_select_next<= RAM_select;
				late_counter_next<= std_logic_vector(unsigned(late_counter) + 1);
				intrlv_ctr_next <= intrlv_ctr;
			end if;
				
		
					
							if(RAM_select = '0') then
							rd_en<='1';
							wr_en<='0';
							wr_en2<='1';
							rd_en2<='0';
							
							
							rd_ad <= counter;
							wr_ad2 <= counter;
							

							wr_bit2<=data_in;
							wr_bit3<=rd_bit;
							
								
							rd_ad2<="00000000";
							
							
							wr_ad<="00000000";	
							
							wr_bit<="0";
							
							
							wr_en3<='1';					
							rd_en3<='0';
							wr_en4<='0';
							rd_en4<='1';
							wr_ad3<= std_logic_vector(to_unsigned(to_integer(unsigned(Ncbs_over_d)) * to_integer(unsigned(late_counter) rem unsigned(d)) +to_integer(unsigned(late_counter)/to_integer(unsigned(d))),wr_ad3'length)    );
							rd_ad4<=late_counter;
							if(late_counter="00000000"or late_counter="00000001") then
							data_out<=rd_bit3;
							else
							data_out<=rd_bit4;
							end if;
							rd_ad3<="00000000";
							wr_ad4<="00000000";
							wr_bit4<="0";

							
                                

		
							
							else
							rd_en<='0';
							wr_en<='1';
							wr_en2<='0';
							rd_en2<='1';
							
							
							rd_ad2 <= counter;
							wr_ad <= counter;
							

							wr_bit<=data_in;
							
							
							rd_ad<="00000000";	
							
							
							wr_ad2<="00000000";
							
							
						
							wr_bit2<="0";
							
							
							wr_en3<='0';					
							rd_en3<='1';
							wr_en4<='1';
							rd_en4<='0';
							wr_bit4<=rd_bit2;
							wr_ad4<= std_logic_vector(to_unsigned(to_integer(unsigned(Ncbs_over_d)) * to_integer(unsigned(late_counter) rem unsigned(d)) +to_integer(unsigned(late_counter)/to_integer(unsigned(d))),wr_ad3'length)    );
							rd_ad3<=late_counter;
							if(late_counter="00000000"or late_counter="00000001") then
							data_out<=rd_bit4;
							else
							data_out<=rd_bit3;
							end if;
							rd_ad4<="00000000";
							wr_ad3<="00000000";
							wr_bit3<="0";

							
							
							end if;
						
							

					

        
					else
					valid_out_next <= '0';
					late_counter_next<=late_counter;	
					 counter_next<= counter;
					 intrlv_ctr_next<= intrlv_ctr;

				    RAM_select_next<=RAM_select;
							rd_en<='0';
							wr_en<='0';
							wr_en2<='0';
							rd_en2<='0';
							wr_en3<='0';					
							rd_en3<='0';
							wr_en4<='0';
							rd_en4<='0';

							rd_ad<="00000000";	
							rd_ad2<="00000000";
							rd_ad3<="00000000";
							rd_ad4<="00000000";
							
							wr_ad<="00000000";	
							wr_ad2<="00000000";
							wr_ad3<="00000000";
							wr_ad4<="00000000";
							
							wr_bit<="0";
							wr_bit2<="0";
							wr_bit3<="0";
							wr_bit4<="0";

							data_out<="0";
							
end if;

			when SWITCHING	=>
				
			       if(ready_in = '0')then
				ready_out <= '0';
				else
				ready_out<='1';
				end if;
				  intrlv_ctr_next<= intrlv_ctr;

				 RAM_select_next<=RAM_select;
            if(valid_in = '1' and ready_in = '1') then
            
				valid_out_next <= valid_out1;
				
				counter_next<=std_logic_vector(unsigned(counter)+1);
				if(counter="00000001")then
				late_counter_next<=(others=>'0');
				else
				late_counter_next<=std_logic_vector(unsigned(late_counter)+1);
				end if;
                    if(RAM_select = '0') then
			
                    rd_en<='1';
                    wr_en<='0';
                    wr_en2<='1';
                    rd_en2<='0';
                   
                    
                    rd_ad <= counter;
                    wr_ad2 <= counter;
                   

                    wr_bit2<=data_in;
                    

                        
                    rd_ad2<="00000000";
                  
                    
                    wr_ad<="00000000";	
                    
                    wr_bit<="0";
                    
    
							 wr_en3<='0';					
                   					 rd_en3<='1';
                    					wr_en4<='1';
                   					 rd_en4<='0';
							wr_ad4<= std_logic_vector(to_unsigned(to_integer(unsigned(Ncbs_over_d)) * to_integer(unsigned(late_counter) rem unsigned(d)) +to_integer(unsigned(late_counter)/to_integer(unsigned(d))),wr_ad3'length)    );
							
							wr_bit4<=rd_bit2;
							rd_ad3<=late_counter;
							data_out<=rd_bit3;
							rd_ad4<="00000000";
							wr_ad3<="00000000";
							wr_bit3<="0";
							 
                    
                    else
                    rd_en<='0';
                    wr_en<='1';
                    wr_en2<='0';
                    rd_en2<='1';
                    
                    
                    rd_ad2 <= counter;
                    wr_ad <= counter;
                     
                    wr_bit<=data_in;
                    
			
                    rd_ad<="00000000";	
                    
                
                    
                
                    wr_ad2<="00000000";
                   
                
                    
                
                    wr_bit2<="0";
                   
               
							wr_en3<='1';					
                    					rd_en3<='0';
                    						wr_en4<='0';
                    					rd_en4<='1';
							wr_ad3<= std_logic_vector(to_unsigned(to_integer(unsigned(Ncbs_over_d)) * to_integer(unsigned(late_counter) rem unsigned(d)) +to_integer(unsigned(late_counter)/to_integer(unsigned(d))),wr_ad3'length)    );
							
							wr_bit3<=rd_bit;
							rd_ad4<=late_counter;
							data_out<=rd_bit4;
							rd_ad3<="00000000";
							wr_ad4<="00000000";
							wr_bit4<="0";
							
                    
                    end if;
               
                   
                    

            


            else
			valid_out_next <= '0';
			late_counter_next<=late_counter;	
					 counter_next<= counter;
					 intrlv_ctr_next<= intrlv_ctr;

				    RAM_select_next<=RAM_select;
                    rd_en<='0';
                    wr_en<='0';
                    wr_en2<='0';
                    rd_en2<='0';
                    wr_en3<='0';					
                    rd_en3<='0';
                    wr_en4<='0';
                    rd_en4<='0';

                    rd_ad<="00000000";	
                    rd_ad2<="00000000";
                    rd_ad3<="00000000";
                    rd_ad4<="00000000";
                    
                    wr_ad<="00000000";	
                    wr_ad2<="00000000";
                    wr_ad3<="00000000";
                    wr_ad4<="00000000";
                    
                    wr_bit<="0";
                    wr_bit2<="0";
                    wr_bit3<="0";
                    wr_bit4<="0";

                    data_out<="0";
                  
end if;
end case;
		--end if; -- end if;
    end process;

end architecture arch;

