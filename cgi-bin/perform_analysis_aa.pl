#!/usr/bin/perl -T

use strict;
use warnings;
use CGI qw( :all -utf8 );

my $sequence = param( 'seka' );
my $final_seq;
my $unfiltered_seq;
my $each_aa_count;

sub find_length ( $@ ) {
	
	my $seq = shift ( @_ );
	my $seq_length;
	
	if ( $seq eq "Seka nepateikta!" ) {
		$seq_length = $seq;
	}
	
	elsif ( $seq !~ /^([ACDEFGHIKLMNPQRSTVWYacdefghiklmnpqrstvwy]+)$/ ) {
		$seq_length = "Negalima apskaičiuoti!";
	}
	
	else {	$seq_length = length( $seq ); }
	
	return $seq_length;
	
}

sub count_mass ( $@ ) {
	
	my $seq = shift ( @_ );

	my %aa_masses = ( 
		'A' => 89.1, 'R' => 174.2, 'N' => 132.1, 'D' => 133.1,
		'C' => 121.2, 'E' => 147.1, 'Q' => 146.2, 'G' => 75.1,
		'H' => 155.2, 'I' => 131.2, 'L' => 131.2, 'K' => 146.2,
		'M' => 149.2, 'F' => 165.2, 'P' => 115.1, 'S' => 105.1,
		'T' => 119.1, 'W' => 204.2, 'Y' => 181.2, 'V' => 117.1
	);
	
	my $seq_total_mass = 0;
	
	$seq = uc ( $seq );
	
	if ( $seq =~ /^([ACDEFGHIKLMNPQRSTVWY]+)$/ ) {	
	
		my @split_seq = split( '', $seq );

		for ( my $at = 0; $at < scalar @split_seq; $at++ ) {
	
			my $aa_mass = $aa_masses{ $split_seq[ $at ] };
			$seq_total_mass = $seq_total_mass + $aa_mass . " g/mol";	
		}
	
	}
	
	elsif ( $seq eq "Seka nepateikta!" || $seq !~ /^([ACDEFGHIKLMNPQRSTVWY]+)$/ ) {
		$seq_total_mass = "Negalima apskaičiuoti!";
	}
	
	return $seq_total_mass;

}

sub open_GOR_C {

	my @GOR_C_array = ();
	open ( my $GOR_C, '<', '/var/www/html/BIAP/GOR/GOR_C.tab' );
	
	while ( my $file_line = <$GOR_C> ) {
		push ( @GOR_C_array, $file_line );
	}

	#print @GOR_C_array;
	#print scalar @GOR_C_array;

	close ( $GOR_C );
	return @GOR_C_array;

}

sub open_GOR_H {

	my @GOR_H_array = ();
	open ( my $GOR_H, '<', '/var/www/html/BIAP/GOR/GOR_H.tab' );

	while ( my $file_line = <$GOR_H> ) {
		push ( @GOR_H_array, $file_line );
	}

	#print @GOR_H_array;
	#print scalar @GOR_H_array;

	close ( $GOR_H );
	return @GOR_H_array;

}

sub open_GOR_E {

	my @GOR_E_array = ();
	open ( my $GOR_E, '<', '/var/www/html/BIAP/GOR/GOR_E.tab' );

	while ( my $file_line = <$GOR_E> ) {
		push ( @GOR_E_array, $file_line );
	}

	#print @GOR_E_array;
	#print scalar @GOR_E_array;
	
	close ( $GOR_E );
	return @GOR_E_array;

}

# Subroutine that cuts sequence into 17-nt long fragments:

sub perform_sequence_cut ( $$ ) {

	my @fragment_array = ();
	my $cut_at = 0;

	my $sequence = shift @_;
	$cut_at = shift @_;

	my $fragment = substr ( $sequence, $cut_at, 17 );
	my @split_fragment = split ( '', $fragment );

	#print @split_fragment, "\n";
	
	if ( scalar @split_fragment == 17 ) {

		push @fragment_array, $fragment;
		return @fragment_array;

	}
	
}

# Subroutine that determines which GOR file to open ( C, E, H ) and
# finds amino acid GOR values based on amino acid position in fragments:

sub determine_GOR_values {

	my @values = ();
	my @GOR_table = ();

	my @fragments_array = shift @_;
	my $GOR_letter = shift @_;

	#print "@fragments_array\n";

	if ( $GOR_letter eq 'C' ) { @GOR_table = open_GOR_C; }
	elsif ( $GOR_letter eq 'E' ) { @GOR_table = open_GOR_E; }
	elsif ( $GOR_letter eq 'H' ) { @GOR_table = open_GOR_H; }

	for ( my $at_1f = 0; $at_1f < scalar @fragments_array; $at_1f++ ) {

		my $fragment = $fragments_array[ $at_1f ];
		my @split_fragment = split ( '', $fragment );

		for ( my $at_2f = 0; $at_2f < scalar @split_fragment; $at_2f++ ) {

			if ( $split_fragment[ $at_2f ] eq '?' ) { next; }
			else {

				for ( my $at_3f = 0; $at_3f < scalar @GOR_table; $at_3f++ ) {

					my @aminoAcid = split ( ' ', $GOR_table[ $at_3f ] );

					if ( $split_fragment[ $at_2f ] eq $aminoAcid[ 1 ] ) {
	
						my $position = $at_2f + 2;
						push ( @values, $aminoAcid[ $position ] );
					}
				}
			}
		}
	}	

	if ( $GOR_letter eq 'E' ) { push @values, -87.5; }
	elsif ( $GOR_letter eq 'H' ) { push @values, -75; }

	#print "@values\n";
	return @values;

}

# Subroutine that returns the sum of the GOR values:

sub count_GOR_value ( $ ) {

	my $sum_of_values = 0;

	my $joint_values = shift @_;
	my @values_array = split ( ' ', $joint_values );

	#print "@values_array\n";

	for my $iter( 0..$#values_array ) {

		my $value = $values_array[ $iter ];
		$sum_of_values = $sum_of_values + $value;

	}

	#print $sum_of_values, "\n";
	return $sum_of_values;

}

# Subroutine that determines the highest GOR value:

sub find_highest_GOR_value ( @ ) {

	my @CEH_values = @_;

	my @sorted_CEH = sort { $a <=> $b } @CEH_values;
	
	#print "@sorted_CEH\n";

	my $last_value = pop @sorted_CEH;

	if ( $last_value == $CEH_values[ 0 ] ) { return "C"; }
	elsif ( $last_value == $CEH_values[ 1 ] ) { return "E"; }
	elsif ( $last_value == $CEH_values[ 2 ] ) { return "H"; }

}

# Subroutine that returns highest values:

sub return_highest_values ( $ ) {

	my $symbol = shift @_;

	if ( $symbol eq "C" ) { return "C"; }
	elsif ( $symbol eq "E" ) { return "E"; }
	elsif ( $symbol eq "H" ) { return "H"; }

}

# Subroutine that implements filter:

sub implement_filter ( $ ) {

	my @symbol_after_filter = ();
	my $C_count = 0;
	my $E_count = 0;
	my $H_count = 0;

	my $fragment = shift @_;
	my @split_fragment = split ( '', $fragment );

	#print $fragment, "\n";

	for ( my $at_1f = 0; $at_1f < scalar @split_fragment; $at_1f++ ) {

		if ( $split_fragment[ $at_1f ] eq 'C' ) { $C_count = $C_count + 1; }
		elsif ( $split_fragment[ $at_1f ] eq 'E' ) { $E_count = $E_count + 1; }
		elsif ( $split_fragment[ $at_1f ] eq 'H' ) { $H_count = $H_count + 1; }

	}

	#print "C: ", $C_count, "\t";
	#print "E: ", $E_count, "\t";
	#print "H: ", $H_count, "\n";

	for ( my $at_2f = 0; $at_2f < scalar @split_fragment; $at_2f++ ) {

		if ( $C_count > $E_count && $C_count > $H_count) {

			$split_fragment[ $at_2f ] = 'C';
			push ( @symbol_after_filter, $split_fragment[ $at_2f ] );

		}
		elsif ( $E_count > $C_count && $E_count > $H_count) { 

			$split_fragment[ $at_2f ] = 'E';
			push ( @symbol_after_filter, $split_fragment[ $at_2f ] );

		}
		elsif ( $H_count > $C_count && $H_count > $E_count) { 

			$split_fragment[ $at_2f ] = 'H';
			push ( @symbol_after_filter, $split_fragment[ $at_2f ] );

		}
		else { 
			my $position = $at_2f + 1;
			push ( @symbol_after_filter, $split_fragment[ $position ] );
		}

	}

	#print $symbol_after_filter[ 0 ], "\n";
	return $symbol_after_filter[ 0 ];

}

# Subroutine that returns filtered sequence:

sub pass_through_filter ( $$ ) {

	my @filtered_sequence = ();
	my @split_CEH_values = ();
	my $cut_CEH_fragment;
	my $filtered_symbol;

	my $sequence = shift @_;
	my $CEH_values = shift @_;

	my @split_seq = split ( '', $sequence );
	@split_CEH_values = split ( '', $CEH_values );
	#print scalar @split_CEH_values,"\n";
	#print "@split_CEH_values\n";

	push ( @filtered_sequence, ( '?' )x8 );

	my $limit_pos = scalar @split_seq - 10;

	for ( my $at = 7; $at < scalar @split_CEH_values; $at++ ) {

		if ( $at == $limit_pos ) {

			$cut_CEH_fragment = substr ( $CEH_values, $at, 3 );
			#print $cut_CEH_fragment,"\n";

			$filtered_symbol = implement_filter ( $cut_CEH_fragment );
			push ( @filtered_sequence, $filtered_symbol );
			last;

		}

		else {

			$cut_CEH_fragment = substr ( $CEH_values, $at, 3 );
			#print $cut_CEH_fragment,"\n";

			$filtered_symbol = implement_filter ( $cut_CEH_fragment );
			push ( @filtered_sequence, $filtered_symbol );
			next;

		}
	}

	push ( @filtered_sequence, ( '?' )x8 );
	my $jnt_filtered_seq = join ( '', @filtered_sequence );
	
	return $jnt_filtered_seq;

}

# Subroutine that determines protein class:

sub determine_protein_class ( $ ) {

	my $flt_seq = shift @_;
	#print $flt_seq, "\n";

	$flt_seq =~ /([CHE]+)/g;

	my $seq_no_signs = $1;
	#print $seq_no_signs, "\n";
	
	my @split_seq_no_signs = split ( '', $seq_no_signs );

	my @C_count = grep { /C/ } @split_seq_no_signs;
	my @H_count = grep { /H/ } @split_seq_no_signs;
	my @E_count = grep { /E/ } @split_seq_no_signs;

	#print @C_count,"\n";
	#print @H_count,"\n";
	#print @E_count,"\n";

	if ( scalar @C_count == scalar @split_seq_no_signs ) { return "Negalima nuspėti!"; }
	elsif ( ( $flt_seq !~ /E/ && $flt_seq =~ /H/ ) || 
			scalar @H_count == scalar @split_seq_no_signs ) { return "α"; }
	elsif ( ( $flt_seq !~ /H/ && $flt_seq =~ /E/ ) || 
			scalar @E_count == scalar @split_seq_no_signs ) { return "β"; }
	elsif ( $flt_seq =~ /E{1,}C{0,}H{1,}C{0,}E{1,}/ || 
				$flt_seq =~ /H{1,}C{0,}E{1,}C{0,}H{1,}/ ) { return "α/β"; }
	else { return "α+β"; }

}

# Subroutine that calls other subroutines to perform sequence modifications:

sub make_CEH_sequences ( $ ) {

	my @cut_sequences = ();
	my @counted_GOR_values = ();
	my @sequence_with_signs = ();
	my $start = 0;

	my $sequence = shift @_;
	my @split_seq = split ( '', $sequence );

	for ( my $at = 0; $at < scalar @split_seq; $at++ ) {

		@cut_sequences = perform_sequence_cut( $sequence, $start );

		my @C_values = determine_GOR_values( @cut_sequences, 'C' );
		my $C_values_jnt = join ( ' ', @C_values );
		my $C_value = count_GOR_value ( $C_values_jnt );
		#print $C_value, "\n";

		my @E_values = determine_GOR_values( @cut_sequences, 'E' );
		my $E_values_jnt = join ( ' ', @E_values );
		my $E_value = count_GOR_value ( $E_values_jnt );
		#print $E_value, "\n";

		my @H_values = determine_GOR_values( @cut_sequences, 'H' );
		my $H_values_jnt = join ( ' ', @H_values );
		my $H_value = count_GOR_value ( $H_values_jnt );
		#print $H_value, "\n";

		push ( @counted_GOR_values, $C_value, $E_value, $H_value );
		my $highest_value = find_highest_GOR_value ( @counted_GOR_values );
		#print $highest_value, "\n\n";

		my $returned_CEH_symbols = return_highest_values ( $highest_value );
		push ( @sequence_with_signs, $returned_CEH_symbols ); 

		$start = $start + 1;
		@counted_GOR_values = ();

	}

	unshift ( @sequence_with_signs, ( '?' )x8 );
	my $lth_seq_signs = scalar @sequence_with_signs - 16;
	my $jnt_seq_signs = join ( '', @sequence_with_signs );

	my $full_CEH_seq = substr ( $jnt_seq_signs, 0, $lth_seq_signs );
	my @split_CEH_seq = split ( '', $full_CEH_seq );

	push ( @split_CEH_seq, ( '?' )x8 ); 
	my $complete_CEH_seq = join ( '', @split_CEH_seq );

	return $complete_CEH_seq;
	
}

# Subroutine that prints results:

sub print_results ( $ ) {

	my $sequence = shift @_;

	my $unfiltered_CEH_seq = make_CEH_sequences ( $sequence );	
	return $unfiltered_CEH_seq;

}

sub determine_aa_frequency ( $ ) {
	
	my $sequence = shift @_;
	
	my %aa_names = ( 
		'A' => "Alaninas", 'R' => "Argininas", 'N' => "Asparaginas",
		'D' => "Aspartatas", 'C' => "Cisteinas", 'E' => "Glutamatas",
		'Q' => "Glutaminas", 'G' => "Glicinas", 'H' => "Histidinas",
		'I' => "Izoleucinas", 'L' => "Leucinas", 'K' => "Lizinas",
		'M' => "Metioninas", 'F' => "Fenilalaninas", 'P' => "Prolinas",
		'S' => "Serinas", 'T' => "Treoninas", 'W' => "Triptofanas",
		'Y' => "Tirozinas", 'V' => "Valinas"
	);
	my %aa_frequencies = ();
	my @aa_freq_arr;
	my $aa_freq_jnt;
	
	$sequence = uc ( $sequence );
	
	my @split_sequence = split ( '', $sequence );
	
	foreach my $iter ( @split_sequence ) { 
		$aa_frequencies{ $iter }++;
	}
	
	my @hash_keys = keys %aa_frequencies;
	
	if ( scalar @hash_keys < 5 ) {
		
		$aa_freq_jnt = "Seką sudaro mažiau nei 5 skirtingos aminorūgštys!"
		
	}
	
	else {

		foreach my $acid( sort { $aa_frequencies{ $a } <=>
				$aa_frequencies{ $b } } keys %aa_frequencies) {
			my $concat = $aa_names{ $acid } . " ($acid) =" . 
						$aa_frequencies{ $acid };
			push ( @aa_freq_arr, $concat );
		}
	
		@aa_freq_arr = reverse ( @aa_freq_arr );
		my @most_frequent = @aa_freq_arr [ 0..4 ];
	
		$aa_freq_jnt = join ( ', ', @most_frequent );
	}
	
	return $aa_freq_jnt;
	
}

if ( $sequence =~ /^([ACDEFGHIKLMNPQRSTVWYacdefghiklmnpqrstvwy]+)$/ ) {
	$final_seq = $1;
	$unfiltered_seq = print_results ( $final_seq );
	$each_aa_count = determine_aa_frequency ( $final_seq ); 
}

elsif ( $sequence !~ /^([ACDEFGHIKLMNPQRSTVWYacdefghiklmnpqrstvwy]+)$/ && length ( $sequence ) != 0 ) {
	$final_seq = "Aptikta neteisingų simbolių!";
	$unfiltered_seq = "Negalima nustatyti!";
	$each_aa_count = "Negalima nustatyti!";
}

elsif ( length ( $sequence ) == 0 ) {
	$final_seq = "Seka nepateikta!";
	$unfiltered_seq = "Negalima apskaičiuoti!";
	$each_aa_count = "Negalima apskaičiuoti!";
}

my $sequence_length = find_length ( $final_seq );
my $sequence_mol_mass = count_mass ( $final_seq );
my $filtered_seq = pass_through_filter( $final_seq, $unfiltered_seq );
my $sequence_protein_class = determine_protein_class ( $filtered_seq );

print
	header( -charset => 'utf-8' ),
	start_html(
		-title => 'Sekos analizės rezultatas', -text => '#520063'
	),
	end_html();
	
print <<ENDHTML;
<HTML>
	<HEAD>
		<TITLE>CGI Test</TITLE>
		<link rel="stylesheet" href="http://localhost/BIAP/CSS stiliai/aa_baigta_analize.css">
		<style>
			.menu_bar {
				overflow: hidden;
				background-color: rgb(5,3,26);
				border-top-left-radius: 0px;
				border-top-right-radius: 0px;
				border-bottom-left-radius: 20px;
				border-bottom-right-radius: 20px;
				border: 1px solid rgb(1,3,14);
				color: black;
				font-size: 110%;
				font-weight: bold;
				padding: 5px;
				text-align: center;
				margin-top: 5px;
			}

			.menu_bar a {
				width: 200px;
				margin: 0 auto;
				color: #f2f2f2;
				padding: 30px;
				text-decoration: none;
				border-color: white;
			}

			.menu_bar a:hover {
				width: 200px;
				margin: 0 auto;
				background-color: rgb(223,213,255);
				padding: 40px;
				color: black;
				font-weight: bold;
			}
		</style>
	</HEAD>
	<BODY>
		<div class="menu_bar">
			<a href="http://localhost/BIAP/HTML failai/tinklalapis.html">Pagrindinis puslapis</a>
			<a href="http://localhost/BIAP/HTML failai/aminorūgštys.html">Aminorūgštys</a>
			<a href="http://localhost/BIAP/HTML failai/genetiniai_kodai.html">Genetiniai kodai</a>
			<a href="http://localhost/BIAP/HTML failai/seku_analize.html">Sekos analizė</a>
			<a href="http://localhost/BIAP/HTML failai/mokymai_forma.html">MOKYMAI</a>
			<a href="http://localhost/BIAP/HTML failai/aa_analize.html">Grįžti</a>
		</div>
		<table>
			<tr>
				<th colspan="3"><h2><b><center>Aminorūgščių sekos analizė</center></b></h2></th>
			</tr>
			<tr>
				<td colspan="1" class="col_1">Aminorūgščių seka</td>
				<td colspan="2" class="col_2">$final_seq</td>
			</tr>
			<tr>
				<td colspan="1" class="col_1">Sekos ilgis (aminorūgščių skaičius)</td>
				<td colspan="2" class="col_2">$sequence_length</td>
			</tr>
			<tr>
				<td colspan="1" class="col_1">Aminorūgščių kiekis</td>
				<td colspan="2" class="col_2">$each_aa_count</td>
			</tr>
			<tr>
				<td colspan="1" class="col_1">Sekos molinė masė</td>
				<td colspan="2" class="col_2">$sequence_mol_mass</td>
			</tr>
			<tr>
				<td colspan="1" class="col_1">Nefiltruota GOR metodo prognozė</td>
				<td colspan="2" class="col_2">$unfiltered_seq</td>
			</tr>
			<tr>
				<td colspan="1" class="col_1">Spėta antrinė struktūra</td>
				<td colspan="2" class="col_2">$sequence_protein_class</td>
			</tr>
		</table>
	</BODY>
</HTML>

ENDHTML
