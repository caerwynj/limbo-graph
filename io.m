GraphIO: module
{
	PATH:	con	"/dis/lib/graphio.dis";

	init:	fn(sys_mod: Sys, bufio_mod: Bufio);
	
	gb_raw_open: fn(f: string): int;
	gb_open: fn(f: string): int;
	gb_close: fn(): int;
	gb_raw_close: fn(): int;
	status: fn(): int;
	
	gb_newline: fn();
	gb_char: fn(): int;
	gb_backup: fn();
	gb_digit: fn(d: int): int;
	gb_number: fn(d: int): big; # using big for potential large numbers, though SGB uses long (32-bit)
	gb_string: fn(c: int): string;
	
	gb_eof: fn(): int;
	
	new_checksum: fn(s: string, old_checksum: int): int;
	
	# Error codes
	cant_open_file: con 16r1;
	cant_close_file: con 16r2;
	bad_first_line: con 16r4;
	bad_second_line: con 16r8;
	bad_third_line: con 16r10;
	bad_fourth_line: con 16r20;
	file_ended_prematurely: con 16r40;
	missing_newline: con 16r80;
	wrong_number_of_lines: con 16r100;
	wrong_checksum: con 16r200;
	no_file_open: con 16r400;
	bad_last_line: con 16r800;
	
	unexpected_char: con 127;
};
