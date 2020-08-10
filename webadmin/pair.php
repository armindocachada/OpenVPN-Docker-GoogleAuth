<?php
require 'vendor/autoload.php';

$appName=$_GET["AppName"];
$appInfo=$_GET["AppInfo"];
$secretCode=$_GET["SecretCode"];




$valid = isset($appName,$appInfo,$secretCode) && $appName != '' && $appInfo != '' && $secretCode != '';

if (!$valid) {
    header('HTTP/1.0 400 Bad Request');
    die('Invalid parameters passed');
}

$ga = new PHPGangsta_GoogleAuthenticator();


$qrCodeUrl = $ga->getQRCodeGoogleUrl('${appName} (${appInfo})', $secretCode);
echo '<img src='.$qrCodeUrl.' border=0/>';