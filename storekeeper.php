<?php
# check for a user session
if (!isset($_SESSION["user"])) {
	header("location: login.php");
}

# initialize array of delivered but not stored products
# such array is implemented as the session variable
if (!isset($_SESSION["supplied_products"])) {
	$_SESSION["supplied_products"] = array();
}
?>

<h3>Supplied products</h3>

<?php
# check for awaiting deliveries (is there any empty contracts)
$sql = "SELECT * FROM contract_supplier 
	WHERE contract_number NOT IN (SELECT contract_number FROM supplied)";
$result = mysqli_query($conn, $sql);

# if awaiting deliveries exist
# display a corresponding form
if (mysqli_num_rows($result) > 0) {
	# chech session array of delivered but not stored products
	# if there are any products - display the form used to store supplied products
	if (sizeof($_SESSION["supplied_products"]) > 0) {
	?>
		<form method="post" action="index.php">
			<p>
				<b>by contract</b>
				<select name="contract_number">
				<?php
				# display the combo box with awaiting orders
				while ($row = mysqli_fetch_assoc($result)) {
					?><option value="<?= $row["contract_number"] ?>">
						<?= $row["contract_number"] . " - " . $row["Supplier"] . 
							" (" . $row["contract_date"] . ")" ?></option><?php
				}
				?>
				</select>
			</p>
			<table border="1">
				<tr>
					<th>Product</th>
					<th>Amount</th>
					<th>Cost</th>
					<th>Action</th>
				</tr>
			<?php
			# display the session array of delivered products
			foreach ($_SESSION["supplied_products"] as $key => $value) {
			?>
				<tr>
					<td><?= $key ?></td>
					<td><?= $value["amount"] ?></td>
					<td><?= $value["cost"] ?></td>
					<td><a href="index.php?supplied=remove&product=<?= $key ?>">Remove</a></td>
				</tr>
			<?php
			}
			?>
			</table>
			<p>
				<input type="submit" name="save_products" value="Store products" />
			</p>
		</form>
	<?php
	} else {
		echo "Add supplied products";
	}
	?>
	<p>
		<b>New product</b>
	</p>
	<form method="post" action="index.php">
		<table border="1">
			<tr>
				<th>Product</th>
				<th>Amount</th>
				<th>Cost</th>
			</tr>
			<tr>
				<td>
					<input type="text" name="supplied_product" required />
				</td>
				<td>
					<input type="number" name="supplied_amount" min="0.01" step="0.01" value="0.01" required />
				</td>
				<td>
					<input type="number" name="supplied_cost" min="0.01" step="0.01" value="0.01" required />
				</td>
			</tr>
		</table>
		<p>
			<input type="submit" name="add_product" value="Add product">
		</p>
	</form>
<?php
} else {
	echo "There are no awaiting deliveries";
}
?>
