<?php
session_start();

require_once("connect.php");

$conn = NULL;

# check for a user session
if (isset($_SESSION["user"])) {
	$conn = db_conn();
	include("action.php");
} else {
	# redired to login page if the user is not set
	header("location: login.php");
}
?>
<!DOCTYPE html>
<html>
<head>
	<title>Supply</title>
</head>
<body>
	<p>
		<b>User:</b> <i><?= $_SESSION["user"] ?></i> | <a href="logout.php">Logout</a>
	</p>
	<?php
	# display content depending on the user type
	if ($_SESSION["user"] == "manager") {
		include("manager.php");
	}

	if ($_SESSION["user"] == "storekeeper") {
		include("storekeeper.php");
	}
	?>
</body>
</html>
<?php
mysqli_close($conn);
?>
