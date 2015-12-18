#!/usr/bin/php
<?php

//$dateformat='d-m-Y h:i:s';
//print date($dateformat);

// Variables
$db = DATABASE;
$table = table1;
$nb = 10000;
$file = 'rows_table.log';
$handle = fopen($file, 'w');

// Display start INSERT hour
print("INSERT START:\n");
print(date("d-m-Y H:i:s\n"));

// Define db connect
$connect = mysql_connect("localhost","user","password");
if (!$connect)
{
die('Could not connect: ' . mysql_error());
}

// Define db select
$check_db = mysql_select_db("$db", $connect);
if (!$check_db)
{
die('DB does not exists: ' . mysql_error());
}

// INSERT Loop with INSERT TO table, SELECT the value, write it to a log file and display this value on the STDOUT
for($i=1;$i<$nb;$i++){
$query = mysql_query("INSERT INTO $table VALUES ($i)");
$result = mysql_query("SELECT * FROM $table", $connect);
$num_rows = mysql_num_rows($result);
$datas = "$num_rows value written to $file\n";
fwrite($handle, $datas);
print($datas);

// mysql_query("SELECT COUNT(*) FROM $table");
// mysql_query("DELETE FROM $table");
}

// Close the log file
fclose($handle);

// Display end INSERT hour
print("INSERT END:\n");
print(date("d-m-Y H:i:s\n"));

// Count all rows into the table and display the total number of rows
$result = mysql_query("SELECT COUNT(*) FROM $table");
print("Number of rows into $table table\n");
echo mysql_result($result, 0);

// Truncate the table
print("\nRemoving rows into $table table\n");
mysql_query("DELETE FROM $table");

// Count all rows into the table and display the total number of rows
$result = mysql_query("SELECT COUNT(*) FROM $table");
print("Number of rows into $table table\n");
echo mysql_result($result, 0);
print("\n");

?>
