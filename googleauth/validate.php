<?php
require 'vendor/autoload.php';

$pin=$_GET["Pin"];
$secretCode=$_GET["SecretCode"];


$valid = isset($pin, $secretCode) && $pin != '' && $secretCode != '';

if (!$valid) {
    header('HTTP/1.0 400 Bad Request');
    die('Invalid parameters passed');
}

else {
    $ga = new PHPGangsta_GoogleAuthenticator();

    $checkResult = $ga->verifyCode($secretCode, $pin, 2);    // 2 = 2*30sec clock tolerance
    if ($checkResult) {
        echo 'True';
    } else {
        echo 'False';
    }
}