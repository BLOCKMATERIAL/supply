<?php
# process request to create contract
if (isset($_POST["create_contract"])) {
	$supplier_id = $_POST["supplier_id"];
	$contract_note = $_POST["contract_note"];

	# use the stored procedure created earlier
	$sql = "CALL sp_contract_ops('i', 0, '', {$supplier_id}, '{$contract_note}')";
	mysqli_query($conn, $sql);

	header("location: index.php");
}

# process request to delete contract
if (isset($_POST["delete_contract"])) {
	$contract_number = $_POST["contract_number"];

	$sql = "CALL sp_contract_ops('d', {$contract_number}, '', 0, '')";
	mysqli_query($conn, $sql);

	header("location: index.php");
}

# process request to update contract
if (isset($_POST["update_contract"])) {
	$contract_number = $_POST["contract_number"];
	$supplier_id = $_POST["supplier_id"];
	$contract_note = $_POST["contract_note"];

	$sql = "CALL sp_contract_ops('u', {$contract_number}, CURRENT_TIMESTAMP(), {$supplier_id}, '{$contract_note}')";
	mysqli_query($conn, $sql);

	header("location: index.php");
}

# process request to insert new record into session array of delivered products
if (isset($_POST["add_product"])) {
	$supplied_product = $_POST["supplied_product"];
	$supplied_amount = $_POST["supplied_amount"];
	$supplied_cost = $_POST["supplied_cost"];

	if (!empty($supplied_product) && !empty($supplied_amount) && !empty($supplied_cost)) {
		if (is_numeric($supplied_amount) && is_numeric($supplied_cost)) {
			if ($supplied_amount > 0 && $supplied_cost > 0) {
				$_SESSION["supplied_products"][$supplied_product] = array("amount" => $supplied_amount, 
					"cost" => $supplied_cost);
			}
		}
	}

	header("location: index.php");
}

# process request to remove a record from the session array
if (isset($_GET["supplied"]) && $_GET["supplied"] == "remove") {
	$supplied_product = $_GET["product"];
	unset($_SESSION["supplied_products"][$supplied_product]);

	header("location: index.php");
}

# process request to store delivered products into the database
if (isset($_POST["save_products"])) {
	$contract_number = $_POST["contract_number"];

	# begin transaction
	mysqli_query($conn, "SET AUTOCOMMIT = 0");
	mysqli_query($conn, "START TRANSACTION");

	$failed = false;

	foreach ($_SESSION["supplied_products"] as $key => $value) {
		$amount = $value["amount"];
		$cost = $value["cost"];

		# keep result of each query inside the transaction
		$result = mysqli_query($conn, "INSERT INTO supplied (contract_number, 
			supplied_product, supplied_amount, supplied_cost) VALUES (
			{$contract_number}, '{$key}', {$amount}, {$cost})");

		if (!$result) {
			$failed = true;

			# rollback the transaction if any query is failed
			mysqli_query($conn, "ROLLBACK");
			break;
		}
	}

	if (!$failed) {
		# commit the transaction if there are no failed queries
		mysqli_query($conn, "COMMIT");
	}

	# restore autocommit property
	mysqli_query($conn, "SET AUTOCOMMIT = 1");

	# clear session array after products are stored into the database
	$_SESSION["supplied_products"] = NULL;

	header("location: index.php");
}

# process request to export report into the Excel document
if (isset($_GET["action"]) && $_GET["action"] == "export") {
	$filename = "report_contracts_" . date('Ymd') . ".xls";

	header("Content-Disposition: attachment; filename=\"$filename\"");
	header("Content-Type: application/vnd.ms-excel");
	
	$flag = false;
	$result = mysqli_query($conn, "CALL sp_contract_total('2018-01-01', CURRENT_TIMESTAMP())");

	while ($row = mysqli_fetch_assoc($result)) {
		if (!$flag) {
			echo implode("\t", array_keys($row)) . "\r\n";
			$flag = true;
    	}

	    array_walk($row, __NAMESPACE__ . '\cleanData');
	    echo implode("\t", array_values($row)) . "\r\n";
	}

	exit;
}

function cleanData(&$str) {
    $str = preg_replace("/\t/", "\\t", $str);
    $str = preg_replace("/\r?\n/", "\\n", $str);

    if (strstr($str, '"')) {
    	$str = '"' . str_replace('"', '""', $str) . '"';
    }
}
?>
