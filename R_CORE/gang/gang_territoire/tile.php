<?php
$tileSize = 256;

$z = isset($_GET['z']) ? (int)$_GET['z'] : 0;
$x = isset($_GET['x']) ? (int)$_GET['x'] : 0;
$y = isset($_GET['y']) ? (int)$_GET['y'] : 0;

$imagePath = 'map.png';
list($width, $height) = getimagesize($imagePath);

$scale = pow(2, $z);
$tileSize = 256 * $scale;

$sx = $x * $tileSize;
$sy = $y * $tileSize;
$sw = min($tileSize, $width - $sx);
$sh = min($tileSize, $height - $sy);

$image = imagecreatefrompng($imagePath);
$tile = imagecreatetruecolor($tileSize, $tileSize);

imagecopyresampled($tile, $image, 0, 0, $sx, $sy, $tileSize, $tileSize, $sw, $sh);

header('Content-Type: image/png');
imagepng($tile);
imagedestroy($tile);
imagedestroy($image);
?>
