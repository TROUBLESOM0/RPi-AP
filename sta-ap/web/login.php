<?php
// login.php v.1
// requires install into /var/www/html
// requires www-data:www-data u+rwx,g+rx,o+r
//
ini_set('display_errors', 1);
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
        echo "Login has been saved successfully! ";
        echo "Configuring ...";
        $output = shell_exec('bash /usr/local/etc/subcloud/sta-ap/web/run-check.sh');
        echo "<pre>$output</pre>";
    } else {
        echo "Error opening the file!";
    }
} else {
    echo "Invalid request.";
}
?>
