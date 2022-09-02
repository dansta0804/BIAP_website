#!/usr/bin/perl -T

use strict;
use warnings;
use CGI qw( :all -utf8 );

my $sequence = param( 'seka' );
my $final_seq;
my $mismatch;

sub check_sequence ( $@ ) {
	
	my $seq_given = shift ( @_ );
	my $seq_checked;
	
	if ( $seq_given eq "Aptikta neteisingų simbolių!" || $seq_given eq "Seka nepateikta!") {
		$seq_checked = $seq_given;
	}
	
	elsif ( $seq_given =~ /^([ACGTacgt]+)$/ ) {
		$seq_checked = $seq_given;
	}
	
	return $seq_checked;
	
}


sub find_length ( $@ ) {
	
	my $seq = shift ( @_ );
	my $seq_length;
	
	if ( $seq eq "Seka nepateikta!" || $seq !~ /^([ACGTacgt]+)$/ ) {
		$seq_length = "Negalima apskaičiuoti!";
	}
	
	else {	$seq_length = length( $seq ); }
	
	return $seq_length;
	
}

sub count_mass ( $@ ) {
	
	my $seq = shift ( @_ );

	my %nt_masses = ( 
		'A' => 135.13, 'T' => 126.11, 'G' => 151.13, 'C' => 111.1,
		'a' => 135.13, 't' => 126.11, 'g' => 151.13, 'c' => 111.1
	);
	
	my $seq_total_mass = 0;
	
	if ( $seq =~ /^([ACGTacgt]+)$/ ) {	
	
		my @split_seq = split( '', $seq );

		for ( my $at = 0; $at < scalar @split_seq; $at++ ) {
	
			my $nt_mass = $nt_masses{ $split_seq[ $at ] };
			$seq_total_mass = $seq_total_mass + $nt_mass . " g/mol";	
		}
	
	}
	
	elsif ( $seq ne "Seka nepateikta!" || $seq !~ /^([ACGTacgt]+)$/ ) {
		$seq_total_mass = "Negalima apskaičiuoti!";
	}
	
	return $seq_total_mass;

}

sub determine_nt_count ( $@ ) {
	
	my $nt_seq = shift ( @_ );
	$nt_seq = uc ( $nt_seq );
	
	my $nt_A = 0;
	my $nt_T = 0;
	my $nt_G = 0;
	my $nt_C = 0;
	my @nt_count_arr;
	my $nt_count_jnt;
	
	if ( $nt_seq eq "Seka nepateikta!" && $nt_seq !~ /^([ACGTacgt]+)$/ ) { 
		$nt_count_jnt = "Negalima apskaičiuoti!";
	}
	
	elsif ( $nt_seq !~ /^([ACGTacgt]+)$/ ) {
		$nt_count_jnt = "Aptikta neteisingų simbolių!";
	}
	
	elsif ( $nt_seq =~ /^([ACGTacgt]+)$/ ) {
		
		my @split_nts = split ( '', $nt_seq );
	
		for ( my $iter = 0; $iter < scalar @split_nts; $iter++ ) {
		
			if ( $split_nts [ $iter ] eq 'A' ) { $nt_A = $nt_A + 1; }
			elsif ( $split_nts [ $iter ] eq 'T' ) { $nt_T = $nt_T + 1; }
			elsif ( $split_nts [ $iter ] eq 'G' ) { $nt_G = $nt_G + 1; }
			elsif ( $split_nts [ $iter ] eq 'C' ) { $nt_C = $nt_C + 1; }
		
		}
	
		push ( @nt_count_arr, "A = $nt_A", "T = $nt_T", "G = $nt_G", "C = $nt_C" );
	
		$nt_count_jnt = join ( ', ', @nt_count_arr );
	}
	
	return $nt_count_jnt;
	
}

sub find_complement ( $@ ) {
	
	my $seq = shift ( @_ );
	my $jnt_seq;
	
	if ( $seq eq "Seka nepateikta!" ) { 
		$jnt_seq = "Negalima nustatyti!";
	}
	
	elsif ( $seq !~ /^([ACGTacgt]+)$/ ) {
		$jnt_seq = "Aptikta neteisingų simbolių!";
	}
	
	elsif ( $seq =~ /^([ACGTacgt]+)$/ ){
		my %base_match = ( 'A' => 'T', 'T' => 'A', 'G' => 'C', 'C' => 'G',
			'a' => 't', 't' => 'a', 'g' => 'c', 'c' => 'g'
		);
		my @seq_compl = ();
	
		my @split_seq = split( '', $seq );
		
		for ( my $at = 0; $at < scalar @split_seq; $at++ ) {
	
			my $base = $base_match{ $split_seq[ $at ] };
			push ( @seq_compl, $base );
		
		}
	
		$jnt_seq = join ( '', @seq_compl );
		
	}
	
	return $jnt_seq;
	
}

sub determine_translation_product ( $@ ) {
	
	my %translation_table = (
				"TTA" => 'L', "TTG" => 'L', "CTT" => 'L',
				"CTC" => 'L', "CTA" => 'L', "CTG" => 'L',
				"TTA" => 'L', "TTG" => 'L', "CTT" => 'L',
				"CTC" => 'L', "CTA" => 'L', "CTG" => 'L',
				"ATT" => 'I', "ATC" => 'I', "ATA" => 'I',
				"CGT" => 'R', "CGC" => 'R', "CGA" => 'R',
				"CGG" => 'R', "AGA" => 'R', "AGG" => 'R', 
				"GTT" => 'V', "GTV" => 'V', "GTA" => 'V',
				"GTG" => 'V', "TCT" => 'S', "TCC" => 'S',
				"TCA" => 'S', "TCG" => 'S', "CCT" => 'P',
				"CCC" => 'P', "CCA" => 'P', "CCG" => 'P',
				"ACT" => 'T', "ACC" => 'T', "ACA" => 'T',
				"ACG" => 'T', "GCT" => 'A', "GCC" => 'A',
				"GCA" => 'A', "GCG" => 'A', "TAT" => 'Y',
				"TAC" => 'Y', "CAT" => 'H', "CAC" => 'H',
				"CAA" => 'Q', "CAG" => 'Q', "AAT" => 'N',
				"AAC" => 'N', "AAA" => 'K', "AAG" => 'K',
				"GAT" => 'D', "GAC" => 'D', "GAA" => 'E',
				"GAG" => 'E', "TGT" => 'C', "TGC" => 'C',
				"AGT" => 'S', "AGC" => 'S', "GGT" => 'G',
				"GGC" => 'G', "GGA" => 'G', "GGG" => 'G',
				"ATG" => 'M', "TGG" => 'W', "TTT" => 'F',
				"TTC" => 'F'
				);
				
	my $seq= shift ( @_ );
	my @triplet_array = ();
	my @amino_acid_array = ();
	my $translation_product;
	my $triplet_check;
	
	if ( $seq  eq "Seka nepateikta!" ) { 
		$translation_product = "Negalima nustatyti!";
	}
	
	elsif ( $seq !~ /^([ACGTacgt]+)$/ ) {
		$translation_product = "Negalima nustatyti!";
	}	
	
	elsif ( $seq =~ /^([ACGTacgt]+)$/ ) {
		for ( my $cut_at = 0; $cut_at < length ( $sequence ); $cut_at += 3 ) {
				
			my $triplet = substr ( $sequence, $cut_at, 3 );
			
			if ( $triplet =~ /^([acgt]+)$/ ) { 
				$triplet_check = uc( $1 );
			}
			
			elsif ( $triplet =~ /^([ACGTacgt]+)$/ ) { 
				$triplet_check = uc( $1 );
			}
			else { $triplet_check = $triplet; }
			push ( @triplet_array, $triplet_check );
				
		}
	
		for my $iter ( @triplet_array ) {
		
			if ( length ( $triplet_array[ $iter ] ) < 3 ) { next; }
		
			else {
				my $amino_acid = $translation_table{ $iter };
				push ( @amino_acid_array, $amino_acid );
			}	
		}
	
		$translation_product = join ( '', @amino_acid_array );
		
	}
	
	return $translation_product;
	
}

if ( $sequence =~ /^([ACGTacgt]+)$/ ) {
	$final_seq = $1;
}

elsif ( length ( $sequence ) == 0 ) {
	$final_seq = "Seka nepateikta!";
}

elsif ( $sequence !~ /^([ACGTacgt]+)$/ ) {
	$final_seq = "Aptikta neteisingų simbolių!";
}

my $sequence_length = find_length ( $final_seq );
my $sequence_mol_mass = count_mass ( $final_seq );
my $sequence_complement = find_complement ( $final_seq );
my $translation_product = determine_translation_product ( $final_seq );
my $base_count = determine_nt_count ( $final_seq );

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
		<link rel="stylesheet" href="http://localhost/BIAP/CSS/nt_baigta_analize.css">
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
			<a href="http://localhost/BIAP/HTML_files/tinklalapis.html">Pagrindinis puslapis</a>
			<a href="http://localhost/BIAP/HTML_files/aminorūgštys.html">Aminorūgštys</a>
			<a href="http://localhost/BIAP/HTML_files/genetiniai_kodai.html">Genetiniai kodai</a>
			<a href="http://localhost/BIAP/HTML_files/seku_analize.html">Sekos analizė</a>
			<a href="http://localhost/BIAP/HTML_files/mokymai_forma.html">MOKYMAI</a>
			<a href="http://localhost/BIAP/HTML_files/nt_analize.html">Grįžti</a>
		</div>
		<table>
			<tr>
				<th colspan="3"><h2><b><center>Nukleotidų sekos analizė</center></b></h2></th>
			</tr>
			<tr>
				<td colspan="1" class="col_1">Nukleotidų seka</td>
				<td colspan="2" class="col_2">$final_seq</td>
			</tr>
			<tr>
				<td colspan="1" class="col_1">Sekos ilgis (nukleotidų skaičius)</td>
				<td colspan="2" class="col_2">$sequence_length</td>
			</tr>
			<tr>
				<td colspan="1" class="col_1">Sekos molinė masė</td>
				<td colspan="2" class="col_2">$sequence_mol_mass</td>
			</tr>
			<tr>
				<td colspan="1" class="col_1">A, T, G, C skaičius</td>
				<td colspan="2" class="col_2">$base_count</td>
			</tr>
			<tr>
				<td colspan="1" class="col_1">Komplementari seka</td>
				<td colspan="2" class="col_2">$sequence_complement</td>
			</tr>
			<tr>
				<td colspan="1" class="col_1">Transliacijos produktas</td>
				<td colspan="2" class="col_2">$translation_product</td>
			</tr>
		</table>
	</BODY>
</HTML>

ENDHTML
