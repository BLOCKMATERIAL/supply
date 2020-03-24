<?php
session_start();

# process login form
if (isset($_POST["login"])) {
	session_unset();

	# set user session variables
	$_SESSION["user"] = $_POST["user"];
	$_SESSION["pass"] = $_POST["pass"];

	header("location: index.php");
} else {
	# redirect to a home page if user is already signed in
	if (isset($_SESSION["user"])) {
		header("location: index.php");
	}
}
?>
<!DOCTYPE html>
<html>
<head>
	<title>Login</title>
</head>
<body>
	<h3>Supply Application Login</h3>
	<form method="post" action="login.php">
		<p>
			<b>User name</b>
		</p>
		<p>
			<input type="text" name="user" required />
		</p>
		<p>
			<b>Password</b>
		</p>
		<p>
			<input type="password" name="pass" required />
		</p>
		<p>
			<input type="submit" name="login" value="Login" />
		</p>
	</form>
</body>
</html>