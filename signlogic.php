<?php
session_start();
require "conexion.php";

$email = $_POST['email'] ?? '';
$contraseña = $_POST['contraseña'] ?? '';

if (!$email || !$contrasena) {
    exit("Todos los campos deben llenarse");
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    exit("El email no es válido");
}

// Verificar si el correo ya existe
$check = $conexion->prepare("SELECT id FROM usuarios WHERE email = :email");
$check->execute([':email' => $email]);
if ($check->fetch()) {
    exit("Este correo electrónico ya está registrado.");
}

$contra_hash = password_hash($contrasena, PASSWORD_DEFAULT);
$rol_defecto = 'usuario';

$consulta = $conexion->prepare(
    "INSERT INTO usuarios (email, contraseña, rol) VALUES (:email, :contraseña, :rol)"
);
$consulta->execute([
    ":email"  => $email,
    ":contraseña" => $contra_hash,
    ":rol"    => $rol_defecto
]);

$_SESSION["email"] = $email;
$_SESSION["rol"] = $rol_defecto;

header("Location: index.php");
exit;
?>