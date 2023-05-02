library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IFETCH is
    Port ( 
           Jump : in STD_LOGIC;
           JumpAdr : in STD_LOGIC_VECTOR (15 downto 0);
           PCSrc : in STD_LOGIC;
           BranchAdr : in STD_LOGIC_VECTOR (15 downto 0);
           en : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           PCnext : out STD_LOGIC_VECTOR (15 downto 0);
           Instruction : out STD_LOGIC_VECTOR (15 downto 0));
end IFETCH;

architecture Behavioral of IFETCH is

signal jumpMUX, branchMUX, PC: STD_LOGIC_VECTOR (15 downto 0);
type ROM is array(0 to 31) of std_logic_vector(15 downto 0);
signal MEM: ROM :=(

B"000_000_000_001_0_000",  --  0  add  $1, $0, $0  X"0010" 
B"001_010_000_0000101",    --  1  addi $2, $0, 5   X"2805" 
B"000_000_000_011_0_000",  --  2  add  $3, $0, $0  X"0030" 
B"000_000_000_100_0_000",  --  3  add  $4, $0, $0  X"0040" 
B"100_001_010_0000110",    --  4  beq  $2, $1, 6   X"8506" 
B"010_011_101_0000000",    --  5  lw   $5, 0($3)   X"4E80" 
B"000_100_100_101_0_000",  --  6  add  $4, $4, $5  X"1250"
B"011_011_101_0000000",    --  7  sw   $5, 0($3)   X"6E80" 
B"001_011_011_0000001",    --  8  addi $3, $3, 1   X"2D81" 
B"001_001_001_0000001",    --  9  addi $1, $1, 1   X"2481"
B"111_0000000000100",      --  10 j    4     	   X"E005"
B"000_100_010_100_0_111",  --  11 sllv $4, $4, 2   X"1147"
B"011_011_100_0000000",    --  12 sw   $4, 0($3)   X"6E00"
    others=>x"0000");
    

begin

PCnext <= PC + 1;
Instruction<=MEM(conv_integer(PC(3 downto 0)));


 BMUX : process (PCSrc, BranchAdr, PC)
    begin
        case PCSrc is
            when '1' => branchMUX <= BranchAdr;
            when others => branchMUX <= PC + 1;
        end case;
    end process;
 JMUX : process (Jump, JumpAdr, branchMUX)
        begin
            case Jump is
                when '1' => jumpMUX <= JumpAdr;
                when others => jumpMUX <= branchMUX;
            end case;
        end process;

 process (clk)
           begin
           if rising_edge(clk) then
             if RST='1' then
                   PC <= x"0000";
                 elsif EN='1'then
                   PC <= jumpMUX;
                 end if;
              end if;
  end process;
end Behavioral;
