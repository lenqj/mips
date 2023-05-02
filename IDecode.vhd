library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IDecode is
 Port (           
RegWrite : in STD_LOGIC;
Instruction : in STD_LOGIC_VECTOR(15 downto 0);
RegDst : in STD_LOGIC; 
CLK : in STD_LOGIC;         
EN : in STD_LOGIC;
ExtOp : in STD_LOGIC;
RD1 : out STD_LOGIC_VECTOR(15 downto 0);
RD2 : out STD_LOGIC_VECTOR(15 downto 0);
WD : in STD_LOGIC_VECTOR(15 downto 0);
Ext_Imm : out STD_LOGIC_VECTOR(15 downto 0);
func : out STD_LOGIC_VECTOR(2 downto 0);
sa : out STD_LOGIC);
end IDecode;

architecture Behavioral of IDecode is
signal MUX_OUT: std_logic_vector(2 downto 0);
type reg_array is array (0 to 7) of std_logic_vector(15 downto 0); 
signal reg_file : reg_array:=(others=>x"0000");
begin
    process(clk)
     begin
        if rising_edge(clk) then 
            if en = '1' and RegWrite = '1' then 
                reg_file(conv_integer(MUX_OUT)) <= WD;
            end if; 
        end if; 
     end process; 
     rd1 <= reg_file(conv_integer(Instruction(12 downto 10)));
     rd2 <= reg_file(conv_integer(Instruction(9 downto 7))); 
    MUX1: process (RegDst, Instruction(9 downto 7), Instruction(6 downto 4))
       begin
           case RegDst is
               when '0' => MUX_OUT <= Instruction(9 downto 7);
               when '1' => MUX_OUT <= Instruction(6 downto 4);
           end case;
       end process;
       
       ExtOprocces: process (ExtOp, Instruction(6 downto 0))
              begin
                  case ExtOp is
                      when '0' => Ext_Imm <= "000000000"&Instruction(6 downto 0);
                      when '1' => Ext_Imm <= Instruction(6)&Instruction(6)&Instruction(6)&Instruction(6)&Instruction(6)&Instruction(6)&Instruction(6)&Instruction(6)&Instruction(6)&Instruction(6 downto 0);

                  end case;
      end process;
    func <= Instruction(2 downto 0);
    sa <= Instruction(3);
end Behavioral;
