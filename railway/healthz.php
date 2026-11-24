<?php
// Railway health check: answers 200 only when PHP runs and the SQLite database can be queried.
header('Content-Type: text/plain');
header('Cache-Control: no-store');
try {
    $path = getenv('DB_DATABASE') ?: '/app/database/sqlite/database.sqlite';
    $db = new PDO('sqlite:' . $path, null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    $db->query('SELECT 1 FROM users LIMIT 1');
    echo "ok\n";
} catch (Throwable $e) {
    http_response_code(503);
    echo "database not ready\n";
}
