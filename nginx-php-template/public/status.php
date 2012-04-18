<!DOCTYPE html>
<?php
function runcmd($cmd) {
    $file = popen($cmd, 'r');
    $ret = fread($file, 1048576);
    pclose($file);
    return str_replace("\n", '<br />', $ret);
}

$title = $_SERVER['SITE_NAME'];
$properties = Array();
$properties['Nginx version'] = substr($_SERVER['SERVER_SOFTWARE'], strpos($_SERVER['SERVER_SOFTWARE'], '/')+1);
$properties['PHP version'] = phpversion();
$properties['System'] = runcmd('uname -a');
$properties['Memory'] = runcmd('free');
$properties['Disk'] = runcmd('df -h');
?>
<html>
    <head>
        <title><?php echo $title ?></title>
        <link rel="stylesheet" type="text/css" href="/status.css" />
    </head>
    <body>
        <h1><?php echo $title ?></h1>
        <table>
        <?php foreach ($properties as $name => $data) { ?>
            <tr>
                <td nowrap><?php echo $name ?></td>
                <td><?php echo $data ?></td>
            </tr>
        <?php } ?>
        </table>
    </body>
</html>
