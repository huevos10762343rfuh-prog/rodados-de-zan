<?php
require "conexion.php";

$email = $_POST['email'];
$contraseña = $_POST['contraseña'];

if(!$email || !$contraseña){
    echo("todos los campos deben de llenarse");
};
$peticion = $conexion ->query("SELECT * FROM usuarios");
foreach($peticion as $usuario){
    if($user['email'] == $email){
        password_verify($contraseña, $user["contraseña"]);
        $_SESSION["email"] = $user["email"];
        $_SESSION["contra"] = $user["contraseña"];
        }

    
    header('location: index.php');
    exit()
};
?>