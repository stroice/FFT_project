
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;


package Components is

function bits (L: INTEGER) return INTEGER; -- Given a positive integer number, it returns the number of bits needed to represent it in unsinged.
function nextPow2 (L: INTEGER) return INTEGER; -- Given an integer number, it returns the smallest power of 2 that is larger than that integer. 
function bitSwap(L, B, B0, B1: INTEGER) return INTEGER; -- Given an integer L, it swaps the bits B0 and B1. B is the number of bits of L.

function min(L, R: INTEGER) return INTEGER; 
function max(L, R: INTEGER) return INTEGER; 

function min(L, R: REAL) return REAL; 
function max(L, R: REAL) return REAL; 

function isEqual(A, B: INTEGER) return INTEGER;	
function isOdd(A: INTEGER) return INTEGER;      
function isEven(A: INTEGER) return INTEGER;       

type databus is array (integer range <>, integer range <>) of std_logic;

end Components;

--------------
---- BODY ----
--------------

package body Components is

function bits (L: INTEGER) return INTEGER is
begin
	for i in 0 to 100 loop
		if L < 2**i then
			return i;
		end if;
	end loop;
	
	return -1;
end;

function nextPow2 (L: INTEGER) return INTEGER is
begin
	if L = 0 then
		return 0; 
	end if;
	
	for i in 0 to 100 loop
		if L < 2**i +1 then
			return 2**i;
		end if;
	end loop;
	
	return -1;
end;


function bitSwap(L, B, B0, B1: INTEGER) return INTEGER is
	variable Lbin : unsigned(B-1 downto 0);
	variable C: std_logic;
begin
	Lbin := to_unsigned(L,B);
	C := Lbin(B0);
	Lbin(B0) := Lbin(B1);
	Lbin(B1) := C;
	return to_integer(Lbin);
end;


function min(L, R: INTEGER) return INTEGER is
begin
	if L < R then
	    return L;
	else
	    return R;
	end if;
end;

function max(L, R: INTEGER) return INTEGER is
begin
	if L < R then
	    return R;
	else
	    return L;
	end if;
end;


function min(L, R: REAL) return REAL is
begin
	if L < R then
	    return L;
	else
	    return R;
	end if;
end;

function max(L, R: REAL) return REAL is
begin
	if L < R then
	    return R;
	else
	    return L;
	end if;
end;


function isEqual(A, B: INTEGER) return INTEGER is
begin 
	if A = B	then
		return 1;
	else
		return 0;
	end if;
end;


function isOdd(A: INTEGER) return INTEGER is
	variable I: real;
begin 
   
   I:= real(A)/real(2);
   
   if floor(I) = I then	-- Vale asi porque A es un numero entero.
      return 0; -- es par, no impar
   else 
      return 1;
   end if;
end;

function isEven(A: INTEGER) return INTEGER is
begin 
	return 1 - isOdd(A);
end;


end Components;
