<?php 

const PRIVATE_KEY = <<<EOD
-----BEGIN RSA PRIVATE KEY-----
MIICXwIBAAKBgQC+1xcYsEE+ab/Ame1/HHAgfBRhD67I9mBYCiOJqC3lJX5RKFvt
OTcF5Sf5Bz3NL/2QWPLu40+yt4EvjZ3HOUAHrVgo2Fjo4vpaRoEaEtaccOziPH/A
SScOfL+uppNGOa0glTCZLKVZI3Go8zoutr8VDw2dNT7rDM/4TvPjwMYd3QIDAQAB
AoGBAL7C9n1hQfaHcnut4i8bWCHApgZXzNlpHekjSV7C1A2oKtopQ6qfdJbZ99kA
GhDPFeGCaGPOqM32jJXiM4L/gTXxdaZMlthVgxQRqrnGkh4NqPQLAYo0qgb21TsY
RE2BXdSET1E8WbGWjZ4508Jx6TNtTaSJJlgsSnqVibJHAEyBAkEA3i/+jif6KKVm
Q0aS0TJIPCOjp2fmBfke27j/BdC2wJ5Arp1VO+sgKM8qJqaoOUCv+z08WGyIostF
oOfRiGF9DQJBANvh3WQkbIjAgVrWoasHI54S7lz8kkeqKJ30LdIUK/1I9+rf3iy5
YvSmrnH4VnTx4XfxemKfF+HQNnlqcf1sEBECQQCbidGTRl0S0yaRdfgVRjPXFcPc
zxjxmYGGoyyzr3YfxSjWlAE03tY2ez+wqv4chjIrmKSD6gaEn/PwPhgqdsSJAkEA
nRoW3ZsstNSeV7Hsls8mAqZSCrwnI+8O0DSLnILvHyxIfldvXZMjgdup3iJqW2oL
B3DQWbCEFsJ2eW+1fDT+kQJBANUUbnJNJtrUMK013eEIWwgXLk7cnJ71CkhtnVUP
6sK44uktZ2a6YSkpmcRPgniy6McUR8g58ZgMeXn5OUv91lU=
-----END RSA PRIVATE KEY-----
EOD;

$files = "";
$zipFile = "script.zip";
$finalFile = "v1";
for ($i = 1; $i < count($argv); $i ++) {
    if ($argv[$i] == '-o') {
        $finalFile = $argv[$i + 1];
        break;
    }
    $files .= $argv[$i] . " ";
}

if (!empty($files)) {

    //compress files
    echo system("zip $zipFile $files"); 

    //get and encrypt zip file's md5
    $zipFileMD5 = md5_file($zipFile);
    $private_key = openssl_pkey_get_private(PRIVATE_KEY);
    $ret = openssl_private_encrypt($zipFileMD5, $encrypted, $private_key);

    if (!$ret || empty($encrypted)) {
        unlink($zipFile);
        echo "fail to encrypt file md5";
    }

    $md5File = "key";
    file_put_contents($md5File, $encrypted);

    //pack script zip file and md5 file to final zip file
    echo system("zip $finalFile $zipFile $md5File"); 

    unlink($md5File);
    unlink($zipFile);
}
