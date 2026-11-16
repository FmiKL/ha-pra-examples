<?php

header('Cache-Control: no-store');

$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$method = $_SERVER['REQUEST_METHOD'];

if (!in_array($path, ['/', '/health'], true)) {
    http_response_code(404);
    exit;
}

if ($method !== 'GET' && !($path === '/' && $method === 'POST')) {
    http_response_code(405);
    header('Allow: ' . ($path === '/' ? 'GET, POST' : 'GET'));
    exit;
}

$maintenance = file_exists(__DIR__ . '/.maintenance');
if ($maintenance && $path !== '/health') {
    http_response_code(503);
    header('Content-Type: text/plain; charset=utf-8');
    echo 'Maintenance en cours.';
    exit;
}

try {
    $environment = getenv('APP_ENV');
    if ($environment === false || $environment === '') {
        throw new RuntimeException('Variable APP_ENV manquante.');
    }

    $db = new PDO(
        sprintf(
            'mysql:host=%s;dbname=%s;charset=utf8mb4',
            getenv('DB_HOST'),
            getenv('DB_NAME'),
        ),
        getenv('DB_USER'),
        getenv('DB_PASSWORD'),
        [PDO::ATTR_TIMEOUT => 3],
    );

    if ($method === 'POST') {
        if ($db->exec('UPDATE counter SET value = value + 1 WHERE id = 1') !== 1) {
            throw new RuntimeException('Compteur manquant.');
        }

        header('Location: /', true, 303);
        exit;
    }

    $value = $db->query('SELECT value FROM counter WHERE id = 1')->fetchColumn();
    if ($value === false) {
        throw new RuntimeException('Compteur manquant.');
    }
} catch (RuntimeException $error) { // PDOException hérite de RuntimeException.
    error_log($error->getMessage());

    http_response_code(503);
    header(
        'Content-Type: ' . ($path === '/health' ? 'application/json' : 'text/plain')
        . '; charset=utf-8',
    );
    echo $path === '/health' ? '{"status":"unavailable"}' : 'Service indisponible.';
    exit;
}

if ($path === '/health') {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode([
        'status' => 'ok',
        'environment' => $environment,
        'maintenance' => $maintenance,
        'counter' => (int) $value,
    ]);
    exit;
}
?>
<!doctype html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <title>Compteur</title>
</head>
<body>
    <h1>Compteur</h1>
    <p>Environnement <?= htmlspecialchars($environment) ?></p>
    <p>Compteur <?= (int) $value ?></p>
    <form method="post"><button>Ajouter 1</button></form>
    <a href="/health">État de santé</a>
</body>
</html>
