library work;
use work.math_real.all;

package body my_package is

	function n_bits_of (X : in integer) return integer is
	begin
  
		return integer(ceil(log2(real(X))));

	end function n_bits_of;

end package body my_package;
