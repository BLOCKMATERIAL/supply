<?php
function db_conn() {
	$server = "localhost";
	$user = $_SESSION["user"];
	$pass = $_SESSION["pass"];
	$db = "supply";

	$conn = @mysqli_connect($server, $user, $pass, $db);

	if (!$conn) {
		session_unset();
		session_destroy();

		die("Connection failed: " . mysqli_connect_error());
	}

	return $conn;
}
?>
