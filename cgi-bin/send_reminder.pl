#!/usr/bin/perl -T

use strict;
use warnings;
use CGI qw( :all -utf8 );

my $name = param( 'vardas' );
my $surname = param( 'pavardė' );
my $email = param( 'pašto_adresas' );
my $school_stud = param( 'mokinys' ) || 'Nenurodytas statusas';
my $uni_stud = param( 'studentas' ) || 'Nenurodytas statusas';
my $teacher= param( 'mokytojas' ) || 'Nenurodytas statusas';
my $edu_institution = param( 'mok_pavad' ) || 'Nenurodyta mokslo įstaiga';


if ( param( 'vardas' ) !~ /^([A-Za-zĄČĘĖĮŠŲŪąčęėįšųū]+)$/ &&
		param( 'pavardė' ) !~ /^([A-Za-zĄČĘĖĮŠŲŪąčęėįšųū]+)$/ &&
			param( 'pašto_adresas' ) !~ /^(\w+)$/ ||
	param( 'vardas' ) !~ /^([A-Za-zĄČĘĖĮŠŲŪąčęėįšųū]+)$/ && 
		param( 'pavardė' ) !~ /^([A-Za-zĄČĘĖĮŠŲŪąčęėįšųū]+)$/ ||
	param( 'vardas' ) !~ /^([A-Za-zĄČĘĖĮŠŲŪąčęėįšųū]+)$/ &&
		param( 'pašto_adresas' ) !~ /^(\w+)$/ ||
	param( 'pavardė' ) !~ /^([A-Za-zĄČĘĖĮŠŲŪąčęėįšųū]+)$/ &&
		param( 'pašto_adresas' ) !~ /^(\w+)$/ ) {
	
	print redirect(
		-uri => 'http://localhost/BIAP/Klaidos/many_errors.html'
	);
	exit;
}

if ( param( 'vardas' ) =~ /^([A-Za-zĄČĘĖĮŠŲŪąčęėįšųū]+)$/ ) {
	$name = $1;
}

else {
	print redirect(
		-uri => 'http://localhost/BIAP/Klaidos/missing_name.html'
	);
	exit;
}

if ( param( 'pavardė' ) =~ /^([A-Za-zĄČĘĖĮŠŲŪąčęėįšųū]+)$/ ) {
	$surname = $1;
}

else {
	print redirect(
		-uri => 'http://localhost/BIAP/Klaidos/missing_surname.html'
	);
	exit;
}

if ( param( 'pašto_adresas' ) =~ /^([A-Za-z0-9]+@[a-z.]+)$/ ) {
	$email = $1;
}

else {
	print redirect(
		-uri => 'http://localhost/BIAP/Klaidos/missing_email.html'
	);
	exit;
}

print
	header( -charset => 'utf-8' ),
	start_html(
		-title => 'Priminimas', -text => '#520063'
	),
	end_html();

print <<ENDHTML;
<HTML>
	<HEAD>
		<meta charset="utf-8"/>
		<TITLE>CGI Test</TITLE>
		<link rel="stylesheet" href="http://localhost/BIAP/CSS stiliai/priminimo_siuntimas.css">
		<style>
			.menu_bar {
				overflow: hidden;
				background-color: rgb(4,7,51);
				border-top-left-radius: 0px;
				border-top-right-radius: 0px;
				border-bottom-left-radius: 15px;
				border-bottom-right-radius: 15px;
				border: 1px solid rgb(1,3,14);
				color: black;
				font-size: 110%;
				font-weight: bold;
				padding: 5px;
				text-align: center;
				margin-top: 0px;
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

			.frame {
				background-color: rgb(243,218,174); /* Fallback color */
				background-color: rgba(243,218,174,0.5); /* Black w/opacity/see-through */
				color: black;
				font-size: 130%;
				border-color: rgb(233,204,154);
				border-style: solid;
				border-top-left-radius: 20px;
				border-top-right-radius: 20px;
				border-bottom-left-radius: 20px;
				border-bottom-right-radius: 20px;
				position: absolute;
				top: 50%;
				left: 50%;
				transform: translate(-100px, -240px);
				width: 680px;
				height: 450px; 
				text-align: center;
			}
		</style>
	</HEAD>
	<BODY>
		<div class="menu_bar">
			<a href="http://localhost/BIAP/HTML failai/tinklalapis.html">Pagrindinis puslapis</a>
			<a href="http://localhost/BIAP/HTML failai/aminorūgštys.html">Aminorūgštys</a>
			<a href="http://localhost/BIAP/HTML failai/genetiniai_kodai.html">Genetiniai kodai</a>
			<a href="http://localhost/BIAP/HTML failai/seku_analize.html">Sekos analizė</a>
		</div>
		<div class="frame">
			<p class="title_1">Ačiū, kad užsiregistravote į mokymus!</p>
			<p class="title_2"<center>Tikimės, kad renginio metu sužinosite daug naujų dalykų ir tik dar labiau susižavėsite mokslu bei naujovėmis!</center></p>
			<p class="introduce_data">Jūsų įvesta informacija:</p>
			<table class="table_style">
				<tr>
					<th class="col_1">Vardas</th>
					<th class="col_2">$name</th>
				</tr>
				<tr>
					<th class="col_1">Pavardė</th>
					<th class="col_2">$surname</th>
				</tr>
				<tr>
					<th class="col_1">Elektroninio pašto adresas</th>
					<th class="col_2">$email</th>
				</tr>
				<tr>
					<th class="col_1">Mokslo įstaiga</th>
					<th class="col_2">$edu_institution</th>
				</tr>
				<tr>
					<th class="col_1">Renginio data</th>
					<th class="col_2">Lapričio 24 - 26 dienomis</th>
				</tr>
				<tr>
					<th class="col_1">Renginio vieta</th>
					<th class="col_2">Vilniaus universiteto Mokslinės Komunikacijos ir Informacijos Centro konferencijų salė</th>
				</tr>
			</table>
		</div>
	</BODY>
</HTML>

ENDHTML