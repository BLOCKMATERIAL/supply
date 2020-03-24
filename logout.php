<?php
session_start();

# remove session variables and destroy a session
session_unset();
session_destroy();

header("location: login.php");
?>
