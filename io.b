implement GraphIO;

include "sys.m";
	sys: Sys;
	print, sprint: import sys;
include "bufio.m";
	bufio: Bufio;
	Iobuf: import bufio;
include "io.m";

# Global state mirroring sgb/gb_io.c
io_errors: int;
magic: int;
line_no: int;
final_magic: int;
tot_lines: int;
more_data: int;

buffer: string; # Current line buffer
cur_pos: int;   # Current position in buffer
cur_file: ref Iobuf;
file_name: string;

checksum_prime: con (1<<30) - 83;
imap: con "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_^~&@,;.:?!%#$+-*/|\\<=>()[]{}`'\" \n";
icode: array of int;

init(sys_mod: Sys, bufio_mod: Bufio)
{
	sys = sys_mod;
	bufio = bufio_mod;
	icode_setup();
}

icode_setup()
{
	if (icode != nil) return;
	icode = array[256] of { * => unexpected_char };
	for (i := 0; i < len imap; i++)
		icode[imap[i]] = i;
}

imap_ord(c: int): int
{
	if (c < 0 || c > 255) return unexpected_char;
	return icode[c];
}

new_checksum(s: string, old_checksum: int): int
{
	a := old_checksum;
	for (i := 0; i < len s; i++) {
		a = (a + a + imap_ord(s[i])) % checksum_prime;
	}
	return a;
}

fill_buf()
{
	if (cur_file == nil) return;
	
	s := cur_file.gets('\n');
	if (s == nil) {
		io_errors |= file_ended_prematurely;
		buffer = "";
		more_data = 0;
		return;
	}
	
	# Check for trailing newline
	if (len s > 0 && s[len s - 1] == '\n') {
		# Remove trailing blanks before newline
		check_len := len s - 1;
		while (check_len > 0 && s[check_len-1] == ' ')
			check_len--;
		
		# Create new canonical string with newline and null equivalent? 
		# SGB uses explicit null at end of buffer. Limbo strings are safe.
		# We just keep the string up to check_len and append \n
		buffer = s[0:check_len] + "\n";
	} else {
		io_errors |= missing_newline;
		# SGB appends \n\0 anyway.
		buffer = s + "\n";
	}
	cur_pos = 0;
}

gb_newline()
{
	line_no++;
	if (line_no > tot_lines) more_data = 0;
	if (more_data) {
		fill_buf();
		if (len buffer == 0) return; 
		if (buffer[0] != '*')
			magic = new_checksum(buffer, magic);
	}
}

gb_raw_open(f: string): int
{
	if (icode == nil) icode_setup();
	
	cur_file = bufio->open(f, Bufio->OREAD);
	if (cur_file != nil) {
		io_errors = 0;
		more_data = 1;
		line_no = 0;
		magic = 0;
		tot_lines = 16r7fffffff;
		fill_buf();
	} else {
		io_errors = cant_open_file;
	}
	return io_errors;
}

gb_open(f: string): int
{
	file_name = f;
	gb_raw_open(f);
	if (cur_file != nil) {
		# Check header lines
		s := sprint("* File \"%s\"", f);
		# Line 1
		if (len buffer < len s || buffer[0:len s] != s)
			return (io_errors |= bad_first_line);
		
		# Line 2
		gb_newline();
		if (len buffer == 0 || buffer[0] != '*') return (io_errors |= bad_second_line);
		
		# Line 3
		gb_newline();
		if (len buffer == 0 || buffer[0] != '*') return (io_errors |= bad_third_line);
		
		# Line 4
		gb_newline();
		prefix := "* (Checksum parameters ";
		if (len buffer < len prefix || buffer[0:len prefix] != prefix)
			return (io_errors |= bad_fourth_line);
			
		cur_pos = len prefix;
		tot_lines = int gb_number(10);
		if (gb_char() != ',') return (io_errors |= bad_fourth_line);
		final_magic = int gb_number(10);
		if (gb_char() != ')') return (io_errors |= bad_fourth_line);
		
		gb_newline(); # Load first data line
	}
	return io_errors;
}

gb_close(): int
{
	if (cur_file == nil) return (io_errors |= no_file_open);
	
	gb_newline(); # Should read end of file line
	s := sprint("* End of file \"%s\"", file_name);
	if (len buffer < len s || buffer[0:len s] != s)
		io_errors |= bad_last_line;
		
	more_data = 0;
	cur_pos = 0;
	cur_file.close();
	cur_file = nil;
	
	if (line_no != tot_lines + 1)
		io_errors |= wrong_number_of_lines;
	if (magic != final_magic)
		io_errors |= wrong_checksum;
		
	return io_errors;
}

gb_raw_close(): int
{
	if (cur_file != nil) {
		cur_file.close();
		cur_file = nil;
		more_data = 0;
		cur_pos = 0;
	}
	return magic;
}

status(): int
{
	return io_errors;
}


gb_char(): int
{
	if (cur_pos < len buffer) {
		c := buffer[cur_pos];
		cur_pos++;
		return c;
	}
	return '\n';
}

gb_backup()
{
	if (cur_pos > 0) cur_pos--;
}

gb_digit(d: int): int
{
	if (cur_pos >= len buffer) return -1;
	c := buffer[cur_pos];
	ord := imap_ord(c);
	if (ord < d) {
		cur_pos++;
		return ord;
	}
	return -1;
}

gb_number(d: int): big
{
	a := big 0;
	if (cur_pos >= len buffer) return a;
	
	while (cur_pos < len buffer) {
		ord := imap_ord(buffer[cur_pos]);
		if (ord < d) {
			a = a * big d + big ord;
			cur_pos++;
		} else {
			break;
		}
	}
	return a;
}

gb_string(c: int): string
{
	s := "";
	while (cur_pos < len buffer) {
		ch := buffer[cur_pos];
		if (ch == c) break;
		s[len s] = ch;
		cur_pos++;
	}
	if (cur_pos < len buffer) cur_pos++; # Skip delimiter
	return s;
}

gb_eof(): int
{
	return !more_data;
}
