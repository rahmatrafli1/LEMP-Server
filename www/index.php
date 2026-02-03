<?php
// Load environment variables from .env file
require_once __DIR__ . '/loadEnv.php';
loadEnv('/var/www/.env'); // Path di dalam Docker container
?>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LEMP Server</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="shortcut icon" href="icon/nginx.png" type="image/x-icon">
</head>

<body>
    <div class="theme-selector">
        <button id="theme-toggle" class="theme-toggle" aria-label="Toggle theme mode">
            <span class="sun-icon">☀️</span>
            <span class="moon-icon">🌙</span>
            <span class="system-icon">💻</span>
        </button>

        <div id="theme-menu" class="theme-menu">
            <button class="theme-option" data-theme="light" title="Light Mode">
                <span class="theme-icon">☀️</span>
            </button>
            <button class="theme-option" data-theme="dark" title="Dark Mode">
                <span class="theme-icon">🌙</span>
            </button>
            <button class="theme-option" data-theme="system" title="System">
                <span class="theme-icon">💻</span>
            </button>
        </div>
    </div>

    <div class="container">
        <h1>Welcome!!!</h1>
        <div class="container-button">
            <a href="info.php" class="btn-primary" target="_blank">View PHP Info</a>
            <a href="phpmyadmin" target="_blank" class="btn-primary">PHPMyAdmin</a>
        </div>

        <p>This is a LEMP server (Linux, Nginx, MariaDB, PHP)</p>

        <p>PHP Version: <?php echo phpversion(); ?></p>

        <p>Nginx Version:
            <?php
            $nginxVersion = shell_exec('nginx -v 2>&1');
            echo htmlspecialchars($nginxVersion);
            ?>
        </p>

        <p>MariaDB Status:
            <?php
            try {
                // Get database credentials from environment variables
                $dbHost = getenv('DB_HOST') ?: 'localhost';
                $dbName = getenv('DB_DATABASE') ?: 'your_database';
                $dbUser = getenv('DB_USER') ?: 'root';
                $dbPass = getenv('DB_PASSWORD') ?: '';

                $pdo = new PDO("mysql:host=$dbHost;dbname=$dbName", $dbUser, $dbPass);
                $version = $pdo->query('SELECT VERSION()')->fetchColumn();
                echo "Connected! <br> Version: " . htmlspecialchars($version);
            } catch (PDOException $e) {
                echo "Connection failed: " . htmlspecialchars($e->getMessage());
            }
            ?>
        </p>
    </div>

    <script src="js/theme-toggle.js"></script>
</body>

</html>