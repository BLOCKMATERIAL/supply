<?php
# check for a user session
if (!isset($_SESSION["user"])) {
	header("location: login.php");
}
?>

<h3>Contracts</h3>
<p>
	<?php
	# if the page is in record's create/update or delete mode (action parameter is set) - show 'back' link
	if (isset($_GET["action"]) && ($_GET["action"] == "create" || $_GET["action"] == "update" 
		|| $_GET["action"] == "delete")) {
	?>
		<a href="index.php">Back</a>
	<?php
	# otherwise - show 'new record' link
	} else {
	?>
		<a href="index.php?action=create">New contract</a>
		<a href="index.php?action=export">Export data</a>
	<?php
	}
	?>
</p>

<?php
# check for action parameter
# show create/update or delete form if it is set
if (isset($_GET["action"]) && ($_GET["action"] == "create" || $_GET["action"] == "update" 
	|| $_GET["action"] == "delete")) {
?>
	<form method="post" action="index.php">
		<input type="hidden" value="<?= $_GET["id"] ?>" name="contract_number" />
		<?php
		# if the current mode is create/update
		# show corresponding form with the required fields and buttons
		if ($_GET["action"] == "create" || $_GET["action"] == "update") {
		?>
		<p>
			<b>Supplier</b>
		</p>
		<p>
			<select name="supplier_id">
			<?php
			# retrieve suppliers ids/info to display select control
			$sql = "SELECT * FROM supplier_info";
			$result = mysqli_query($conn, $sql);

			while ($row = mysqli_fetch_assoc($result)) {
				?><option value="<?= $row["supplier_id"] ?>"><?= $row["Info"] ?></option><?php
			}
			?>
			</select>
		</p>
		<p>
			<b>Note</b>
		</p>
		<p>
			<?php
			# retrieve and display contract note of the updated contract
			if (isset($_GET["action"]) && $_GET["action"] == "update") {
				$contract_number = $_GET["id"];

				$sql = "SELECT contract_note FROM contract WHERE contract_number = {$contract_number}";
				$result = mysqli_query($conn, $sql);
				$row = mysqli_fetch_assoc($result);
			}
			?>
			<textarea name="contract_note" rows="5" cols="50"><?= $row["contract_note"] ?></textarea>
		</p>
		<p>
			<?php
			# set proper names for create/update buttons
			if (isset($_GET["action"]) && $_GET["action"] == "create") {
			?>
				<input type="submit" name="create_contract" value="Save" />
			<?php
			} else if (isset($_GET["action"]) && $_GET["action"] == "update") {
			?>
				<input type="submit" name="update_contract" value="Save" />
			<?php
			}
			?>
		</p>
		<?php
		# if the current mode is delete
		# display the corresponding question and button
		} else if ($_GET["action"] == "delete") {
		?>
			<b>Delete the contract #<?= $_GET["id"] ?>?</b>
			<p>
				<input type="submit" name="delete_contract" value="Continue" />
			</p>
		<?php
		}
		?>
	</form>
<?php
} else {
?>
	<table border="1">
		<tr>
			<th>Contract number <p><a href="dog.html">По убывания</a></p>
			<p><a href="dog.html">По возрастанию</a></p> </th>
			<th>Contract date <p><a href="dog.html">По убывания</a></p>
			<p><a href="dog.html">По возрастанию</a></p> </th>
			<th>Supplier</th>
			<th>Note</th>
			<th>Action</th>
		</tr>
	<?php
	# retrieve and display data about contracts
	$sql = "SELECT contract_supplier.*,
		(SELECT contract_note FROM contract WHERE contract_number = contract_supplier.contract_number) AS `note`
		FROM contract_supplier ORDER BY contract_date DESC";
	$result = mysqli_query($conn, $sql);

	while ($row = mysqli_fetch_assoc($result)) {
		?>

		<tr>
			<td><a href="index.php?action=info&id=<?= $row["contract_number"] ?>"><?= $row["contract_number"] ?></a></td>
			<td><?= $row["contract_date"] ?></td>
			<td><?= $row["Supplier"] ?></td>
			<td><?= $row["note"] ?></td>
			<td>
				<a href="index.php?action=update&id=<?= $row["contract_number"] ?>">Update</a>
				<a href="index.php?action=delete&id=<?= $row["contract_number"] ?>">Delete</a>
			</td>
		</tr>
		<?php
	}
	?>
	</table>
<?php
}

# if the action mode is info
# display data about supplied products for a selected contract
if (isset($_GET["action"]) && $_GET["action"] == "info") {
	$contract_number = $_GET["id"];
?>
	<h3>Supplied products by contract #<?= $contract_number ?></h3>
	<p>
	<a href="index.php">Hide</a>
	</p>
	<?php
	# retrieve data about selected products
	$sql = "SELECT supplied_product, supplied_amount, supplied_cost 
		FROM supplied
		WHERE contract_number = {$contract_number}";
	$result = mysqli_query($conn, $sql);

	# check the size of a result set
	if (mysqli_num_rows($result) > 0) {
		?>
		<table border="1">
			<tr>
				<th>Product</th>
				<th>Amount</th>
				<th>Cost</th>
			</tr>
		<?php
		# display products if the contract is not empty
		while ($row = mysqli_fetch_assoc($result)) {
			?>
			<tr>
				<td><?= $row["supplied_product"] ?></td>
				<td><?= $row["supplied_amount"] ?></td>
				<td><?= $row["supplied_cost"] ?></td>
			</tr>
			<?php
		}
	} else {
		# if the result set is empty print the following message
		echo "Contract is empty";
	}
	?>
	</table>
<?php
}
?>
