<?php

// Load environment variables from .env file
require_once __DIR__ . '/loadEnv.php';
loadEnv('/var/www/.env'); // Path di dalam Docker container

$host = getenv('POSTGRES_HOST') ?: 'localhost';
$dbname = getenv('POSTGRES_DB') ?: 'your_db';
$user = getenv('POSTGRES_USER') ?: 'your_user';
$password = getenv('POSTGRES_PASSWORD') ?: 'your_password';

try {
    $dsn = "pgsql:host=$host;port=5432;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "✅ Connected to PostgreSQL successfully!<br>";
    echo "Database: $dbname<br>";
    echo "User: $user<br>";
    
    // Test query
    $stmt = $pdo->query('SELECT version()');
    $version = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "PostgreSQL Version: " . $version['version'];
    
} catch (PDOException $e) {
    echo "❌ Connection failed: " . $e->getMessage();
}
?>